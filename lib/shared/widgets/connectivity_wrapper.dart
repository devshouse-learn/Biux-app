
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);
  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOnline = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } on SocketException catch (_) {
      if (mounted) setState(() => _isOnline = false);
    } on TimeoutException catch (_) {
      if (mounted) setState(() => _isOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offline banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOnline ? 0 : 36,
          width: double.infinity,
          color: Colors.red[700],
          child: _isOnline
              ? null
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Sin conexión a internet', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
