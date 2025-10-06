import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static UserDto? _currentUser;

  static UserDto? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null && ApiService.hasValidToken;

  static Future<void> init() async {
    await _loadStoredUser();
    await ApiService.loadStoredToken();
  }

  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      log('Login response: $response');

      final loginResponse = LoginResponse.fromJson(response);


      // Store tokens securely
      await ApiService.setAccessToken(loginResponse.accessToken);
      await StorageService.storeSecure(
        AppConstants.refreshTokenKey,
        loginResponse.refreshToken,
      );

      // Store user data
      await _storeUser(loginResponse.user);
      _currentUser = loginResponse.user;

      return loginResponse;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate tokens on server
      if (ApiService.hasValidToken) {
        await ApiService.post(
          ApiConstants.identityServiceBaseUrl,
          ApiConstants.logoutEndpoint,
        );
      }
    } catch (e) {
      // Ignore logout API errors, proceed with local cleanup
    } finally {
      // Clear local data
      await _clearUserData();
      await ApiService.logout();
      _currentUser = null;
    }
  }

  static Future<UserDto> getUserProfile() async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.userProfileEndpoint,
      );

      final user = UserDto.fromJson(response);
      await _storeUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw e;
    }
  }

  static Future<UserDto> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await ApiService.put<Map<String, dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.userProfileEndpoint,
        data: request.toJson(),
      );

      final user = UserDto.fromJson(response);
      await _storeUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await ApiService.post(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.changePasswordEndpoint,
        data: request.toJson(),
      );
    } catch (e) {
      throw e;
    }
  }

  static Future<FileUploadResponse> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await ApiService.postMultipart<Map<String, dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.avatarEndpoint,
        formData: formData,
      );

      final uploadResponse = FileUploadResponse.fromJson(response);

      // Update user's avatar URL
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(avatarUrl: uploadResponse.url);
        await _storeUser(updatedUser);
        _currentUser = updatedUser;
      }

      return uploadResponse;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> removeAvatar() async {
    try {
      await ApiService.delete(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.avatarEndpoint,
      );

      // Update user's avatar URL to null
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(avatarUrl: null);
        await _storeUser(updatedUser);
        _currentUser = updatedUser;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<LoginResponse> refreshToken() async {
    try {
      final refreshToken = await StorageService.getSecure(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        throw ApiException(message: 'No refresh token available');
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await ApiService.post<Map<String, dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.refreshTokenEndpoint,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response);

      // Update stored tokens
      await ApiService.setAccessToken(loginResponse.accessToken);
      await StorageService.storeSecure(
        AppConstants.refreshTokenKey,
        loginResponse.refreshToken,
      );

      // Update user data
      await _storeUser(loginResponse.user);
      _currentUser = loginResponse.user;

      return loginResponse;
    } catch (e) {
      // If refresh fails, logout the user
      await logout();
      throw e;
    }
  }

  static Future<void> _storeUser(UserDto user) async {
    await StorageService.storeJson(AppConstants.userDataKey, user.toJson());
  }

  static Future<void> _loadStoredUser() async {
    final userData = StorageService.getJson(AppConstants.userDataKey);
    if (userData != null) {
      try {
        _currentUser = UserDto.fromJson(userData);
      } catch (e) {
        // Invalid stored user data, clear it
        await StorageService.remove(AppConstants.userDataKey);
      }
    }
  }

  static Future<void> _clearUserData() async {
    await StorageService.remove(AppConstants.userDataKey);
  }

  // Utility methods
  static String? get userFullName => _currentUser?.fullName;
  static String? get userEmail => _currentUser?.email;
  static String? get userAvatarUrl => _currentUser?.avatarUrl;
  static String? get userInitials => _currentUser?.initials;

  static bool hasPermission(String permission) {
    // TODO: Implement permission checking based on user roles
    // This would typically check user roles/permissions from the user object
    return true;
  }

  static Future<bool> validateSession() async {
    if (!isLoggedIn) return false;

    try {
      // Try to fetch user profile to validate session
      await getUserProfile();
      return true;
    } catch (e) {
      // Session is invalid, logout user
      await logout();
      return false;
    }
  }

  /// Fetch users by their IDs
  /// Returns a list of basic user information
  static Future<List<UserBasicDto>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final response = await ApiService.post<List<dynamic>>(
        ApiConstants.identityServiceBaseUrl,
        ApiConstants.usersByIdsEndpoint,
        data: userIds,
      );

      return response.map((json) => UserBasicDto.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}