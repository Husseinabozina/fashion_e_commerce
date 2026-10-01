import 'package:flutter/material.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';

class RetryPanel extends StatelessWidget {
  const RetryPanel({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final arabic = AppStrings.of(context).isArabic;
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    arabic
                        ? 'تعذّر تحميل البيانات. تأكد من الاتصال.'
                        : 'Could not load your data. Check your connection.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: onRetry,
                    child: Text(arabic ? 'حاول تاني' : 'Try again')),
              ],
            )));
  }
}
