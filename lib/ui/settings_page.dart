import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../services/api_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.read<ApiService>();
    final provider = context.watch<SleepProvider>();
    final s = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Automation Settings"),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // LIGHTS SECTION
          _buildSectionHeader(Icons.lightbulb_outline, "Light Automation"),
          _buildCard([
            _buildSwitch(
              "Off when sleeping",
              s.autoLightsOff,
              (val) {
                provider.updateSingleSetting('lightsOff', val);
                apiService.sleepingSetting("lights", "sleepingStatus", val);
              },
            ),
            _buildSwitch(
              "On when waking up",
              s.lightsOnWake,
              (val) {
                provider.updateSingleSetting('lightsOnWake', val);
                apiService.sleepingSetting("lights", "notSleepingStatus", val);
              },
            ),
          ]),

          const SizedBox(height: 24),

          // CURTAINS SECTION
          _buildSectionHeader(Icons.curtains, "Curtain Automation"),
          _buildCard([
            _buildSwitch(
              "Close when sleeping",
              s.autoCurtainClose,
              (val) {
                provider.updateSingleSetting('curtainClose', val);
                apiService.sleepingSetting("curtain", "sleepingStatus", val);
              },
            ),
            _buildSwitch(
              "Open when waking up",
              s.curtainOpenWake,
              (val) {
                provider.updateSingleSetting('curtainOpenWake', val);
                apiService.sleepingSetting("curtain", "notSleepingStatus", val);
              },
            ),
          ]),

          const SizedBox(height: 40),

          // Sync status indicator (Replaces the large button for a cleaner look)
          const Center(
            child: Text(
              "Settings are automatically synced to the cloud",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      activeColor: Colors.blue,
      value: value,
      onChanged: onChanged,
    );
  }
}
