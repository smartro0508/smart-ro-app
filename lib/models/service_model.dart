class ServiceModel {
  final String? id;
  final String servicename;
  final String? description;
  final double servicecost;
  final double serviceproductcost;

  ServiceModel({
    this.id,
    required this.servicename,
    this.description,
    required this.servicecost,
    required this.serviceproductcost,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString(),
      servicename: json['servicename'] ?? json['name'] ?? '',
      description: json['description'],
      servicecost: json['servicecost'] != null ? double.parse(json['servicecost'].toString()) : 0.0,
      serviceproductcost: json['serviceproductcost'] != null ? double.parse(json['serviceproductcost'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'servicename': servicename,
      if (description != null) 'description': description,
      'servicecost': servicecost,
      'serviceproductcost': serviceproductcost,
    };
  }
}
