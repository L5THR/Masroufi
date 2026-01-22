import '../../../admin/data/models/user_account.dart';

class JobSeekerProfile {
  final int id;
  final int? userId; // Direct userId from backend DTO
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? cvUrl;
  final String? profilePictureUrl;
  final UserAccount? user; // The actual user account with the real user ID

  JobSeekerProfile({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.cvUrl,
    this.profilePictureUrl,
    this.user,
  });

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    // Handle both DTO format (fullName) and full profile format (firstName/lastName)
    String firstName = '';
    String lastName = '';

    if (json.containsKey('fullName') && json['fullName'] != null) {
      // DTO format: parse fullName into firstName and lastName
      final parts = (json['fullName'] as String).split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    } else {
      // Full profile format
      firstName = json['firstName'] ?? '';
      lastName = json['lastName'] ?? '';
    }

    return JobSeekerProfile(
      id: json['id'] ?? 0,
      userId: json['userId'] as int?,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: json['phoneNumber'],
      cvUrl: json['cvUrl'],
      profilePictureUrl: json['profilePictureUrl'],
      user: json['user'] != null ? UserAccount.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'cvUrl': cvUrl,
      'profilePictureUrl': profilePictureUrl,
      if (user != null) 'user': user!.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
}
