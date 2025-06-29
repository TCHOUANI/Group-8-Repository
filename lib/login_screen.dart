import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'home_screen.dart'; // Import home_screen.dart

class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialPassword;
  const LoginScreen({Key? key, this.initialEmail, this.initialPassword})
      : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  List<String> _savedEmails = [];
  bool _showEmailSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Auto-fill the form fields if initial values are provided
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialPassword != null) {
      _passwordController.text = widget.initialPassword!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load saved emails and remember me preference
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Load saved emails
    final savedEmails = prefs.getStringList('saved_emails') ?? [];
    final lastEmail = prefs.getString('last_email') ?? '';
    final rememberMe = prefs.getBool('remember_me') ?? false;

    setState(() {
      _savedEmails = savedEmails;
      _rememberMe = rememberMe;

      // Auto-fill last used email if remember me was checked
      if (rememberMe && lastEmail.isNotEmpty && widget.initialEmail == null) {
        _emailController.text = lastEmail;
      }
    });
  }

  // Save email and remember me preference
  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      final email = _emailController.text.trim();

      // Save the current email
      await prefs.setString('last_email', email);
      await prefs.setBool('remember_me', true);
      // Add to saved emails list if not already present
      if (!_savedEmails.contains(email)) {
        _savedEmails.add(email);
        await prefs.setStringList('saved_emails', _savedEmails);
      }
    } else {
      // Clear saved credentials if remember me is unchecked
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_email');
      await prefs.setBool('remember_me', false);
    }
  }

  // Handle user login with Firebase
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Save credentials before attempting login
      await _saveCredentials();

      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Login successful
      if (userCredential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        final bool? hasCompletedProfile = prefs.getBool('has_completed_profile');

        if (hasCompletedProfile == true) {
          // If profile completed, go to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(), // Assuming HomeScreen is the name of your home page class
            ),
          );
        } else {
          // If profile not completed, go to edit profile page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfilePage(
                fullName: '',
                phoneNumber: '',
                selectedLanguage: 'English',
                selectedAlertType: 'In-App Notification',
                roadHazardAlerts: false,
                locationTracking: false,
                roadSignTips: false,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'Login failed. Please check your credentials.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onEmailChanged(String value) {
    setState(() {
      _showEmailSuggestions = value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  // App Logo or Illustration
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _CarPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Welcome Text
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to your account to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: _onEmailChanged,
                  ),
                  if (_showEmailSuggestions && _savedEmails.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _savedEmails.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_savedEmails[index]),
                            onTap: () {
                              _emailController.text = _savedEmails[index];
                              setState(() {
                                _showEmailSuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                            activeColor: const Color(0xFF1A237E),
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // TODO: Implement Forgot Password logic
                              },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Login Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  // Sign Up Link
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          children: [
                            TextSpan(text: 'Don\'t have an account? '),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw car body
    paint.color = const Color(0xFF1A237E);
    paint.style = PaintingStyle.fill;
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.1, size.height * 0.6);
    bodyPath.lineTo(size.width * 0.0, size.height * 0.5);
    bodyPath.quadraticBezierTo(
        size.width * 0.1, size.height * 0.2, size.width * 0.3, size.height * 0.2);
    bodyPath.lineTo(size.width * 0.7, size.height * 0.2);
    bodyPath.quadraticBezierTo(
        size.width * 0.9, size.height * 0.2, size.width * 1.0, size.height * 0.5);
    bodyPath.lineTo(size.width * 0.9, size.height * 0.6);
    bodyPath.quadraticBezierTo(
        size.width * 0.8, size.height * 0.8, size.width * 0.7, size.height * 0.8);
    bodyPath.lineTo(size.width * 0.3, size.height * 0.8);
    bodyPath.quadraticBezierTo(
        size.width * 0.2, size.height * 0.8, size.width * 0.1, size.height * 0.6);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Draw windows
    paint.color = const Color(0xFFBBDEFB);
    final windowPath = Path();
    windowPath.moveTo(size.width * 0.3, size.height * 0.25);
    windowPath.lineTo(size.width * 0.2, size.height * 0.45);
    windowPath.lineTo(size.width * 0.4, size.height * 0.45);
    windowPath.close();
    canvas.drawPath(windowPath, paint);

    final backWindowPath = Path();
    backWindowPath.moveTo(size.width * 0.7, size.height * 0.25);
    backWindowPath.lineTo(size.width * 0.8, size.height * 0.45);
    backWindowPath.lineTo(size.width * 0.6, size.height * 0.45);
    backWindowPath.close();
    canvas.drawPath(backWindowPath, paint);

    // Draw tires
    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.7), size.width * 0.1, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.7), size.width * 0.1, paint);

    // Draw hubcaps
    paint.color = const Color(0xFF90A4AE);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.7), size.width * 0.06, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.7), size.width * 0.06, paint);

    // Draw eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.35), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.35), 2, paint);

    // Draw nose
    paint.color = const Color(0xFFCD853F);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.42), 1.5, paint);

    // Draw mouth
    paint.color = const Color(0xFF8B4513);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final mouthPath = Path();
    mouthPath.moveTo(size.width * 0.45, size.height * 0.5);
    mouthPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.52,
      size.width * 0.55,
      size.height * 0.5,
    );
    canvas.drawPath(mouthPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}