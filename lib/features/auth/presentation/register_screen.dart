import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/auth_provider.dart';
import '../../../features/settings/logic/lang_provider.dart';
import 'widgets/auth_loading_splash.dart';
import '../../../core/utils/snackbar_helper.dart';

class RegisterScreen extends StatefulWidget {
  final AppLang lang;

  const RegisterScreen({super.key, required this.lang});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    final lang = context.read<LangProvider>().lang;
    final strings = AppStrings(lang);

    if (_passCtrl.text != _confirmCtrl.text) {
      SnackbarHelper.show(
        strings.isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match',
        isError: true,
      );
      return;
    }

    final error = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      if (!mounted) return;
      SnackbarHelper.show(
        strings.isAr
            ? '✅ تم إنشاء الحساب! تحقق من بريدك لتأكيد الحساب.'
            : '✅ Account created! Check your email to verify.',
        isError: false,
        duration: const Duration(seconds: 4),
      );
      Navigator.pop(context);
    } else {
      String message;
      if (error == 'email-already-in-use') {
        message = strings.isAr ? 'البريد الإلكتروني مستخدم بالفعل' : 'Email already in use';
      } else if (error == 'weak-password') {
        message = strings.isAr ? 'كلمة المرور ضعيفة (6 أحرف على الأقل)' : 'Password too weak (min 6 characters)';
      } else if (error == 'invalid-email') {
        message = strings.isAr ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
      } else {
        message = strings.isAr ? 'حدث خطأ، حاول مجدداً' : 'An error occurred, try again';
      }
      SnackbarHelper.show(message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>().lang;
    final strings = AppStrings(lang);
    final auth = context.watch<AuthProvider>();
    final isAr = lang == AppLang.ar;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: AppTheme.primary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(strings.register, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),

                // Header
                Hero(
                  tag: 'register_icon',
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withAlpha(25), AppTheme.primary.withAlpha(8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 48, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAr ? 'انضم إلى FitKitchen اليوم 🌿' : 'Join FitKitchen today 🌿',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 36),

                // Form card
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField(
                        _nameCtrl, 
                        strings.fullName, 
                        Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return isAr ? 'الرجاء إدخال اسمك الكامل' : 'Please enter your full name';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildField(
                        _emailCtrl, 
                        strings.email, 
                        Icons.email_outlined,
                        type: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return isAr ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter your email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return isAr ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildField(
                        _passCtrl, 
                        strings.password, 
                        Icons.lock_outline, 
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return isAr ? 'الرجاء إدخال كلمة المرور' : 'Please enter your password';
                          if (v.length < 6) return isAr ? 'كلمة المرور قصيرة (6 أحرف على الأقل)' : 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildField(
                        _confirmCtrl,
                        isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                        Icons.lock_reset_outlined,
                        isPassword: true,
                        validator: (v) {
                          if (v != _passCtrl.text) return isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Register button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusL),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  strings.register,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isAr ? 'لديك حساب بالفعل؟' : 'Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        strings.login,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      if (auth.isLoading)
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: AuthLoadingSplash(label: isAr ? 'جارٍ إنشاء الحساب...' : 'Creating your account...'),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.primary.withAlpha(8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(color: Colors.grey.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
    );
  }
}
