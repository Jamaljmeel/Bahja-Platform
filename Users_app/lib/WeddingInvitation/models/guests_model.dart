class EventModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventType;
  final String eventDate;
  final String eventTime;
  final String location;
  final String inviterName;

  EventModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.inviterName,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> data) {
    return EventModel(
      id: id,
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? 'مناسبة غير محددة',
      eventType: data['eventType'] ?? 'نوع غير محدد',
      eventDate: data['eventDate']?.toString() ?? 'تاريخ غير محدد',
      eventTime: data['eventTime']?.toString() ?? 'وقت غير محدد',
      location: data['location']?.toString() ?? 'مكان غير محدد',
      inviterName: data['inviterName']?.toString() ?? 'داعي غير محدد',
    );
  }
}

class InviteeModel {
  final String id;
  final String name;
  final String phoneNumber;
  final int numberOfPeople;
  final String uuid;
  final String responseStatus;
  final DateTime? sentAt;
  final DateTime? respondedAt;

  InviteeModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.numberOfPeople,
    required this.uuid,
    required this.responseStatus,
    this.sentAt,
    this.respondedAt,
  });

  factory InviteeModel.fromMap(String id, Map<String, dynamic> data) {
    return InviteeModel(
      id: id,
      name: data['name']?.toString() ?? 'غير محدد',
      phoneNumber: data['phoneNumber']?.toString() ?? 'غير محدد',
      numberOfPeople: (data['numberOfPeople'] as num?)?.toInt() ?? 1,
      uuid: data['uuid']?.toString() ?? '',
      responseStatus: data['responseStatus']?.toString() ?? 'pending',
      sentAt: data['sentAt']?.toDate(),
      respondedAt: data['respondedAt']?.toDate(),
    );
  }

  bool get isPending => responseStatus == 'pending';
  bool get isCheckedIn => responseStatus == 'checked_in';
}

class InviteeStatus {
  static const String pending = 'pending';
  static const String checkedIn = 'checked_in';
}