import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/auth_provider.dart';
import '../../../features/settings/logic/lang_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'widgets/auth_loading_splash.dart';
import '../../../core/utils/snackbar_helper.dart';

class LoginScreen extends StatefulWidget {
  final AppLang lang;
  final VoidCallback onToggleLang;

  const LoginScreen({
    super.key,
    required this.lang,
    required this.onToggleLang,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    final lang = context.read<LangProvider>().lang;
    final strings = AppStrings(lang);

    final error = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (error != null && mounted) {
      String message;
      if (error == 'empty_fields') {
        message = strings.isAr ? 'يرجى إدخال البريد الإلكتروني وكلمة المرور' : 'Please enter your email and password';
      } else if (error == 'user-not-found') {
        message = strings.isAr ? 'لا يوجد حساب بهذا البريد' : 'No account found with this email';
      } else if (error == 'wrong-password' || error == 'invalid-credential') {
        message = strings.isAr ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة' : 'Incorrect email or password';
      } else if (error == 'invalid-email') {
        message = strings.isAr ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
      } else if (error == 'email_not_verified') {
        message = strings.isAr ? 'يبدو أنك لم تقم بتأكيد حسابك. يرجى مراجعة بريدك الإلكتروني لتأكيد الحساب.' : 'Please verify your email address to login.';
      } else if (error == 'too-many-requests') {
        message = strings.isAr ? 'محاولات كثيرة، حاول لاحقاً' : 'Too many attempts, try again later';
      } else {
        message = strings.isAr ? 'حدث خطأ في تسجيل الدخول' : 'Login failed, please try again';
      }
      
      SnackbarHelper.show(
        message, 
        isError: true,
        action: SnackBarAction(
          label: strings.isAr ? 'إنشاء حساب' : 'Register',
          textColor: Colors.white,
          onPressed: () {
            final l = context.read<LangProvider>().lang;
            Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(lang: l)));
          },
        ),
      );
    }
  }

  Future<void> _handleBiometric() async {
    debugPrint('[LoginScreen] _handleBiometric() button tapped');
    final auth = context.read<AuthProvider>();
    final lang = context.read<LangProvider>().lang;
    final strings = AppStrings(lang);
    
    debugPrint('[LoginScreen] Awaiting auth.authenticateBiometrically()...');
    final errorCode = await auth.authenticateBiometrically();
    debugPrint('[LoginScreen] auth.authenticateBiometrically() finished with errorCode=$errorCode');
    
    if (errorCode != null && mounted) {
      debugPrint('[LoginScreen] Showing SnackBar for biometric failure: $errorCode');
      String errorMsg = '';
      
      switch (errorCode) {
        case 'not_available':
          errorMsg = strings.isAr ? 'البصمة غير متوفرة في هذا الجهاز أو معطلة.' : 'Biometric hardware is not available or disabled.';
          break;
        case 'not_enrolled':
          errorMsg = strings.isAr ? 'لم تقم بتسجيل أي بصمة أو وجه في الهاتف.' : 'No biometric enrolled on this device.';
          break;
        case 'no_saved_credentials':
          errorMsg = strings.isAr ? 'يجب تسجيل الدخول بالبريد وكلمة السر مرة واحدة أولاً ليتم حفظ بياناتك.' : 'Please login with email and password once to cache your session.';
          break;
        case 'auth_failed':
          errorMsg = strings.isAr ? 'فشلت المصادقة البيومترية، حاول مجدداً.' : 'Biometric authentication failed, try again.';
          break;
        case 'passcode_not_set':
          errorMsg = strings.isAr ? 'يرجى إعداد رمز حماية للهاتف لتفعيل البصمة.' : 'Please set a device passcode to use biometrics.';
          break;
        case 'system_error':
        default:
          errorMsg = strings.isAr ? 'حدث خطأ في النظام أثناء محاولة قراءة البصمة.' : 'A system error occurred during biometric scan.';
          break;
      }

      SnackbarHelper.show(
        errorMsg,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LangProvider>();
    final lang = langProvider.lang;
    final strings = AppStrings(lang);
    final auth = context.watch<AuthProvider>();
    final isAr = lang == AppLang.ar;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),

                        // Logo
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(AppTheme.spacingXL),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.kitchen_rounded, size: 64, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          strings.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.welcomeBack,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 48),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusL),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 24, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthField(
                                ctrl: _emailCtrl, 
                                label: strings.email, 
                                icon: Icons.email_outlined, 
                                type: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return isAr ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return isAr ? 'الرجاء إدخال بريد إلكتروني صحيح' : 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              _AuthField(
                                ctrl: _passCtrl, 
                                label: strings.password, 
                                icon: Icons.lock_outline, 
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return isAr ? 'الرجاء إدخال كلمة المرور' : 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return isAr ? 'كلمة المرور قصيرة جداً' : 'Password is too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppTheme.spacingS),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: auth.rememberMe,
                                        onChanged: (v) => auth.setRememberMe(v ?? false),
                                        activeColor: AppTheme.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Text(isAr ? 'تذكرني' : 'Remember me', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen(lang: lang)),
                                    ),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                    child: Text(isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingM),

                              // Login Button
                              ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                                  elevation: 0,
                                ),
                                child: Text(strings.login,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Biometric (if enabled)
                        if (auth.biometricAvailable && auth.biometricEnabled) ...[
                          Row(children: [
                            Expanded(child: Divider(color: Colors.grey.withAlpha(60))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(isAr ? 'أو' : 'OR', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.withAlpha(60))),
                          ]),
                          const SizedBox(height: AppTheme.spacingM),
                          GestureDetector(
                            onTap: _handleBiometric,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.primary.withAlpha(120), width: 1.5),
                                color: AppTheme.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fingerprint_rounded, color: AppTheme.primary, size: 28),
                                  const SizedBox(width: 10),
                                  Text(
                                    isAr ? 'الدخول السريع بالبصمة' : 'Quick Login with Biometrics',
                                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                        ],

                        // Guest continue
                        TextButton(
                          onPressed: () async {
                            final auth = context.read<AuthProvider>();
                            await auth.loginAsGuest();
                          },
                          child: Text(
                            isAr ? 'متابعة كزائر' : 'Continue as Guest',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ),

                        // Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isAr ? 'ليس لديك حساب؟' : "Don't have an account?", style: TextStyle(color: Colors.grey.shade600)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => RegisterScreen(lang: lang)),
                              ),
                              child: Text(strings.register, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ),
                          ],
                        ),

                        // Language
                        TextButton.icon(
                          onPressed: () => langProvider.toggle(),
                          icon: const Icon(Icons.language, size: 16, color: AppTheme.primary),
                          label: Text(isAr ? 'Switch to English' : 'تغيير للغة العربية', style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (auth.isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: AuthLoadingSplash(label: isAr ? 'جارٍ تسجيل الدخول...' : 'Signing you in...'),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared input widget
// ─────────────────────────────────────────────────────────────────────────────
class _AuthField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType type;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.type = TextInputType.text,
    this.validator,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.type,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: AppTheme.primary, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
