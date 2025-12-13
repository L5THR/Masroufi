class RecruiterProfile {
  final int id;
  final String companyName;
  final String? companyLogo;
  final String? website;

  RecruiterProfile({
    required this.id,
    required this.companyName,
    this.companyLogo,
    this.website,
  });

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      id: json['id'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'website': website,
    };
  }
}
