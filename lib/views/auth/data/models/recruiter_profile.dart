class RecruiterProfile {
  final int id;
  final String companyName;
  final String? companyLogoUrl;
  final String? website;

  RecruiterProfile({
    required this.id,
    required this.companyName,
    this.companyLogoUrl,
    this.website,
  });

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      id: int.tryParse(json['id'].toString()) ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogoUrl: json['companyLogoUrl'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'website': website,
    };
  }
}
