class Invitee {
  final String name;
  final String phoneNumber;
  final String numberOfPeople;
  final String uuid;
  final String responseStatus;
  final DateTime? sentAt;
  final DateTime? respondedAt;

  Invitee({
    required this.name,
    required this.phoneNumber,
    required this.numberOfPeople,
    required this.uuid,
    this.responseStatus = 'pending',
    this.sentAt,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'numberOfPeople': numberOfPeople,
      'uuid': uuid,
      'responseStatus': responseStatus,
      'sentAt': sentAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory Invitee.fromJson(Map<String, dynamic> json) {
    return Invitee(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      numberOfPeople: json['numberOfPeople'] ?? '1',
      uuid: json['uuid'] ?? '',
      responseStatus: json['responseStatus'] ?? 'pending',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }
}