import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../services/api_service.dart';
import '../widgets/status_card.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SleepProvider>().init());
  }

  @override
  Widget build(BuildContext context) {
    final sleepProvider = context.watch<SleepProvider>();
    final apiService = context.read<ApiService>(); // Access the API Service
    final isSleeping = sleepProvider.isSleeping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Sleep Control'),
        actions: [
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
              // ignore: use_build_context_synchronously
              context.read<SleepProvider>().clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Main Status Card (Existing) ---
                StatusCard(
                  isSleeping: isSleeping,
                  onToggle: () async {
                    // Toggle local state
                    sleepProvider.setSleeping(!isSleeping);

                    // Sync state with Hardware API
                    final newState = !isSleeping ? "sleeping" : "awake";
                    await apiService.updateSleepState(newState);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mode switched to: $newState")));
                    }
                  },
                ),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                // --- Manual Hardware Controls ---
                const Text("Manual Controls", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Lights Button
                    _HardwareButton(icon: Icons.lightbulb, label: "Light ON", color: Colors.orangeAccent, onTap: () => apiService.toggleLights(true)),
                    _HardwareButton(
                      icon: Icons.lightbulb_outline,
                      label: "Light OFF",
                      color: Colors.grey,
                      onTap: () => apiService.toggleLights(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Curtains Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.curtains),
                    label: const Text("Open Curtains"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => apiService.openCurtains(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for the buttons to keep code clean
class _HardwareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HardwareButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
