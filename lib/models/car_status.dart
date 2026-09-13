class CarStatus {
  final double batteryVoltage;
  final int throttle;
  final int steering;
  final bool connected;
  final int maxForwardSpeed;
  final int maxReverseSpeed;
  final int rampStep;

  const CarStatus({
    this.batteryVoltage = 0,
    this.throttle = 0,
    this.steering = 60,
    this.connected = false,
    this.maxForwardSpeed = 100,
    this.maxReverseSpeed = 100,
    this.rampStep = 5,
  });

  CarStatus copyWith({
    double? batteryVoltage,
    double? sensorVoltage,
    int? throttle,
    int? steering,
    bool? connected,
    int? maxForwardSpeed,
    int? maxReverseSpeed,
    int? rampStep,
  }) {
    return CarStatus(
      batteryVoltage:
          batteryVoltage ?? this.batteryVoltage,
      throttle:
          throttle ?? this.throttle,
      steering:
          steering ?? this.steering,
      connected:
          connected ?? this.connected,
          maxForwardSpeed: maxForwardSpeed ?? this.maxForwardSpeed,
      maxReverseSpeed: maxReverseSpeed ?? this.maxReverseSpeed,
      rampStep: rampStep ?? this.rampStep,
    );
  }
}