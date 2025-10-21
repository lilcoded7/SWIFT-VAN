import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4361EE);
  static const Color secondaryPurple = Color(0xFF7209B7);
  static const Color accentTeal = Color(0xFF4CC9F0);
  static const Color successGreen = Color(0xFF06D6A0);
  static const Color warningAmber = Color(0xFFFFD166);
  static const Color errorRed = Color(0xFFEF476F);
  static const Color backgroundWhite = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color shadowSubtle = Color(0x0D000000);
  static const Color overlayDark = Color(0x66000000);

  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [accentTeal, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Focus nodes for better form navigation
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Demo credentials for testing
  final String _demoPhone = "0241234567";
  final String _demoPassword = "Password123!";

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
    _loadSavedCredentials();
  }

  void _setupFocusNodes() {
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        _validatePhone(_phoneController.text);
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword(_passwordController.text);
      }
    });
  }

  void _loadSavedCredentials() {
    // In a real app, you would load these from secure storage
    // For demo purposes, we're using placeholder values
    // setState(() {
    //   _phoneController.text = _demoPhone;
    //   _passwordController.text = _demoPassword;
    // });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool get _isFormValid {
    return _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _login() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter phone number and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.backgroundWhite,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show success message
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.backgroundWhite,
      );

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Login failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.backgroundWhite,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _quickLogin() {
    setState(() {
      _phoneController.text = _demoPhone;
      _passwordController.text = _demoPassword;
    });
    _login();
  }

  void _loginWithGoogle() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Google login coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryBlue,
      textColor: AppTheme.backgroundWhite,
    );
  }

  void _loginWithFacebook() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Facebook login coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryBlue,
      textColor: AppTheme.backgroundWhite,
    );
  }

  void _loginWithPhone() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Phone login coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryBlue,
      textColor: AppTheme.backgroundWhite,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),

                // Welcome Back Section
                _buildWelcomeSection(),

                SizedBox(height: 6.h),

                // Phone Field
                _buildPhoneField(),

                SizedBox(height: 2.h),

                // Password Field
                _buildPasswordField(),

                SizedBox(height: 2.h),

                // Remember Me & Forgot Password
                _buildRememberForgotSection(),

                SizedBox(height: 4.h),

                // Login Button
                _buildLoginButton(),

                SizedBox(height: 3.h),

                // Quick Login Button (for demo)
                _buildQuickLoginButton(),

                SizedBox(height: 3.h),

                // Divider
                _buildDivider(),

                SizedBox(height: 3.h),

                // Social Login Options
                _buildSocialLogin(),

                SizedBox(height: 4.h),

                // Sign Up Link
                _buildSignUpLink(),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign in to continue with SwiftVan delivery services',
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
        ),
        SizedBox(height: 3.h),

        // App Logo/Branding
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 3.h),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.delivery_dining_rounded,
                color: Colors.white,
                size: 40.sp,
              ),
              SizedBox(height: 1.h),
              Text(
                'SwiftVan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Fast & Reliable Deliveries',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.phone_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
          ),
          style: TextStyle(fontSize: 14.sp),
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.done,
          obscureText: _obscurePassword,
          onFieldSubmitted: (_) => _login(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.lock_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
          ),
          style: TextStyle(fontSize: 14.sp),
          validator: _validatePassword,
        ),
      ],
    );
  }

  Widget _buildRememberForgotSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color:
                      _rememberMe
                          ? AppTheme.primaryBlue
                          : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        _rememberMe
                            ? AppTheme.primaryBlue
                            : AppTheme.textDisabled,
                    width: 2,
                  ),
                ),
                child:
                    _rememberMe
                        ? Icon(
                          Icons.check_rounded,
                          color: AppTheme.backgroundWhite,
                          size: 12,
                        )
                        : null,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Remember me',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),

        // Forgot Password
        GestureDetector(
          onTap: _navigateToForgotPassword,
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _login : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isFormValid ? AppTheme.primaryBlue : AppTheme.textDisabled,
          foregroundColor: AppTheme.backgroundWhite,
          elevation: _isFormValid ? 4 : 0,
          shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.backgroundWhite,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Signing In...',
                      style: TextStyle(
                        color: AppTheme.backgroundWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppTheme.backgroundWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
      ),
    );
  }

  Widget _buildQuickLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: OutlinedButton(
        onPressed: _quickLogin,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.successGreen,
          side: const BorderSide(color: AppTheme.successGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: AppTheme.successGreen,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              'Quick Demo Login',
              style: TextStyle(
                color: AppTheme.successGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.textDisabled.withOpacity(0.5))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            'Or continue with',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.textDisabled.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: AppTheme.errorRed,
          onPressed: _loginWithGoogle,
          label: 'Google',
        ),
        SizedBox(width: 4.w),
        _buildSocialButton(
          icon: Icons.facebook_rounded,
          color: AppTheme.primaryBlue,
          onPressed: _loginWithFacebook,
          label: 'Facebook',
        ),
        SizedBox(width: 4.w),
        _buildSocialButton(
          icon: Icons.phone_iphone_rounded,
          color: AppTheme.successGreen,
          onPressed: _loginWithPhone,
          label: 'Phone',
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
        ),
        GestureDetector(
          onTap: _navigateToSignUp,
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
