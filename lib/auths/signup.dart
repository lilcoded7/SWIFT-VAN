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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  // Focus nodes for better form navigation
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  void _setupFocusNodes() {
    _fullNameFocusNode.addListener(() {
      if (!_fullNameFocusNode.hasFocus) {
        _validateField(_fullNameController.text, 'Full Name');
      }
    });

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

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _acceptTerms;
  }

  Future<void> _signUp() async {
    if (!_isFormValid) {
      Fluttertoast.showToast(
        msg: "Please fill all fields and accept the terms",
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
        msg: "Account created successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.backgroundWhite,
      );

      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Failed to create account. Please try again.",
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

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms & Conditions'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'By creating an account, you agree to our:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildTermItem('Privacy Policy'),
                  _buildTermItem('Terms of Service'),
                  _buildTermItem('Cookie Policy'),
                  _buildTermItem('User Agreement'),
                  SizedBox(height: 2.h),
                  Text(
                    'We respect your privacy and are committed to protecting your personal data.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildTermItem(String term) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppTheme.successGreen,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            term,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary),
          ),
        ],
      ),
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
                SizedBox(height: 4.h),

                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                SizedBox(height: 2.h),

                // Header Section
                _buildHeaderSection(),

                SizedBox(height: 4.h),

                // Full Name Field
                _buildFullNameField(),

                SizedBox(height: 2.h),

                // Phone Field
                _buildPhoneField(),

                SizedBox(height: 2.h),

                // Password Field
                _buildPasswordField(),

                SizedBox(height: 3.h),

                // Terms and Conditions
                _buildTermsCheckbox(),

                SizedBox(height: 4.h),

                // Sign Up Button
                _buildSignUpButton(),

                SizedBox(height: 3.h),

                // Divider
                _buildDivider(),

                SizedBox(height: 3.h),

                // Social Sign Up Options
                _buildSocialSignUp(),

                SizedBox(height: 3.h),

                // Login Link
                _buildLoginLink(),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign up to get started with SwiftVan delivery services',
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _fullNameController,
          focusNode: _fullNameFocusNode,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.person_rounded,
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
          validator: (value) => _validateField(value, 'Username'),
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
          decoration: InputDecoration(
            hintText: 'Create a strong password',
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

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _acceptTerms = !_acceptTerms;
            });
          },
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color:
                  _acceptTerms ? AppTheme.primaryBlue : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    _acceptTerms ? AppTheme.primaryBlue : AppTheme.textDisabled,
                width: 2,
              ),
            ),
            child:
                _acceptTerms
                    ? Icon(
                      Icons.check_rounded,
                      color: AppTheme.backgroundWhite,
                      size: 14,
                    )
                    : null,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: _showTermsDialog,
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _signUp : null,
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
                      'Creating Account...',
                      style: TextStyle(
                        color: AppTheme.backgroundWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Create Account',
                  style: TextStyle(
                    color: AppTheme.backgroundWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
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
            'Or sign up with',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.textDisabled.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildSocialSignUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: AppTheme.errorRed,
          onPressed: () {
            HapticFeedback.lightImpact();
            Fluttertoast.showToast(
              msg: "Google sign up coming soon",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.primaryBlue,
              textColor: AppTheme.backgroundWhite,
            );
          },
        ),
        SizedBox(width: 4.w),
        _buildSocialButton(
          icon: Icons.facebook_rounded,
          color: AppTheme.primaryBlue,
          onPressed: () {
            HapticFeedback.lightImpact();
            Fluttertoast.showToast(
              msg: "Facebook sign up coming soon",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.primaryBlue,
              textColor: AppTheme.backgroundWhite,
            );
          },
        ),
        SizedBox(width: 4.w),
        _buildSocialButton(
          icon: Icons.phone_iphone_rounded,
          color: AppTheme.successGreen,
          onPressed: () {
            HapticFeedback.lightImpact();
            Fluttertoast.showToast(
              msg: "Phone verification coming soon",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppTheme.primaryBlue,
              textColor: AppTheme.backgroundWhite,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
        ),
        GestureDetector(
          onTap: _navigateToLogin,
          child: Text(
            'Sign In',
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
