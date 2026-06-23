import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../services/language_service.dart';

import '../main_navigation_screen.dart';
import 'login_screen.dart';
import 'widgets/onboarding_design_tokens.dart';
import 'widgets/onboarding_dots_row.dart';
import 'widgets/onboarding_feature_page.dart';
import 'widgets/onboarding_ghost_button.dart';
import 'widgets/onboarding_icon_button.dart';
import 'widgets/onboarding_language_page.dart';
import 'widgets/onboarding_primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _languagePreferenceKey = 'app_language_code';

  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedLanguageCode;
  bool _savingLanguage = false;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  // 3 feature pages + 1 language page
  static const int _totalPages = 4; // 3 feature + 1 language
  int get _lastPage => _totalPages - 1;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = LanguageService.instance.locale.languageCode;
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage >= _lastPage) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _lastPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectLanguage(String code) async {
    setState(() => _selectedLanguageCode = code);
    await LanguageService.instance.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, code);
  }

  Future<void> _persistLanguageSelection() async {
    final code = _selectedLanguageCode ?? 'en';
    await LanguageService.instance.setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, code);
  }

  Future<void> _completeOnboarding() async {
    if (_selectedLanguageCode == null || _savingLanguage) return;
    setState(() => _savingLanguage = true);
    try {
      await _persistLanguageSelection();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } finally {
      if (mounted) setState(() => _savingLanguage = false);
    }
  }

  Future<void> _skipToHome() async {
    if (_savingLanguage) return;
    setState(() => _savingLanguage = true);
    try {
      await _persistLanguageSelection();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } finally {
      if (mounted) setState(() => _savingLanguage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kOnboardingBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // App name / back
                  if (_currentPage > 0)
                    OnboardingIconButton(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      onTap: _goBack,
                    )
                  else
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(
                            'assets/images/Logo_KYSC.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KY Services',
                          style: kFont(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kOnboardingTextHead,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (_currentPage > 0 && _currentPage < _lastPage)
                    TextButton(
                      onPressed: _skipToLastPage,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        backgroundColor: kOnboardingPrimaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        l.skip,
                        style: kFont(context,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: kOnboardingPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Pages ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return OnboardingLanguagePage(
                      selectedCode: _selectedLanguageCode,
                      onSelect: _selectLanguage,
                    );
                  }
                  return OnboardingFeaturePage(
                    pageIndex: index - 1,
                    floatAnim: _floatAnim,
                  );
                },
              ),
            ),

            // ── Progress dots ──────────────────────────────────────────
            OnboardingDotsRow(
              count: _totalPages,
              current: _currentPage,
            ),
            const SizedBox(height: 20),

            // ── CTA buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: _currentPage == _lastPage
                  ? Column(
                      children: [
                        OnboardingPrimaryButton(
                          label: _savingLanguage ? 'Saving…' : l.getStarted,
                          enabled: _selectedLanguageCode != null && !_savingLanguage,
                          onTap: _completeOnboarding,
                        ),
                        const SizedBox(height: 10),
                        OnboardingGhostButton(
                          label: l.skip,
                          onTap: _savingLanguage ? null : _skipToHome,
                        ),
                      ],
                    )
                  : OnboardingPrimaryButton(
                      label: l.next,
                      onTap: _goNext,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
