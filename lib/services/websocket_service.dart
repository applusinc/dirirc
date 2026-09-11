import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/car_status.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _telemetryTimeoutTimer;
  static const Duration _telemetryTimeoutDuration = Duration(milliseconds: 1000);

  final StreamController<CarStatus>
      _statusController =
      StreamController<CarStatus>.broadcast();

  final StreamController<DateTime>
      _pongController =
      StreamController<DateTime>.broadcast();
final StreamController<String> _notificationController =
      StreamController<String>.broadcast();
  CarStatus _status =
      const CarStatus();

  Stream<CarStatus> get statusStream =>
      _statusController.stream;

  Stream<DateTime> get pongStream =>
      _pongController.stream;

  bool get isConnected =>
      _status.connected;
      Stream<String> get notificationStream => _notificationController.stream;
void _notify(String message) {
    if (!_notificationController.isClosed) {
      _notificationController.add(message);
    }
  }
  Future<void> connect() async {
    
    await disconnect();
    _notify('Araç ile bağlantı kuruluyor...');

    final uri = Uri.parse(
      'ws://192.168.4.1:81/',
    );

    try {
      final channel =
          WebSocketChannel.connect(uri);

      _channel = channel;

      _subscription =
          channel.stream.listen(
        _handleMessage,
        onError: (_) {
          _notify('Bağlantı hatası oluştu! onerror');
          print('Bağlantı kurulamadı!1');
          _handleDisconnect();
        },
        onDone: () {
          _notify('Bağlantı hatası oluştu! ondone');
          print('Bağlantı kurulamadı!2');
          _handleDisconnect();
        },
        cancelOnError: true,
      );

      await channel.ready;
    } catch (_) {
      _notify('Bağlantı kurulamadı!');
      print('Bağlantı kurulamadı!3');
      _handleDisconnect();
    }
  }

  void _handleMessage(dynamic message) {
    
    if (message is! String) {
      return;
    }
    _resetTelemetryTimeout();
    if (message == 'READY') {
      _status =
          _status.copyWith(
        connected: true,
        throttle: 0,
      );
      _notify('Araç ile bağlantı başarıyla sağlandı!');
      _emitStatus();

      return;
    }

    if (message.startsWith('PONG:')) {
      _pongController.add(
        DateTime.now(),
      );

      return;
    }

    if (message.startsWith('V:')) {
      _parseTelemetry(message);
    }
  }
  void _resetTelemetryTimeout() {
    _telemetryTimeoutTimer?.cancel();
    _telemetryTimeoutTimer = Timer(_telemetryTimeoutDuration, () {
      _notify('Sinyal kesildi! Araçtan yanıt alınamıyor.');
      // 1000 ms boyunca ESP32'den hiçbir veri gelmediyse bağlantıyı koptu say
      
    });
  }
  void _parseTelemetry(String message) {
    try {
      
      final sections =
          message.split('|');

      double battery =
          _status.batteryVoltage;


      int throttle =
          _status.throttle;

      int steering =
          _status.steering;
      

      for (final section in sections) {
        if (section.startsWith('V:')) {
          final values =
              section.substring(2)
                  .split(',');

          if (values.length >= 2) {
            battery =
                double.tryParse(
                  values[0],
                ) ??
                battery;

            
          }
        }

        if (section.startsWith('T:')) {
          throttle =
              int.tryParse(
                section.substring(2),
              ) ??
              throttle;
        }

        if (section.startsWith('S:')) {
          steering =
              int.tryParse(
                section.substring(2),
              ) ??
              steering;
        }
      }

      _status = CarStatus(
        batteryVoltage: battery,
        throttle: throttle,
        steering: steering,
        connected: true,
      );

      _emitStatus();
    } catch (_) {
      // Hatalı paket uygulamayı bozmasın.
    }
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  void sendThrottle(int value) {
    value = value.clamp(-100, 100);
    print(value);

    _send(
      'T:$value',
    );
  }

  void stop() {
    _send('STOP');
  }

  void sendSteering(int angle) {
    angle = angle.clamp(30, 90);
    print("direksiyon");
    _send(
      'S:$angle',
    );
    
  }

  void ping() {
    final timestamp =
        DateTime.now()
            .millisecondsSinceEpoch;

    _send(
      'PING:$timestamp',
    );
  }

  void _send(String message) {
    final channel = _channel;

    if (channel == null) {
      return;
    }

    

    try {
      channel.sink.add(message);
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _telemetryTimeoutTimer?.cancel();
    _telemetryTimeoutTimer = null;
    _status =
        _status.copyWith(
      connected: false,
      throttle: 0,
    );
    _notify('Bağlantı kesildi!');

    _emitStatus();
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();

    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {}

    _channel = null;

    _status =
        _status.copyWith(
      connected: false,
      throttle: 0,
    );

    _emitStatus();
  }

  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();

    _statusController.close();
    _pongController.close();
  }
}