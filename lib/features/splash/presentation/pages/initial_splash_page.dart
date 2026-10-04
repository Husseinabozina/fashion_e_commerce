import 'package:fashion_e_commerce/core/branding/nova_launch_view.dart';
import 'package:fashion_e_commerce/core/config/app_constants.dart';
import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/di/service_locator.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/entities/shopping_preferences.dart';
import 'package:fashion_e_commerce/features/onboarding/domain/usecases/get_shopping_preferences.dart';
import 'package:flutter/material.dart';

class InitialSplashPage extends StatefulWidget {
  const InitialSplashPage({super.key, this.loadPreferences});
  final Future<ShoppingPreferences> Function()? loadPreferences;

  @override
  State<InitialSplashPage> createState() => _InitialSplashPageState();
}

class _InitialSplashPageState extends State<InitialSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: AppConstants.initialSplashDuration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigateWhenReady();
    });
  bool _started = false;
  bool _failed = false;
  bool _loading = false;
  bool _navigationScheduled = false;
  String? _destination;

  @override
  void initState() {
    super.initState();
    _readPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
      _started = true;
      _navigateWhenReady();
    } else if (!_started) {
      _started = true;
      _animation.forward();
    }
  }

  Future<void> _readPreferences() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final preferences = await (widget.loadPreferences?.call() ??
          serviceLocator<GetShoppingPreferences>()());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _destination = preferences.hasCompletedOnboarding
            ? Routes.home
            : Routes.onboarding;
      });
      _navigateWhenReady();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  void _navigateWhenReady() {
    if (!mounted ||
        _destination == null ||
        !_animation.isCompleted ||
        _failed ||
        _navigationScheduled) {
      return;
    }
    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(_destination!, (_) => false);
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => NovaLaunchView(
        progress: _animation.value,
        footer: _failed
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                    arabic
                        ? 'تعذر تحميل تفضيلاتك. حاول مرة أخرى.'
                        : 'Could not load your preferences. Please try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.offWhite, fontSize: 13)),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: _readPreferences,
                    child: Text(arabic ? 'حاول مرة أخرى' : 'Try again')),
              ])
            : _loading && _animation.isCompleted
                ? Semantics(
                    liveRegion: true,
                    child: Text(
                        arabic
                            ? 'جارٍ تجهيز اختياراتك…'
                            : 'Preparing your edit…',
                        style: const TextStyle(
                            color: AppColors.concrete, fontSize: 12)))
                : null,
      ),
    );
  }
}
