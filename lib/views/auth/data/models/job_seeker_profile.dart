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
    return JobSeekerProfile(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
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
