class ChoosePaymentArgs {
  final int timeSlotId;
  final String slotType; // 'online' or 'offline'
  final String? clinicName;

  ChoosePaymentArgs({
    required this.timeSlotId,
    required this.slotType,
    this.clinicName,
  });

  bool get isOnline => slotType.toLowerCase() == 'online';
}
