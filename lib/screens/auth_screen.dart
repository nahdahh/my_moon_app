import 'package:flutter/material.dart';
import 'package:my_moon/screens/welcome_screen.dart';
import 'package:my_moon/widgets/social_login_button.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:intl/intl.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // Loading states
  bool _isRegistering = false;
  bool _isLoggingIn = false;
  
  // Error messages
  String? _registerError;
  String? _loginError;
  
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Connection test is still performed but status is not displayed
    _testConnection();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _testConnection() async {
    // Still test connection but don't show status
    await _authService.testConnection();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _register() async {
    // Reset error message
    setState(() {
      _registerError = null;
    });
    
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _birthDateController.text.isEmpty) {
      setState(() {
        _registerError = 'Please fill all fields';
      });
      return;
    }
    
    // Validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_emailController.text)) {
      setState(() {
        _registerError = 'Please enter a valid email address';
      });
      return;
    }
    
    // Validate password length
    if (_passwordController.text.length < 8) {
      setState(() {
        _registerError = 'Password must be at least 8 characters';
      });
      return;
    }
    
    setState(() {
      _isRegistering = true;
    });
    
    try {
      final success = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        birthDate: _birthDateController.text,
      );
      
      if (success) {
        // After successful registration, switch to login tab
        _tabController.animateTo(1);
        
        // Pre-fill login fields with registration data
        _loginEmailController.text = _emailController.text;
        _loginPasswordController.text = _passwordController.text;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in.')),
        );
      } else {
        setState(() {
          _registerError = 'Registration failed. Email may already be in use.';
        });
      }
    } catch (e) {
      setState(() {
        _registerError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }
  
  Future<void> _login() async {
    // Reset error message
    setState(() {
      _loginError = null;
    });
    
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      setState(() {
        _loginError = 'Please enter email and password';
      });
      return;
    }
    
    setState(() {
      _isLoggingIn = true;
    });
    
    try {
      final success = await _authService.login(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      
      if (success) {
        // Navigate to welcome screen after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _loginError = 'Login failed. Please check your credentials or server connection.';
        });
      }
    } catch (e) {
      setState(() {
        _loginError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFF7FD), // Light pink background
        child: SafeArea(
          child: Column(
            children: [
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFF4D6D),
                labelColor: const Color(0xFFFF4D6D),
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: 'Register'),
                  Tab(text: 'Login'),
                ],
              ),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRegisterTab(),
                    _buildLoginTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Register Screen
  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/mascot.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Join My Moon Today',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Sign up to start tracking your cycle today',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Username field with very rounded corners
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Username',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFFFF4D6D),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Email field with very rounded corners
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFFF4D6D),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Birth date field with very rounded corners
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    hintText: 'Birth Date',
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFFFF4D6D),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password field with rounded corners
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFFF4D6D),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            
            // Error message
            if (_registerError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _registerError!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isRegistering ? null : _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFF4D6D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: _isRegistering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Have an account? ',
                  style: TextStyle(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(1);
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFFFF4D6D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialLoginButton(iconPath: 'assets/images/facebook.png'),
                const SizedBox(width: 20),
                SocialLoginButton(iconPath: 'assets/images/google.png'),
                const SizedBox(width: 20),
                SocialLoginButton(iconPath: 'assets/images/apple.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Login Screen
  Widget _buildLoginTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/mascot.png',
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'Join My Moon Today',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to track your cycle today',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            // Email field with very rounded corners
            TextField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFFFF4D6D),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Password field with very rounded corners
            TextField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFFF4D6D),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            
            // Error message
            if (_loginError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loginError!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoggingIn ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFF4D6D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: _isLoggingIn
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have account? ',
                  style: TextStyle(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(0);
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFFFF4D6D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialLoginButton(iconPath: 'assets/images/facebook.png'),
                const SizedBox(width: 20),
                SocialLoginButton(iconPath: 'assets/images/google.png'),
                const SizedBox(width: 20),
                SocialLoginButton(iconPath: 'assets/images/apple.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
