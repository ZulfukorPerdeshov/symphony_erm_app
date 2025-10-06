class UserDto {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'],
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        avatarUrl: json['avatarUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  UserDto copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phone,
        'password': password,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        user: UserDto.fromJson(json['user']),
      );
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}

class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String email;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
}

class FileUploadResponse {
  final String url;
  final String fileName;
  final int fileSize;

  FileUploadResponse({
    required this.url,
    required this.fileName,
    required this.fileSize,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        url: json['url'],
        fileName: json['fileName'],
        fileSize: json['fileSize'],
      );
}

// Basic user info from Users/by-Ids endpoint
class UserBasicDto {
  final String id;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? email;

  UserBasicDto({
    required this.id,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.email,
  });

  String get fullName => '$firstName $lastName';

  factory UserBasicDto.fromJson(Map<String, dynamic> json) => UserBasicDto(
        id: json['id'],
        phoneNumber: json['phoneNumber'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        avatar: json['avatar'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'avatar': avatar,
        'email': email,
      };
}