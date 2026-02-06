import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_watch/providers/sleep_provider.dart';
import 'package:smart_watch/services/index.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We need read access to ApiService
    final apiService = context.read<ApiService>();

    // We watch SleepProvider to reflect UI changes locally
    final provider = context.watch<SleepProvider>();
    final s = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text("Automation Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Turn off lights when sleeping
          // Device: lights, Setting: sleepingStatus
          _buildSwitch(
            "Turn off lights when sleeping",
            s.autoLightsOff,
            (bool value) {
              // Update Local UI
              provider.updateSingleSetting('lightsOff', value);
              // Send to API
              apiService.sleepingSetting("lights", "sleepingStatus", value);
            },
          ),

          // 2. Close curtains when sleeping
          // Device: curtain, Setting: sleepingStatus
          _buildSwitch(
            "Close curtains when sleeping",
            s.autoCurtainClose,
            (bool value) {
              provider.updateSingleSetting('curtainClose', value);
              apiService.sleepingSetting("curtain", "sleepingStatus", value);
            },
          ),

          // 3. Turn on lights when waking up
          // Device: lights, Setting: notSleepingStatus
          _buildSwitch(
            "Turn on lights when waking up",
            s.lightsOnWake,
            (bool value) {
              provider.updateSingleSetting('lightsOnWake', value);
              apiService.sleepingSetting("lights", "notSleepingStatus", value);
            },
          ),

          // 4. Open curtains when waking up
          // Device: curtain, Setting: notSleepingStatus
          _buildSwitch(
            "Open curtains when waking up",
            s.curtainOpenWake,
            (bool value) {
              provider.updateSingleSetting('curtainOpenWake', value);
              apiService.sleepingSetting("curtain", "notSleepingStatus", value);
            },
          ),

          const SizedBox(height: 20),

          // Optional: Keep Sync button if you still want manual Firebase sync
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Sync Settings to Server"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent[700],
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              // You can leave this empty if the switches update automatically,
              // or use it to re-send all current settings.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Settings updated via API ✅"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
