import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ACCOUNT')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            AuthFailure(:final message) => Center(child: Text(message)),
            AuthReady(:final user) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    color: AppColors.nearBlack,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.isGuest
                              ? 'GUEST\nMODE.'
                              : 'HEY,\n' + user.name.toUpperCase() + '.',
                          style: AppTheme.display(
                            fontSize: 36,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.isGuest
                              ? 'Browse freely. Sign in when you want your account synced.'
                              : user.email,
                          style: const TextStyle(
                            color: AppColors.white,
                            height: 1.4,
                          ),
                        ),
                        if (user.isGuest) ...[
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(Routes.signIn);
                            },
                            child: const Text('SIGN IN  →'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _AccountTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'ORDERS & RETURNS',
                    onTap: () => Navigator.of(context).pushNamed(Routes.orders),
                  ),
                  _AccountTile(
                    icon: Icons.favorite_border_rounded,
                    label: 'SAVED ITEMS',
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.wishlist),
                  ),
                  const _AccountTile(
                    icon: Icons.location_on_outlined,
                    label: 'ADDRESSES',
                  ),
                  const _AccountTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'NOTIFICATIONS',
                  ),
                  const _AccountTile(
                    icon: Icons.language_rounded,
                    label: 'LANGUAGE & REGION',
                  ),
                  if (!user.isGuest) ...[
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: context.read<AuthCubit>().signOut,
                      child: const Text('SIGN OUT'),
                    ),
                  ],
                ],
              ),
          };
        },
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.concrete),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 19),
          ],
        ),
      ),
    );
  }
}
