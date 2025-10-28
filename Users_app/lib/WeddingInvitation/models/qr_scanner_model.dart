// qr_scanner_model.dart
class QrCodeData {
  final String? invitationId;
  final String? inviteeId;
  final String eventName;
  final String inviteeName;
  final int numberOfPeople;
  final int checkedInCount;

  QrCodeData({
    this.invitationId,
    this.inviteeId,
    required this.eventName,
    required this.inviteeName,
    required this.numberOfPeople,
    this.checkedInCount = 0,
  });

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      invitationId: json['invitationId'],
      inviteeId: json['inviteeId'],
      eventName: json['eventName'] ?? 'غير معروف',
      inviteeName: json['inviteeName'] ?? 'غير معروف',
      numberOfPeople: (json['numberOfPeople'] ?? 1) as int,
      checkedInCount: (json['checkedInCount'] ?? 0) as int,
    );
  }

  bool get isValid => invitationId != null && inviteeId != null;
  bool get isFullyCheckedIn => checkedInCount >= numberOfPeople;
  int get remainingScans => numberOfPeople - checkedInCount;
}

class InviteeStatus {
  static const String pending = 'pending';
  static const String partiallyCheckedIn = 'partially_checked_in';
  static const String fullyCheckedIn = 'fully_checked_in';
}