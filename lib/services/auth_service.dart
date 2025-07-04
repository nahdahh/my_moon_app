import 'dart:io';
import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

final pb = PocketBase('http://127.0.0.1:8090');

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Initialize auth service and restore session if available
  Future<void> initializeAuth() async {
    try {
      print("Initializing auth service...");
      
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUserData = prefs.getString(_userDataKey);
      final wasLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      print("Saved token exists: ${savedToken != null}");
      print("Saved user data exists: ${savedUserData != null}");
      print("Was logged in: $wasLoggedIn");
      
      if (savedToken != null && savedUserData != null && wasLoggedIn) {
        try {
          // Restore auth state manually
          pb.authStore.save(savedToken, jsonDecode(savedUserData));
          print("Auth state restored from SharedPreferences");
          
          // Verify the token is still valid by trying to refresh
          await pb.collection('users').authRefresh();
          print("Token verified and refreshed successfully");
          
        } catch (e) {
          print("Failed to restore or verify auth state: $e");
          // Clear invalid data
          await _clearAuthData();
        }
      } else {
        print("No valid auth data found in SharedPreferences");
      }
      
      // Log current auth state
      print("Current auth state - Valid: ${pb.authStore.isValid}, Token: ${pb.authStore.token.isNotEmpty}");
      
    } catch (e) {
      print("Error initializing auth: $e");
    }
  }

  /// Save auth data to SharedPreferences
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, pb.authStore.token);
      await prefs.setString(_userDataKey, jsonEncode(pb.authStore.model?.toJson() ?? {}));
      await prefs.setBool(_isLoggedInKey, true);
      print("Auth data saved to SharedPreferences");
    } catch (e) {
      print("Error saving auth data: $e");
    }
  }

  /// Clear auth data from SharedPreferences
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.setBool(_isLoggedInKey, false);
      pb.authStore.clear();
      print("Auth data cleared from SharedPreferences");
    } catch (e) {
      print("Error clearing auth data: $e");
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String birthDate, // format: YYYY-MM-DD
  }) async {
    try {
      final body = {
        "email": email,
        "password": password,
        "passwordConfirm": password,
        "name": name,
        "birth_date": birthDate,
      };

      print("Registering user with email: $email");
      await pb.collection('users').create(body: body);
      
      // After registration, log in automatically
      print("Registration successful, attempting to login");
      final loginSuccess = await login(email: email, password: password);
      
      return loginSuccess;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print("Attempting to login with email: $email");
      
      // Clear any existing auth data first
      pb.authStore.clear();
      
      // Attempt login with timeout
      await pb.collection('users').authWithPassword(
        email, 
        password
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Login timeout - server not responding");
        }
      );
      
      print("Login successful. Auth valid: ${pb.authStore.isValid}");
      print("User ID: ${pb.authStore.model?.id}");
      print("Token length: ${pb.authStore.token.length}");
      
      // Verify that token is properly set
      if (!pb.authStore.isValid || pb.authStore.token.isEmpty) {
        print("Warning: Auth store is not valid after successful login");
        return false;
      }
      
      // Save auth data to SharedPreferences for persistence
      await _saveAuthData();
      
      return true;
    } catch (e) {
      print("Login error: $e");
      
      // Clear any partial auth data on error
      await _clearAuthData();
      
      // Provide detailed error information
      if (e.toString().contains("Failed to authenticate")) {
        print("Authentication failed - incorrect email or password");
      } else if (e.toString().contains("timeout")) {
        print("Login timeout - check server connection");
      } else if (e.toString().contains("404")) {
        print("Server endpoint not found - check PocketBase URL");
      }
      
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    print("Logging out user");
    await _clearAuthData();
  }

  /// Check if user is logged in with detailed logging
  bool isLoggedIn() {
    final isValid = pb.authStore.isValid;
    final hasToken = pb.authStore.token.isNotEmpty;
    final hasModel = pb.authStore.model != null;
    
    print("=== Auth Status Check ===");
    print("Auth valid: $isValid");
    print("Has token: $hasToken");
    print("Token: ${pb.authStore.token.substring(0, pb.authStore.token.length > 20 ? 20 : pb.authStore.token.length)}...");
    print("Has model: $hasModel");
    print("Model ID: ${pb.authStore.model?.id}");
    print("========================");
    
    return isValid && hasToken && hasModel;
  }

  /// Check login status from SharedPreferences as backup
  Future<bool> isLoggedInFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final hasToken = prefs.getString(_tokenKey) != null;
      final hasUserData = prefs.getString(_userDataKey) != null;
      
      print("Storage check - Was logged in: $wasLoggedIn, Has token: $hasToken, Has user data: $hasUserData");
      
      return wasLoggedIn && hasToken && hasUserData;
    } catch (e) {
      print("Error checking login status from storage: $e");
      return false;
    }
  }

  /// Get current user data
  RecordModel? getCurrentUser() {
    if (!isLoggedIn()) {
      print("Cannot get current user: User not logged in");
      return null;
    }
    return pb.authStore.model;
  }

  /// Refresh authentication token with better error handling
  Future<bool> refreshAuth() async {
    try {
      print("Attempting to refresh auth token...");
      
      // Check if we have a token to refresh
      if (pb.authStore.token.isEmpty) {
        print("No token available to refresh");
        return false;
      }
      
      await pb.collection('users').authRefresh();
      print("Auth token refreshed successfully");
      
      // Save the refreshed auth data
      await _saveAuthData();
      
      return true;
    } catch (e) {
      print("Failed to refresh auth token: $e");
      
      // Clear invalid auth data
      await _clearAuthData();
      
      return false;
    }
  }

  /// Update profile info - IMPROVED VERSION
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? birthDate,
    File? photoProfile, // image file
  }) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        print("Cannot update profile: User not logged in");
        return false;
      }

      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        print("Auth store is not valid, attempting to refresh");
        final refreshSuccess = await refreshAuth();
        if (!refreshSuccess) {
          print("Failed to refresh auth for profile update");
          return false;
        }
      }

      // Create a map for the form data
      final Map<String, dynamic> formData = {};
      if (name != null) formData['name'] = name;
      if (email != null) formData['email'] = email;
      if (birthDate != null) formData['birth_date'] = birthDate;
      
      print("Updating profile with data: $formData");
      
      // Handle file upload for profile photo
      if (photoProfile != null) {
        try {
          print("Uploading profile photo: ${photoProfile.path}");
          
          // Use PocketBase's native file upload method
          final fileBytes = await photoProfile.readAsBytes();
          final fileName = path.basename(photoProfile.path);
          
          // Create a direct HTTP request to PocketBase API
          final uri = Uri.parse('http://127.0.0.1:8090/api/collections/users/records/${currentUser.id}');
          
          // Create a multipart request
          final request = http.MultipartRequest('PATCH', uri);
          
          // Add authorization header
          request.headers['Authorization'] = pb.authStore.token;
          
          // Add the file as bytes
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo_profile',
              fileBytes,
              filename: fileName,
            ),
          );
          
          // Add other fields
          if (name != null) request.fields['name'] = name;
          if (email != null) request.fields['email'] = email;
          if (birthDate != null) request.fields['birth_date'] = birthDate;
          
          print("Sending request to update profile...");
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          
          if (response.statusCode != 200) {
            print("Failed to update profile: ${response.body}");
            return false;
          }
          
          // Refresh auth store to get updated user data
          await refreshAuth();
          return true;
        } catch (e) {
          print("Error uploading file: $e");
          return false;
        }
      } else {
        // If no file to upload, use the regular update method
        try {
          print("Updating profile without file upload...");
          await pb.collection('users').update(currentUser.id, body: formData);
          
          // Refresh auth store to get updated user data
          await refreshAuth();
          print("Profile updated and auth refreshed successfully");
          
          return true;
        } catch (e) {
          print("Error updating profile: $e");
          
          // Check if it's an email conflict error
          if (e.toString().contains("email") && e.toString().contains("unique")) {
            throw Exception("Email already exists. Please use a different email.");
          }
          
          return false;
        }
      }
    } catch (e) {
      print("Update profile error: $e");
      rethrow; // Re-throw to let the UI handle the specific error message
    }
  }
  
  /// Update profile photo using PocketBase's SDK directly
  Future<bool> updateProfilePhoto(List<int> fileBytes, String fileName) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        print("Cannot update profile photo: User not logged in");
        return false;
      }
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        print("Auth store is not valid, attempting to refresh");
        final refreshSuccess = await refreshAuth();
        if (!refreshSuccess) {
          print("Failed to refresh auth for profile photo update");
          return false;
        }
      }
      
      print("Updating profile photo using PocketBase SDK...");
      
      // Create a direct HTTP request to PocketBase API
      final uri = Uri.parse('http://127.0.0.1:8090/api/collections/users/records/${currentUser.id}');
      
      // Create a multipart request
      final request = http.MultipartRequest('PATCH', uri);
      
      // Add authorization header
      request.headers['Authorization'] = pb.authStore.token;
      
      // Add the file
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo_profile',
          fileBytes,
          filename: fileName,
        ),
      );
      
      print("Sending request to update profile photo...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (response.statusCode != 200) {
        print("Failed to update profile photo: ${response.body}");
        return false;
      }
      
      // Refresh auth store to get updated user data
      await refreshAuth();
      return true;
    } catch (e) {
      print("Update profile photo error: $e");
      return false;
    }
  }
  
  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        print("Cannot change password: User not logged in");
        return false;
      }
      
      // Get current user email
      final userEmail = currentUser.data['email'] as String;
      
      // First verify the current password by trying to authenticate
      try {
        print("Verifying current password...");
        // Create a new PocketBase instance to avoid affecting the current auth state
        final tempPb = PocketBase('http://127.0.0.1:8090');
        await tempPb.collection('users').authWithPassword(
          userEmail,
          currentPassword,
        );
        
        // If we get here, the current password is correct
        print("Current password verified successfully");
      } catch (e) {
        print("Failed to verify current password: $e");
        return false;
      }
      
      // Now update the password
      try {
        print("Updating password...");
        
        // Create the request body
        final body = {
          "password": newPassword,
          "passwordConfirm": newPassword,
        };
        
        // Update the user record
        await pb.collection('users').update(currentUser.id, body: body);
        
        print("Password updated successfully");
        
        // Refresh auth to ensure the session remains valid
        await refreshAuth();
        
        return true;
      } catch (e) {
        print("Failed to update password: $e");
        return false;
      }
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }
  
  /// Test connection to PocketBase server
  Future<bool> testConnection() async {
    try {
      print("Testing connection to PocketBase server...");
      final response = await http.get(Uri.parse('http://127.0.0.1:8090/api/health'))
          .timeout(const Duration(seconds: 5));
      
      print("Connection test response: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      return response.statusCode == 200;
    } catch (e) {
      print("Connection test error: $e");
      return false;
    }
  }
}
