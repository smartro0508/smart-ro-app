import 'dart:convert';

class ServiceModel {
  final String? id;
  final String servicename;
  final String? description;
  final double servicecost;
  final double serviceproductcost;
  final List<String>? keypoints;
  final String? status;
  final String? image;

  ServiceModel({
    this.id,
    required this.servicename,
    this.description,
    required this.servicecost,
    required this.serviceproductcost,
    this.keypoints,
    this.status,
    this.image,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedKeypoints;
    if (json['keypoints'] != null) {
      try {
        parsedKeypoints = json['keypoints'] is String ? List<String>.from(jsonDecode(json['keypoints'])) : List<String>.from(json['keypoints']);
      } catch (_) {}
    }

    return ServiceModel(
      id: json['id']?.toString(),
      servicename: json['servicename'] ?? 'Unknown Service',
      description: json['description'],
      servicecost: json['servicecost'] != null ? double.parse(json['servicecost'].toString()) : 0.0,
      serviceproductcost: json['serviceproductcost'] != null ? double.parse(json['serviceproductcost'].toString()) : 0.0,
      keypoints: parsedKeypoints,
      status: json['status'],
      image: json['image'],
    );
  }
}
