import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../models/recipe.dart';
import '../../../core/theme/app_theme.dart';
import '../logic/recipe_provider.dart';
import '../../../core/constants/app_strings.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  final AppLang lang;

  const CookingModeScreen({super.key, required this.recipe, required this.lang});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStepIndex = 0;
  late List<String> _steps;
  
  final FlutterTts flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _steps = widget.recipe.steps.split('\n').where((s) => s.trim().isNotEmpty).toList();
    _initTts();
  }

  Future<void> _initTts() async {
    final isAr = widget.lang == AppLang.ar;
    await flutterTts.setLanguage(isAr ? "ar" : "en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });

    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });

    flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _nextStep() async {
    await flutterTts.stop();
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
    } else {
      _finishCooking();
    }
  }

  void _prevStep() async {
    await flutterTts.stop();
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  void _finishCooking() {
    context.read<RecipeProvider>().markAsCooked(context, widget.recipe);
    Navigator.pop(context); // Back to Details
    Navigator.pop(context, true); // Back to Home/Search and passing cooked state
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.lang == AppLang.ar;
    final currentStep = _steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isAr ? 'وضع التركيز' : 'Focus Cooking Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded, 
              color: _isPlaying ? Colors.redAccent : AppTheme.primary,
              size: _isPlaying ? 30 : 26,
            ),
            onPressed: () async {
              if (_isPlaying) {
                await flutterTts.stop();
              } else {
                await flutterTts.speak(_steps[_currentStepIndex]);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'الخطوة ${_currentStepIndex + 1} من ${_steps.length}' : 'Step ${_currentStepIndex + 1} of ${_steps.length}',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentStepIndex + 1) / _steps.length,
                        backgroundColor: Colors.white10,
                        color: AppTheme.primary,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Step Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey<int>(_currentStepIndex),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    currentStep,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Navigation Controls
              Row(
                children: [
                  if (_currentStepIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isAr ? 'السابق' : 'Previous', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (_currentStepIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _currentStepIndex == _steps.length - 1 
                          ? (isAr ? 'إنهاء' : 'Finish') 
                          : (isAr ? 'التالي' : 'Next'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
