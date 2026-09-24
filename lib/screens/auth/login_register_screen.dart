import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _Brand {
  static const blue = Color(0xFF3B82F6);
  static const ink = Color(0xFF1F2937);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const fieldFill = Color(0xFFF9FAFB);
  static const radius = 14.0;
}

enum _AuthMode { login, register }

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _isLogin => _mode == _AuthMode.login;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      UserCredential userCredential;

      if (_isLogin) {
        // =========================
        // LOGIN
        // =========================
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // =========================
        // REGISTER
        // =========================
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user's display name in Firebase Authentication
        await userCredential.user?.updateDisplayName(
          _nameCtrl.text.trim(),
        );
      }

      // Make sure the widget is still mounted
      if (!mounted) return;

      setState(() => _submitting = false);

      // Authentication was successful
      _onAuthenticated();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => _submitting = false);

      String message;

      switch (e.code) {
        // Login errors
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Invalid email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        // Registration errors
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password authentication is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        default:
          message = e.message ?? 'Authentication failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _submitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLogin
              ? 'Welcome back!'
              : 'Account created successfully!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onContinueAsGuest() {
    // TODO: navigate to HomeScreen in guest mode.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Continuing as guest')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _Header(isLogin: _isLogin),
                    const SizedBox(height: 28),
                    _ModeToggle(mode: _mode, onChanged: _switchMode),
                    const SizedBox(height: 28),

                    // Name field — only for Register, animated in/out.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      child: !_isLogin
                          ? Column(
                              children: [
                                _AuthField(
                                  controller: _nameCtrl,
                                  label: 'Full name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Enter your name'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    _AuthField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _AuthField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _Brand.muted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),

                    // Confirm-password field — only for Register.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      child: !_isLogin
                          ? Column(
                              children: [
                                const SizedBox(height: 16),
                                _AuthField(
                                  controller: _confirmCtrl,
                                  label: 'Confirm password',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscureConfirm,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _Brand.muted,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (_isLogin) return null;
                                    if (v != _passwordCtrl.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _submitting
                              ? null
                              : () async {
                                  final email = _emailCtrl.text.trim();

                                  if (email.isEmpty || !email.contains('@')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Enter your email first.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    await FirebaseAuth.instance.sendPasswordResetEmail(
                                      email: email,
                                    );

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password reset email sent. Check your inbox.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    if (!mounted) return;

                                    String message;

                                    switch (e.code) {
                                      case 'invalid-email':
                                        message = 'Please enter a valid email address.';
                                        break;

                                      case 'user-not-found':
                                        message = 'No account found with this email.';
                                        break;

                                      default:
                                        message =
                                            e.message ?? 'Unable to send password reset email.';
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: _Brand.blue, fontSize: 13),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Brand.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_Brand.radius),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _submitting
                              ? const SizedBox(
                                  key: ValueKey('spinner'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Log In' : 'Create Account',
                                  key: ValueKey(_isLogin),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: _Brand.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(color: _Brand.muted, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(color: _Brand.border)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    OutlinedButton.icon(
                      onPressed: _onContinueAsGuest,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: _Brand.ink,
                      ),
                      label: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: _Brand.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: _Brand.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_Brand.radius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isLogin});
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _Brand.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.home_repair_service_rounded,
              color: _Brand.blue, size: 28),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            isLogin ? 'Welcome back' : 'Create your account',
            key: ValueKey(isLogin),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _Brand.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLogin
              ? 'Log in to pick up where you left off'
              : 'Get AI-powered fixes and trusted pros, fast',
          style: const TextStyle(fontSize: 14, color: _Brand.muted),
        ),
      ],
    );
  }
}

/// Animated pill toggle between Login and Register, with a sliding
/// highlight (like an iOS segmented control).
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == _AuthMode.login;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _Brand.fieldFill,
        borderRadius: BorderRadius.circular(_Brand.radius),
        border: Border.all(color: _Brand.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment:
                isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_Brand.radius - 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ToggleLabel(
                  text: 'Log In',
                  active: isLogin,
                  onTap: () => onChanged(_AuthMode.login),
                ),
              ),
              Expanded(
                child: _ToggleLabel(
                  text: 'Register',
                  active: !isLogin,
                  onTap: () => onChanged(_AuthMode.register),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleLabel extends StatelessWidget {
  const _ToggleLabel({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? _Brand.ink : _Brand.muted,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _Brand.ink, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _Brand.muted, fontSize: 14),
        prefixIcon: Icon(icon, color: _Brand.muted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _Brand.fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Brand.radius),
          borderSide: const BorderSide(color: _Brand.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Brand.radius),
          borderSide: const BorderSide(color: _Brand.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Brand.radius),
          borderSide: const BorderSide(color: _Brand.blue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Brand.radius),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}