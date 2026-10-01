import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/localization/locale_cubit.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const List<String> _interests = <String>[
    'Sneakers',
    'Hoodies',
    'Jackets',
    'T-Shirts',
    'Bags',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final isArabic = locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.nearBlack,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.92, end: 1),
                    duration: const Duration(milliseconds: 480),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          alignment: AlignmentDirectional.topStart,
                          child: child,
                        ),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        isArabic ? 'ابني\nستايلك.' : 'BUILD YOUR\nROTATION.',
                        softWrap: false,
                        style: AppTheme.displayFor(
                          context,
                          fontSize: 48,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic
                        ? 'اختيارات قليلة تساعد NOVA ترتب المنتجات الأقرب لذوقك.'
                        : 'A few choices help NOVA surface the products closest to your style.',
                    style: const TextStyle(
                      color: AppColors.white,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    isArabic ? 'اللغة' : 'LANGUAGE',
                    style: const TextStyle(
                      color: AppColors.concrete,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('English'),
                          selected: !isArabic,
                          showCheckmark: false,
                          onSelected: (_) {
                            context.read<LocaleCubit>().useEnglish();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('العربية'),
                          selected: isArabic,
                          showCheckmark: false,
                          onSelected: (_) {
                            context.read<LocaleCubit>().useArabic();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    isArabic ? 'إيه اللي بتهتم بيه؟' : 'WHAT ARE YOU INTO?',
                    style: const TextStyle(
                      color: AppColors.concrete,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: _interests.map((interest) {
                      final selected = state.interests.contains(interest);
                      return FilterChip(
                        label:
                            Text(AppStrings.of(context).categoryName(interest)),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          context
                              .read<OnboardingCubit>()
                              .toggleInterest(interest);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 34),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: FilledButton(
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              await context.read<OnboardingCubit>().complete();
                              if (!context.mounted) return;

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.home,
                                (route) => false,
                              );
                            },
                      child: Text(
                        state.isSaving
                            ? (isArabic ? 'جارٍ الحفظ...' : 'SAVING...')
                            : (isArabic
                                ? 'ابدأ التسوق  ←'
                                : 'START SHOPPING  →'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            await context.read<OnboardingCubit>().skip();
                            if (!context.mounted) return;

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.home,
                              (route) => false,
                            );
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(
                      isArabic ? 'تخطي الآن' : 'SKIP FOR NOW',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
