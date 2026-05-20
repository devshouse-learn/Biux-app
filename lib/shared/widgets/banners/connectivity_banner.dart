import 'package:flutter/material.dart';
import 'package:biux/core/services/connectivity_service.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    return StreamBuilder<ConnectivityStatus>(
      stream: ConnectivityService().statusStream,
      initialData: ConnectivityService().status,
      builder: (context, snapshot) {
        final isOnline = snapshot.data != ConnectivityStatus.offline;
        return Column(
          children: [
            if (!isOnline)
              Material(
                color: Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        l.t('no_connection_offline'),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
