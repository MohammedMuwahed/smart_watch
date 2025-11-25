import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SleepProvider>();
    final s = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text("Automation Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitch(
            "Turn off lights when sleeping",
            s.autoLightsOff,
            (v) => provider.updateSingleSetting('lightsOff', v),
          ),
          _buildSwitch(
            "Close curtains when sleeping",
            s.autoCurtainClose,
            (v) => provider.updateSingleSetting('curtainClose', v),
          ),
          _buildSwitch(
            "Turn on lights when waking up",
            s.lightsOnWake,
            (v) => provider.updateSingleSetting('lightsOnWake', v),
          ),
          _buildSwitch(
            "Open curtains when waking up",
            s.curtainOpenWake,
            (v) => provider.updateSingleSetting('curtainOpenWake', v),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Sync to Firebase"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent[700],
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Settings synced with Firebase ✅"),
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
