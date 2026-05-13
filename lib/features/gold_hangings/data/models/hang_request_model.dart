class HangRequestModel {
  final List<int> goldIds;
  final String? hangNote;

  HangRequestModel({required this.goldIds, this.hangNote});

  Map<String, dynamic> toJson() => {
        'gold_ids': goldIds,
        if (hangNote != null && hangNote!.trim().isNotEmpty)
          'hang_note': hangNote!.trim(),
      };
}
