import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthCubit>().state is AuthLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Text(
                AppStrings.of(context).isArabic
                    ? 'جرّب\nحسابك.'
                    : 'YOUR ACCOUNT.\nYOUR ROTATION.',
                style: AppTheme.displayFor(context, fontSize: 39),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.of(context).isArabic
                    ? 'تسجيل دخول تجريبي. البيانات محفوظة خلال الجلسة الحالية فقط.'
                    : 'Demo sign-in. Your data is kept for this session only.',
                style: const TextStyle(
                  color: AppColors.midGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
                    return AppStrings.of(context).invalidEmail;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: AppStrings.of(context).isArabic
                      ? 'البريد الإلكتروني'
                      : 'EMAIL',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                autocorrect: false,
                validator: (value) {
                  if ((value ?? '').length < 4) {
                    return AppStrings.of(context).invalidPassword;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: AppStrings.of(context).isArabic
                      ? 'كلمة المرور'
                      : 'PASSWORD',
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          FocusScope.of(context).unfocus();
                          final signedIn =
                              await context.read<AuthCubit>().signIn(
                                    email: _email.text,
                                    password: _password.text,
                                  );

                          if (!context.mounted) return;
                          if (signedIn) {
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(AppStrings.of(context).signInFailed)));
                          }
                        },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      loading
                          ? (AppStrings.of(context).isArabic
                              ? 'جارٍ تسجيل الدخول...'
                              : 'SIGNING IN...')
                          : AppStrings.of(context).signIn + '  →',
                      key: ValueKey<bool>(loading),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
