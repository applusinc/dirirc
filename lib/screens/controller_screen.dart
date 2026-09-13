import 'dart:async';

import 'package:flutter/material.dart';

import '../models/car_status.dart';
import '../services/websocket_service.dart';
import '../widgets/stop_button.dart';
import '../widgets/steering_slider.dart';
import '../widgets/throttle_slider.dart';
import '../widgets/top_status_bar.dart';

class ControllerScreen extends StatefulWidget {
  final WebSocketService socket;

  const ControllerScreen({
    super.key,
    required this.socket,
  });

  @override
  State<ControllerScreen> createState() =>
      _ControllerScreenState();
}

class _ControllerScreenState
    extends State<ControllerScreen> {

  StreamSubscription? _statusSubscription;
  StreamSubscription? _pongSubscription;

  Timer? _pingTimer;
  int _currentLightMode = 0;

  CarStatus status =
      const CarStatus();

  int ping = 0;

  DateTime? pingStart;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = widget.socket.notificationStream.listen(
    (message) {
      if (!mounted) return;

      // Üst üste binen eski bildirimleri temizler
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF151A22),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    },
  );

    _statusSubscription =
        widget.socket.statusStream.listen(
      (value) {
        if (!mounted) return;

        setState(() {
          status = value;
        });
      },
    );

    _pongSubscription =
        widget.socket.pongStream.listen(
      (_) {
        if (pingStart == null) return;

        final elapsed =
            DateTime.now()
                .difference(
                  pingStart!,
                )
                .inMilliseconds;

        if (!mounted) return;

        setState(() {
          ping = elapsed;
        });
      },
    );

    _pingTimer =
        Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) {
        if (!status.connected) {
          return;
        }

        pingStart =
            DateTime.now();

        widget.socket.ping();
      },
    );

    widget.socket.connect();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();

    _statusSubscription?.cancel();
    _pongSubscription?.cancel();

    widget.socket.stop();

    super.dispose();
  }

  void openSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<CarStatus>(
          stream: widget.socket.statusStream,
          initialData: widget.socket.currentStatus,
          builder: (context, snapshot) {
            final currentStatus = snapshot.data ?? status;

            return AlertDialog(
              backgroundColor: const Color(0xFF151A22),
              title: const Text(
                'Araç Ayarları',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Maks. İleri Hız: %${currentStatus.maxForwardSpeed}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: currentStatus.maxForwardSpeed.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 18,
                      onChanged: (val) {
                        widget.socket.sendMaxForwardSpeed(val.round());
                      },
                    ),
                    const Divider(color: Colors.white12),
                    Text(
                      'Maks. Geri Hız: %${currentStatus.maxReverseSpeed}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: currentStatus.maxReverseSpeed.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 18,
                      onChanged: (val) {
                        widget.socket.sendMaxReverseSpeed(val.round());
                      },
                    ),
                    const Divider(color: Colors.white12),
                    Text(
                      'Hızlanma Sertliği (ACC): ${currentStatus.rampStep}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Slider(
                      value: currentStatus.rampStep.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      onChanged: (val) {
                        widget.socket.sendRampStep(val.round());
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'KAPAT',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF090C11),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(7),

          child: Column(
            children: [

              // ==================================================
              // ÜST BAR
              // ==================================================

              SizedBox(
                height: 55,

                child: TopStatusBar(
                  status: status,
                  ping: ping,

                  onConnect: () {
                    widget.socket
                        .connect();
                        
                  },

                  onDisconnect: () {
                    widget.socket
                        .disconnect();
                  },

                  onSettings:
                      openSettings,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              // ==================================================
              // ANA ALAN
              // ==================================================

              Expanded(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  

                  children: [

                    // ==========================================
                    // SOL - GAZ
                    // ==========================================

                    Expanded(
                      flex: 5,

                      child: _ControlCard(
                        title: 'GAZ',

                        value:
                            '${status.throttle}%',
                        onHornPressed: () => widget.socket.sendHorn(),
                        onLightPressed: () {
                          _currentLightMode = (_currentLightMode + 1) % 5;
                          widget.socket.sendLightMode(_currentLightMode);
                        },
                        onTurboChanged: (active) =>
                            widget.socket.sendTurbo(active),
                        child: ThrottleSlider(
                          initialValue: status.throttle,
                          onChanged: (value) =>
                              widget.socket.sendThrottle(value),
                          onReleased: () => widget.socket.stop(),
                        ),)),

                        
                           

                    

                    // ==========================================
                    // ORTA
                    // ==========================================

                    

                   
                    // ==========================================
                    // SAĞ - DİREKSİYON
                    // ==========================================

                    Expanded(
                      flex: 5,

                      child: _ControlCardSteering(
                        title:
                            'DİREKSİYON',

                        value:
                            '${status.steering}°',

                        child:
                            SteeringSlider(
                          initialValue:
                              status.steering,

                          onChanged:
                              (value) {
                            widget.socket
                                .sendSteering(
                              value,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              // ==================================================
              // ALT BAR
              // ==================================================

              SizedBox(
                height: 28,

                child:
                    _BottomBar(
                  status: status,
                  ping: ping,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// CONTROL CARD
// =============================================================

class _ControlCard
    extends StatelessWidget {

  final String title;
  final String value;
  final Widget child;
  final VoidCallback onHornPressed;
  final VoidCallback onLightPressed;
  final Function(bool active) onTurboChanged;

  const _ControlCard({
    required this.title,
    required this.value,
    required this.child,
    required this.onHornPressed,
    required this.onLightPressed,
    required this.onTurboChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        7,
        10,
        7,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF151A22,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Başlık
          

          

          // Büyük kontrol alanı
          child,
          const SizedBox(width: 12,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
              
                children: [
                  Text(
                    title,
              
                    style:
                        const TextStyle(
                      color:
                          Colors.white54,
              
                      fontSize: 12,
              
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
              
                  const SizedBox(
                    width: 9,
                  ),
              
                  Text(
                    value,
              
                    style:
                        const TextStyle(
                      fontSize: 21,
              
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  IconButton.filled(
                constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                ),
                icon: const Icon(Icons.campaign, color: Colors.white, size: 20),
                onPressed: onHornPressed,
              ),
              const SizedBox(height: 7,),
              IconButton.filled(
                constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                icon:
                    const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                onPressed: onLightPressed,
              ),
              const SizedBox(height: 7,),
              GestureDetector(
                onTapDown: (_) => onTurboChanged(true),
                onTapUp: (_) => onTurboChanged(false),
                onTapCancel: () => onTurboChanged(false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.yellow, size: 16),
                      SizedBox(width: 2),
                      Text(
                        'TURBO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),)
                  
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlCardSteering
    extends StatelessWidget {

  final String title;
  final String value;
  final Widget child;

  const _ControlCardSteering({
    required this.title,
    required this.value,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        7,
        10,
        7,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF151A22,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Row(
        children: [

          // Başlık
          

          

          // Büyük kontrol alanı
          Expanded(
            child: child,
          ),
          
        ],
      ),
    );
  }
}

// =============================================================
// ORTA PANEL
// =============================================================

class _CenterPanel
    extends StatelessWidget {

  final CarStatus status;
  final int ping;
  final VoidCallback onStop;

  const _CenterPanel({
    required this.status,
    required this.ping,
    required this.onStop,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    String state;

    if (status.throttle > 0) {
      state = 'İLERİ';
    } else if (status.throttle < 0) {
      state = 'GERİ';
    } else {
      state = 'DURUYOR';
    }

    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF151A22,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          const Text(
            'DURUM',
            style:
                TextStyle(
              color:
                  Colors.white54,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            state,

            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            '${status.batteryVoltage.toStringAsFixed(2)} V',

            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            '$ping ms',

            style:
                const TextStyle(
              color:
                  Colors.white38,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          StopButton(
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}


// =============================================================
// ALT BAR
// =============================================================

class _BottomBar extends StatelessWidget {
  final CarStatus status;
  final int ping;

  const _BottomBar({
    required this.status,
    required this.ping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151A22),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            'Maks. hız %${status.maxForwardSpeed}',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
          Text(
            'Direksiyon ${status.steering}°',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          Text(
            'Ping $ping ms',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
          Text(
            'Akü ${status.batteryVoltage.toStringAsFixed(2)} V',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

}