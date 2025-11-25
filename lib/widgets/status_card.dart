import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isSleeping;
  final VoidCallback onToggle;

  const StatusCard({
    super.key,
    required this.isSleeping,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSleeping ? Icons.bedtime : Icons.wb_sunny,
              size: 80,
              color: isSleeping ? Colors.indigoAccent : Colors.amberAccent,
            ),
            const SizedBox(height: 16),
            Text(
              isSleeping ? "Sleeping..." : "Awake",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSleeping ? Colors.indigoAccent : Colors.amberAccent,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onToggle,
              icon: Icon(isSleeping ? Icons.wb_sunny : Icons.bedtime),
              label: Text(isSleeping ? "Wake Up" : "Go to Sleep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSleeping
                    ? Colors.indigoAccent
                    : Colors.amberAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
