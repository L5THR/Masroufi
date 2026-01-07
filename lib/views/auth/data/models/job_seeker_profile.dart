class JobSeekerProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? cvUrl;
  final String? profilePictureUrl;

  JobSeekerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.cvUrl,
    this.profilePictureUrl,
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
      firstName: firstName,
      lastName: lastName,
      phoneNumber: json['phoneNumber'],
      cvUrl: json['cvUrl'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'cvUrl': cvUrl,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  String get fullName => '$firstName $lastName';
}
