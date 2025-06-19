import 'package:flutter/material.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/screens/notification_settings_screen.dart';
import 'package:intl/intl.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AuthService _authService = AuthService();

  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userBirthDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.data['name'] ?? 'User';
        _userEmail = user.data['email'] ?? 'user@example.com';
        _userBirthDate = user.data['birth_date'];
      });
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _EditProfileDialog(
          initialName: _userName,
          initialEmail: _userEmail,
          initialBirthDate: _userBirthDate,
          authService: _authService,
          onProfileUpdated: () {
            if (mounted) {
              _loadUserData();
            }
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _ChangePasswordDialog(
          authService: _authService,
        );
      },
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
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF000000),
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Setting',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Edit Profile Menu
                      _buildMenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: _showEditProfileDialog,
                      ),
                      const SizedBox(height: 16),
                      
                      // Change Password Menu
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: _showChangePasswordDialog,
                      ),
                      const SizedBox(height: 16),
                      
                      // Notification Settings Menu
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notification Settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationSettingsScreen(),
                            ),
                          );
                        },
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

// Keep the existing dialog classes (_EditProfileDialog and _ChangePasswordDialog) unchanged
class _EditProfileDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String? initialBirthDate;
  final AuthService authService;
  final VoidCallback onProfileUpdated;

  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
    required this.initialBirthDate,
    required this.authService,
    required this.onProfileUpdated,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  DateTime? _selectedDate;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _birthDateController = TextEditingController(
      text: widget.initialBirthDate != null 
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.initialBirthDate!)) 
          : ''
    );
    _selectedDate = widget.initialBirthDate != null 
        ? DateTime.parse(widget.initialBirthDate!) 
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF2D55),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    // Validate input
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Email cannot be empty');
      return;
    }
    
    // Validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    
    if (mounted) {
      setState(() {
        _isUpdating = true;
      });
    }
    
    try {
      final success = await widget.authService.updateProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDateController.text.trim().isNotEmpty 
            ? _birthDateController.text.trim() 
            : null,
      );
      
      if (mounted) {
        if (success) {
          widget.onProfileUpdated();
          Navigator.of(context).pop();
          _showSnackBar('Profile updated successfully');
        } else {
          _showSnackBar('Failed to update profile');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Username field
            TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA0A0A0),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFFF2D55),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA0A0A0),
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFFF2D55),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Birth date field
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthDateController,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Birth Date',
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA0A0A0),
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFFFF2D55),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () {
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
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF2D55),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Update',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AuthService authService;

  const _ChangePasswordDialog({
    required this.authService,
  });

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isUpdating = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate input
    if (_currentPasswordController.text.trim().isEmpty) {
      _showSnackBar('Current password cannot be empty');
      return;
    }
    
    if (_newPasswordController.text.trim().isEmpty) {
      _showSnackBar('New password cannot be empty');
      return;
    }
    
    if (_newPasswordController.text.trim().length < 6) {
      _showSnackBar('New password must be at least 6 characters');
      return;
    }
    
    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showSnackBar('New passwords do not match');
      return;
    }
    
    if (mounted) {
      setState(() {
        _isUpdating = true;
      });
    }
    
    try {
      final success = await widget.authService.changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      
      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          _showSnackBar('Password changed successfully');
        } else {
          _showSnackBar('Failed to change password. Please check your current password.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Change Password',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Password field
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA0A0A0),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFFF2D55),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFA0A0A0),
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // New Password field
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA0A0A0),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFFF2D55),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFA0A0A0),
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Confirm Password field
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA0A0A0),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFFF2D55),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFA0A0A0),
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF2D55)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () {
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
        ElevatedButton(
          onPressed: _isUpdating ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF2D55),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Change',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }
}
