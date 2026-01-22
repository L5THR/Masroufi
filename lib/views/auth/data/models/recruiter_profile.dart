import '../../../admin/data/models/user_account.dart';

class RecruiterProfile {
  final int id;
  final int? userId; // Direct userId from backend DTO
  final String companyName;
  final String? companyLogoUrl;
  final String? website;
  final UserAccount? user; // The actual user account with the real user ID

  RecruiterProfile({
    required this.id,
    this.userId,
    required this.companyName,
    this.companyLogoUrl,
    this.website,
    this.user,
  });

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] as int?,
      companyName: json['companyName'] ?? '',
      companyLogoUrl: json['companyLogoUrl'],
      website: json['website'],
      user: json['user'] != null ? UserAccount.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'website': website,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
