class BankModel {
  final String? id;
  final String accountholder;
  final String bankname;
  final String accountnumber;
  final String ifsccode;
  final String branch;

  BankModel({
    this.id,
    required this.accountholder,
    required this.bankname,
    required this.accountnumber,
    required this.ifsccode,
    required this.branch,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['_id'] ?? json['id'],
      accountholder: json['accountholder'] ?? '',
      bankname: json['bankname'] ?? '',
      accountnumber: json['accountnumber'] ?? '',
      ifsccode: json['ifsccode'] ?? '',
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accountholder': accountholder,
      'bankname': bankname,
      'accountnumber': accountnumber,
      'ifsccode': ifsccode,
      'branch': branch,
    };
  }
}
