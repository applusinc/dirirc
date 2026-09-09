import 'package:flutter/material.dart';

import '../models/car_status.dart';

class TopStatusBar extends StatelessWidget {
  final CarStatus status;
  final int ping;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSettings;

  const TopStatusBar({
    super.key,
    required this.status,
    required this.ping,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSettings,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final connected =
        status.connected;

    return Container(
      height: 68,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF151A22),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          const Text(
            'DİRİ RC',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(width: 22),

          Icon(
            connected
                ? Icons.circle
                : Icons.circle_outlined,

            size: 12,

            color: connected
                ? Colors.greenAccent
                : Colors.redAccent,
          ),

          const SizedBox(width: 7),

          Text(
            connected
                ? 'BAĞLI'
                : 'BAĞLI DEĞİL',
            style: TextStyle(
              color: connected
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(width: 20),

          Text(
            '${status.batteryVoltage.toStringAsFixed(2)} V',
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(width: 15),

          Text(
            '$ping ms',
            style:
                const TextStyle(
              color:
                  Colors.white60,
            ),
          ),

          const Spacer(),

          OutlinedButton(
            onPressed:
                connected
                    ? onDisconnect
                    : onConnect,
            child: Text(
              connected
                  ? 'BAĞLANTIYI KES'
                  : 'BAĞLAN',
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: onSettings,
            icon:
                const Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
    );
  }
}