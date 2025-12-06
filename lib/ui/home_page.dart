import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1. Check status immediately on load
    Future.microtask(() => _checkStatus());

    // 2. Auto-refresh every 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final apiService = context.read<ApiService>();
    final sleepProvider = context.read<SleepProvider>();

    // Fetch from API: true = Sleeping, false = Awake
    bool currentStatus = await apiService.isSleeping();

    // Update global state
    sleepProvider.setSleeping(currentStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated from server'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider for changes
    final sleepProvider = context.watch<SleepProvider>();
    final bool isSleeping = sleepProvider.isSleeping;
    final settings = sleepProvider.settings;

    // Logic to determine text based on Settings
    String lightsStatus;
    String curtainsStatus;

    if (isSleeping) {
      // When sleeping: check "Auto Lights Off" and "Auto Curtain Close" settings
      lightsStatus = settings.autoLightsOff ? "OFF" : "ON";
      curtainsStatus = settings.autoCurtainClose ? "CLOSED" : "OPEN";
    } else {
      // When awake: check "Lights On Wake" and "Curtain Open Wake" settings
      lightsStatus = settings.lightsOnWake ? "ON" : "OFF";
      curtainsStatus = settings.curtainOpenWake ? "OPEN" : "CLOSED";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Sleep Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStatus,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                context.read<SleepProvider>().clear();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- STATUS UI START ---
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  // Dark Blue for Sleep, Orange for Awake
                  color: isSleeping ? const Color(0xFF1A237E) : Colors.orange.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(
                  // MOON if True, SUN if False
                  isSleeping ? Icons.bedtime : Icons.wb_sunny,
                  size: 120,
                  // Yellow Moon, Orange Sun
                  color: isSleeping ? Colors.amberAccent : Colors.orange,
                ),
              ),
              const SizedBox(height: 30),

              Text(
                isSleeping ? "User is Sleeping" : "User is Awake",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 50),

              Text(
                "Auto-refreshes every 30 seconds",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
