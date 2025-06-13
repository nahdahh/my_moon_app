import 'package:flutter/material.dart';
import 'package:my_moon/screens/notification_screen.dart';
import 'package:my_moon/screens/add_log_period_screen.dart';
import 'package:my_moon/screens/setting_screen.dart';
import 'package:my_moon/screens/theme_screen.dart';
import 'package:my_moon/screens/cycle_screen.dart';
import 'package:my_moon/widgets/bottom_nav_bar.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/screens/auth_screen.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  
  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userBirthDate;
  String? _profileImageUrl;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.data['name'] ?? 'User';
        _userEmail = user.data['email'] ?? 'user@example.com';
        _userBirthDate = user.data['birth_date'];
        
        // Get the profile image URL from PocketBase
        if (user.data['photo_profile'] != null && user.data['photo_profile'] != '') {
          // Construct the full URL to the profile image
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'users';
          final String recordId = user.id;
          final String fileName = user.data['photo_profile'];
          _profileImageUrl = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print('Profile image URL: $_profileImageUrl');
        } else {
          _profileImageUrl = null;
          print('No profile image available');
        }
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduce image quality to save space
      );
      
      if (pickedFile != null) {
        // Read the file as bytes to avoid path issues
        final bytes = await pickedFile.readAsBytes();
        final fileName = pickedFile.name;
        
        setState(() {
          _imageBytes = bytes;
          _imageName = fileName;
          print("Image picked: $fileName (${bytes.length} bytes)");
        });
        
        // Update the profile image
        await _updateProfileImage();
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  Future<void> _updateProfileImage() async {
    if (_imageBytes == null || _imageName == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print("Starting profile image update...");
      
      // Use the method that accepts bytes directly
      final success = await _authService.updateProfilePhoto(_imageBytes!, _imageName!);
      
      if (success) {
        print("Profile image updated successfully");
        // Reload user data to get the updated profile image URL
        _loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      } else {
        print("Failed to update profile image");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image')),
        );
      }
    } catch (e) {
      print("Error updating profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _imageBytes = null; // Clear the image bytes after upload attempt
        _imageName = null; // Clear the image name after upload attempt
      });
    }
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA0A0A0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA0A0A0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFF2D55),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _logout() {
    _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF000000), // Ubah dari Color(0xFFFF2D55) ke hitam
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Photo
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[100],
                                    ),
                                    child: ClipOval(
                                      child: _imageBytes != null 
                                          ? Image.memory(
                                              _imageBytes!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : (_profileImageUrl != null 
                                              ? Image.network(
                                                  _profileImageUrl!,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFF5F5F5),
                                                      ),
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 50,
                                                        color: Color(0xFFA0A0A0),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFF5F5F5),
                                                  ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Color(0xFFA0A0A0),
                                                  ),
                                                )),
                                    ),
                                  ),
                                  if (_isLoading)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFFFF2D55),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // User Name
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            // User Email
                            Text(
                              _userEmail,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFA0A0A0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Menu List
                      _buildMenuItem(
                        icon: Icons.refresh,
                        title: 'My Cycle',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CycleScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMenuItem(
                        icon: Icons.color_lens_outlined,
                        title: 'Appearance',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThemeScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notification',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Setting',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: _showLogoutConfirmation,
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLogPeriodScreen()),
          );
        },
        backgroundColor: const Color(0xFFFF2D55),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF2D55),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFA0A0A0),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
