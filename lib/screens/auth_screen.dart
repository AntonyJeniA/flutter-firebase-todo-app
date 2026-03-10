// lib/screens/auth_screen.dart
// Login and Sign-up screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPassCtrl = TextEditingController();
  final _signupConfirmPassCtrl = TextEditingController();

  bool _loginPassVisible = false;
  bool _signupPassVisible = false;
  bool _signupConfirmPassVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    _signupConfirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    
    final success = await auth.signIn(_loginEmailCtrl.text, _loginPassCtrl.text);
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Login successful! Welcome back.'),
          backgroundColor: AppTheme.accent,
        ),
      );
    } else if (mounted && auth.errorMessage != null) {
      _showSnackBar(auth.errorMessage!, isError: true);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signupFormKey.currentState!.validate()) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    
    final success = await auth.signUp(
      _signupEmailCtrl.text,
      _signupPassCtrl.text,
      _signupNameCtrl.text,
    );
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: AppTheme.accent,
        ),
      );
      
      if (mounted) {
        _loginEmailCtrl.text = _signupEmailCtrl.text; // Pre-fill email
        
        // Clear sign up fields
        _signupNameCtrl.clear();
        _signupEmailCtrl.clear();
        _signupPassCtrl.clear();
        _signupConfirmPassCtrl.clear();
        
        // Switch to Sign In tab
        _tabController.animateTo(0);
      }
    } else if (mounted && auth.errorMessage != null) {
      _showSnackBar(auth.errorMessage!, isError: true);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthProvider>();
    
    final success = await auth.signInWithGoogle();
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In successful!'),
          backgroundColor: AppTheme.accent,
        ),
      );
    } else if (mounted && auth.errorMessage != null) {
      _showSnackBar(auth.errorMessage!, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.priorityHigh : AppTheme.accent,
      ),
    );
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.poppins(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email and we\'ll send you a password reset link.',
              style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) {
                _showSnackBar('Please enter your email', isError: true);
                return;
              }
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final auth = context.read<AuthProvider>();
              
              final ok = await auth.sendPasswordReset(emailCtrl.text);
              final errMsg = auth.errorMessage;
              
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Password reset email sent! Check your inbox.'
                      : (errMsg ?? 'Failed to send email')),
                  backgroundColor: ok ? AppTheme.accent : AppTheme.priorityHigh,
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 42)),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.bgDark, Color(0xFF1A0533)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // ── Logo & Header ──────────────────────────────
                _buildHeader(),
                const SizedBox(height: 40),
                // ── TabBar ────────────────────────────────────
                _buildTabBar(),
                const SizedBox(height: 24),
                // ── Tab Views ─────────────────────────────────
                SizedBox(
                  height: _tabController.index == 0 ? 380 : 480,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(isLoading),
                      _buildSignUpForm(isLoading),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // ── Divider ───────────────────────────────────
                _buildDivider(),
                const SizedBox(height: 20),
                // ── Google Sign In ─────────────────────────────
                _buildGoogleButton(isLoading),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(100),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'TaskFlow',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Organize your day, your way',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A4E)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
            ),
            validator: (v) =>
                v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPassCtrl,
            obscureText: !_loginPassVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _loginPassVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _loginPassVisible = !_loginPassVisible),
              ),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signupNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person_outline_rounded, color: AppTheme.primary),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primary),
            ),
            validator: (v) =>
                v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupPassCtrl,
            obscureText: !_signupPassVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _signupPassVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _signupPassVisible = !_signupPassVisible),
              ),
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signupConfirmPassCtrl,
            obscureText: !_signupConfirmPassVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon:
                  const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _signupConfirmPassVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => setState(
                    () => _signupConfirmPassVisible = !_signupConfirmPassVisible),
              ),
            ),
            validator: (v) => v != _signupPassCtrl.text
                ? 'Passwords do not match'
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _handleSignUp,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF2A2A4E))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: GoogleFonts.poppins(
                color: AppTheme.textHint, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF2A2A4E))),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2A2A4E)),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/48px-Google_%22G%22_logo.svg.png',
            height: 22,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
