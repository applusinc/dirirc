import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'screens/controller_screen.dart';
import 'services/websocket_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yalnızca yatay kullanım
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Ekran kapanmasın
  await WakelockPlus.enable();

  // Mümkün olduğunca tam ekran
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const RcCarApp());
}

class RcCarApp extends StatelessWidget {
  const RcCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DİRİ RC',

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFF090C11),
      ),

      home: ControllerScreen(
        socket: WebSocketService(),
      ),
    );
  }
}