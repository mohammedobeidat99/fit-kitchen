import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/auth_provider.dart';
import '../../../features/settings/logic/lang_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AppLang lang;

  const ForgotPasswordScreen({super.key, required this.lang});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final auth = context.read<AuthProvider>();
    final lang = context.read<LangProvider>().lang;
    final strings = AppStrings(lang);

    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(strings.isAr ? 'أدخل بريدك الإلكتروني' : 'Please enter your email'),
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final success = await auth.resetPassword(_emailCtrl.text.trim());
    if (!mounted) return;

    // Firebase best practice: always show success to prevent email enumeration
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
        title: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green),
          const SizedBox(width: 8),
          Text(strings.isAr ? 'تم الإرسال!' : 'Link Sent!'),
        ]),
        content: Text(
          strings.isAr
              ? 'إذا كان بريدك مسجلاً لدينا، ستصلك رسالة إعادة تعيين كلمة المرور.'
              : 'If your email is registered, you will receive a password reset link.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(strings.isAr ? 'عودة لتسجيل الدخول' : 'Back to Login'),
          ),
        ],
      ),
    );
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
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Icon
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withAlpha(25), AppTheme.primary.withAlpha(8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 56, color: AppTheme.primary),
                ),
                const SizedBox(height: 32),

                Text(
                  isAr ? 'إعادة تعيين كلمة المرور' : 'Reset your password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr
                      ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.'
                      : 'Enter your email and we\'ll send you a reset link.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                // Card
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
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: strings.email,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primary, size: 20),
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
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleReset,
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
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  isAr ? 'إرسال الرابط' : 'Send Reset Link',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Loading overlay
        if (auth.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(100),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 40),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isAr ? 'جارٍ المعالجة...' : 'Processing...',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
