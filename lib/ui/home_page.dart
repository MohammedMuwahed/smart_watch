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
    Future.microtask(() => _checkStatus());
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    bool currentStatus = await apiService.isSleeping();
    sleepProvider.setSleeping(currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    final sleepProvider = context.watch<SleepProvider>();
    final bool isSleeping = sleepProvider.isSleeping;
    final settings = sleepProvider.settings;

    // Device status logic
    String lightsStatus = isSleeping ? (settings.autoLightsOff ? "OFF" : "ON") : (settings.lightsOnWake ? "ON" : "OFF");
    String curtainsStatus = isSleeping ? (settings.autoCurtainClose ? "CLOSED" : "OPEN") : (settings.curtainOpenWake ? "OPEN" : "CLOSED");

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sleep Monitor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Makes the Menu (Drawer) icon white
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _checkStatus),
        ],
      ),
      // --- ADDED SIDE MENU (DRAWER) ---
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSleeping ? [const Color(0xFF0F2027), const Color(0xFF203A43)] : [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              accountName: const Text("Smart User", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("Control your smart home"),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.blue),
              title: const Text('Settings'),
              subtitle: const Text('Configure auto-actions'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            const Divider(),
            const Spacer(), // Pushes logout to the bottom
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                await context.read<AuthService>().signOut();
                if (mounted) {
                  context.read<SleepProvider>().clear();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSleeping
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                : [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Main Status Icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Icon(
                    isSleeping ? Icons.bedtime_rounded : Icons.wb_sunny_rounded,
                    size: 100,
                    color: isSleeping ? Colors.amberAccent : Colors.orangeAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSleeping ? "RESTING" : "ACTIVE",
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
              Text(
                isSleeping ? "User is Sleeping" : "User is Awake",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Device Status Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildStatusCard(
                      "Lights",
                      lightsStatus,
                      lightsStatus == "ON" ? Icons.lightbulb : Icons.lightbulb_outline,
                      lightsStatus == "ON" ? Colors.yellow : Colors.white54,
                    ),
                    const SizedBox(width: 15),
                    _buildStatusCard(
                      "Curtains",
                      curtainsStatus,
                      curtainsStatus == "OPEN" ? Icons.curtains : Icons.curtains_closed,
                      curtainsStatus == "OPEN" ? Colors.lightBlueAccent : Colors.white54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "System monitoring active",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
