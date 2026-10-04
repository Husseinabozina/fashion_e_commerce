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
  bool _creating = false;
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>();
    final loading = auth.state is AuthLoading;
    final strings = AppStrings.of(context);

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
                    ? (_creating
                        ? 'إنشاء\nحساب.'
                        : (auth.isDemo
                            ? 'جرّب\nحسابك.'
                            : 'حسابك.\nواختياراتك.'))
                    : (_creating
                        ? 'CREATE YOUR\nACCOUNT.'
                        : 'YOUR ACCOUNT.\nYOUR ROTATION.'),
                style: AppTheme.displayFor(context, fontSize: 39),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.of(context).isArabic
                    ? (auth.isDemo
                        ? 'تسجيل دخول تجريبي. البيانات محفوظة خلال الجلسة الحالية فقط.'
                        : 'محفوظاتك وعناوينك وطلباتك مرتبطة بحسابك.')
                    : (auth.isDemo
                        ? 'Demo sign-in. Your data is kept for this session only.'
                        : 'Your saved items, addresses and orders stay with your account.'),
                style: const TextStyle(
                  color: AppColors.midGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              if (_creating) ...[
                TextFormField(
                    controller: _name,
                    enabled: !loading,
                    maxLength: 80,
                    decoration: InputDecoration(
                        labelText: strings.isArabic ? 'الاسم' : 'NAME'),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? strings.requiredField
                        : null),
                const SizedBox(height: 12),
              ],
              TextFormField(
                enabled: !loading,
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
                enabled: !loading,
                controller: _password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                autocorrect: false,
                validator: (value) {
                  if ((value ?? '').length < (auth.isDemo ? 4 : 6)) {
                    return auth.isDemo
                        ? strings.invalidPassword
                        : (strings.isArabic
                            ? 'كلمة المرور ٦ أحرف على الأقل'
                            : 'Password must be at least 6 characters');
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
                          final signedIn = _creating
                              ? await auth.createAccount(
                                  name: _name.text,
                                  email: _email.text,
                                  password: _password.text)
                              : await auth.signIn(
                                  email: _email.text, password: _password.text);

                          if (!context.mounted) return;
                          if (signedIn) {
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(auth.state is AuthFailure
                                    ? strings.authError(
                                        (auth.state as AuthFailure).code)
                                    : strings.signInFailed)));
                          }
                        },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      loading
                          ? (AppStrings.of(context).isArabic
                              ? 'جارٍ تسجيل الدخول...'
                              : 'SIGNING IN...')
                          : (_creating
                                  ? strings.createAccount
                                  : strings.signIn) +
                              '  →',
                      key: ValueKey<bool>(loading),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => _creating = !_creating),
                  child:
                      Text(_creating ? strings.signIn : strings.createAccount)),
              if (!_creating && !auth.isDemo)
                TextButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(_email.text.trim())) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(strings.invalidEmail)));
                              return;
                            }
                            FocusScope.of(context).unfocus();
                            final sent = await auth.resetPassword(_email.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(sent
                                    ? (strings.isArabic
                                        ? 'لو البريد مرتبط بحساب، هتوصلك رسالة لاستعادة كلمة المرور.'
                                        : 'If this email has an account, you will receive a reset link.')
                                    : strings.authError(
                                        auth.state is AuthFailure
                                            ? (auth.state as AuthFailure).code
                                            : 'unknown'))));
                          },
                    child: Text(strings.resetPassword)),
            ],
          ),
        ),
      ),
    );
  }
}
