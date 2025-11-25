import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings_model.dart';

class SleepProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isSleeping = false;
  bool get isSleeping => _isSleeping;

  SettingsModel _settings = SettingsModel();
  SettingsModel get settings => _settings;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  String? get _uid => _auth.currentUser?.uid;
  String get _docId => "user_${_uid ?? 'anonymous'}";

  /// Initialize Firestore listener
  void init() {
    if (_uid == null) return;

    _userStream = _firestore.collection('sleep_states').doc(_docId).snapshots();
    _userStream!.listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _isSleeping = data['isSleeping'] ?? false;
        if (data.containsKey('settings')) {
          _settings = SettingsModel.fromMap(
            Map<String, dynamic>.from(data['settings']),
          );
        } else {
          await _createUserDoc();
        }
        notifyListeners();
      } else {
        await _createUserDoc();
      }
    });
  }

  Future<void> _createUserDoc() async {
    if (_uid == null) return;
    await _firestore.collection('sleep_states').doc(_docId).set({
      'isSleeping': false,
      'settings': _settings.toMap(),
    });
  }

  /// Toggle sleep state
  Future<void> setSleeping(bool value) async {
    if (_uid == null) return;
    _isSleeping = value;
    await _firestore.collection('sleep_states').doc(_docId).update({
      'isSleeping': value,
    });
    _performActionsBasedOnState();
    notifyListeners();
  }

  /// Update single automation preference
  Future<void> updateSingleSetting(String key, bool value) async {
    if (_uid == null) return;

    switch (key) {
      case 'lightsOff':
        _settings.autoLightsOff = value;
        break;
      case 'curtainClose':
        _settings.autoCurtainClose = value;
        break;
      case 'lightsOnWake':
        _settings.lightsOnWake = value;
        break;
      case 'curtainOpenWake':
        _settings.curtainOpenWake = value;
        break;
    }

    await _firestore.collection('sleep_states').doc(_docId).update({
      'settings': _settings.toMap(),
    });
    notifyListeners();
  }

  /// Smart-home simulation logic
  void _performActionsBasedOnState() {
    if (_isSleeping) {
      if (_settings.autoCurtainClose) debugPrint("🪟 Curtains closing...");
      if (_settings.autoLightsOff) debugPrint("💤 Lights off");
    } else {
      if (_settings.lightsOnWake) debugPrint("💡 Lights on");
      if (_settings.curtainOpenWake) debugPrint("🌅 Curtains opening...");
    }
  }

  void clear() {
    _isSleeping = false;
    _settings = SettingsModel();
    _userStream = null;
    notifyListeners();
  }
}
