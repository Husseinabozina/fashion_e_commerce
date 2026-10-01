import 'package:flutter/material.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';

/// Leaves a form open when a network write fails, so the user can retry.
Future<T?> accountAction<T>(
    BuildContext context, Future<T> Function() action) async {
  try {
    return await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        AppStrings.of(context).isArabic
            ? 'تعذّر حفظ التغيير. تأكد من الاتصال وحاول تاني.'
            : 'Could not save the change. Check your connection and try again.',
      )));
    }
    return null;
  }
}
