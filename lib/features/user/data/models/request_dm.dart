enum RequestStatus { pending, approved }

class RequestModel {
  final String requestId;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String wasteType;
  final RequestStatus status;
  final String requestDate;

  RequestModel({
    required this.requestId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.wasteType,
    required this.status,
    required this.requestDate,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      requestId: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      wasteType: json['waste_type']?.toString() ?? '',
      status: json['status'] == 'approved'
          ? RequestStatus.approved
          : RequestStatus.pending,
      requestDate: json['request_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": requestId,
      "user_id": userId,
      "name": name,
      "phone": phone,
      "address": address,
      "waste_type": wasteType,
      "status": status.name, // 👈 مهم
      "request_date": requestDate,
    };
  }

  RequestModel copyWith({
    String? requestId,
    String? userId,
    String? name,
    String? phone,
    String? nationalId,
    String? address,
    String? wasteType,
    RequestStatus? status,
    String? requestDate,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      wasteType: wasteType ?? this.wasteType,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
    );
  }
}
