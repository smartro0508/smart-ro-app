class SettingModel {
  final String? id;
  final String companyName;
  final String supportEmail;
  final String phoneNumber;
  final String businessAddress;

  SettingModel({
    this.id,
    required this.companyName,
    required this.supportEmail,
    required this.phoneNumber,
    required this.businessAddress,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      id: json['id'],
      companyName: json['companyName'] ?? '',
      supportEmail: json['supportEmail'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      businessAddress: json['businessAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyName': companyName,
      'supportEmail': supportEmail,
      'phoneNumber': phoneNumber,
      'businessAddress': businessAddress,
    };
  }
}
