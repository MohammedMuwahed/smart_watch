import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_watch/models/settings_model.dart';

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

  Future<void> setSleeping(bool value) async {
    _isSleeping = value;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('sleep_states').doc('user_${user.uid}').set({
          'isSleeping': value,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error updating Firestore: $e");
      }
    }
  }

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

  void clear() {
    _isSleeping = false;
    _settings = SettingsModel();
    _userStream = null;
    notifyListeners();
  }
}
