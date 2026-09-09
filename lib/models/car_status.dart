class CarStatus {
  final double batteryVoltage;
  final int throttle;
  final int steering;
  final bool connected;

  const CarStatus({
    this.batteryVoltage = 0,
    this.throttle = 0,
    this.steering = 64,
    this.connected = false,
  });

  CarStatus copyWith({
    double? batteryVoltage,
    double? sensorVoltage,
    int? throttle,
    int? steering,
    bool? connected,
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
    );
  }
}