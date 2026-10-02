import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/checkout_cubit.dart';

class SandboxPaymentPage extends StatefulWidget {
  const SandboxPaymentPage({required this.state, super.key});
  final CheckoutPaymentPending state;
  @override
  State<SandboxPaymentPage> createState() => _SandboxPaymentPageState();
}

class _SandboxPaymentPageState extends State<SandboxPaymentPage>
    with WidgetsBindingObserver {
  bool _opening = false;
  bool _openFailed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<CheckoutCubit>().checkPayment();
    }
  }

  Future<void> _openCheckout() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _openFailed = false;
    });
    var opened = false;
    try {
      opened = await launchUrl(widget.state.session.checkoutUrl,
          mode: LaunchMode.externalApplication);
    } catch (_) {/* Keep the pending invoice and allow another open attempt. */}
    if (mounted) {
      setState(() {
        _opening = false;
        _openFailed = !opened;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppStrings.of(context).isArabic;
    final busy = widget.state.isChecking || _opening;
    final message = switch (widget.state.message) {
      'pending' => ar
          ? 'الدفع لم يكتمل بعد. افتح صفحة الدفع أو تحقق مرة أخرى.'
          : 'Payment is not complete yet. Open checkout or check again.',
      'declined' => ar
          ? 'المحاولة اترفضت. تقدر تفتح نفس صفحة الدفع وتجرب كارت الاختبار مرة أخرى.'
          : 'The attempt was declined. Reopen checkout and try the test card again.',
      'cancelled' => ar
          ? 'الفاتورة اتلغت. ارجع للمراجعة وابدأ محاولة جديدة.'
          : 'This invoice was cancelled. Return to review and start again.',
      'error' => ar
          ? 'تعذر التحقق من النتيجة. طلبك لم يتأكد والسلة محفوظة. حاول مرة أخرى.'
          : 'Could not verify payment. Your order is not confirmed and your bag is safe. Check again.',
      'saveError' => ar
          ? 'الدفع التجريبي نجح، لكن حفظ الطلب لم يكتمل. تحقق مرة أخرى لإعادة الحفظ.'
          : 'The test payment succeeded, but saving the order failed. Check again to retry saving.',
      _ => ar
          ? 'افتح صفحة الدفع، وبعد ما تخلص ارجع للتطبيق للتحقق من النتيجة.'
          : 'Open checkout, then return to NOVA to verify the result.',
    };
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) context.read<CheckoutCubit>().leavePayment();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ar ? 'دفع تجريبي' : 'TEST PAYMENT'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  busy ? null : context.read<CheckoutCubit>().leavePayment),
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('MyFatoorah',
                style: AppTheme.displayFor(context, fontSize: 36)),
            const SizedBox(height: 16),
            Text(
                ar
                    ? 'مبلغ الاختبار: 1 د.ك — من غير خصم فلوس حقيقية.'
                    : 'Test amount: 1 KWD — no real money is charged.',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ar
                ? 'ده مبلغ افتراضي ثابت للتجربة، مش تحويل لإجمالي طلبك بالجنيه.'
                : 'This is a fixed virtual test amount, not a conversion of your EGP order total.'),
            const SizedBox(height: 20),
            Text(message, key: const Key('sandbox-payment-message')),
            const SizedBox(height: 20),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            ar
                                ? 'استخدم كارت الاختبار ده فقط'
                                : 'Use this test card only',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const SelectableText('5123450000000008',
                            textDirection: TextDirection.ltr),
                        const Text('01/39  ·  CVV: 100  ·  Test User',
                            textDirection: TextDirection.ltr),
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                                const ClipboardData(text: '5123450000000008'));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(ar
                                          ? 'تم نسخ كارت الاختبار'
                                          : 'Test card copied')));
                            }
                          },
                          icon: const Icon(Icons.copy),
                          label: Text(ar ? 'نسخ رقم الكارت' : 'Copy test card'),
                        ),
                      ],
                    ))),
            const SizedBox(height: 20),
            if (_openFailed)
              Text(ar
                  ? 'تعذر فتح المتصفح. حاول مرة أخرى.'
                  : 'Could not open the browser. Try again.'),
            FilledButton(
                key: const Key('open-sandbox-checkout'),
                onPressed: busy || widget.state.message == 'cancelled'
                    ? null
                    : _openCheckout,
                child: Text(
                    ar ? 'فتح صفحة الدفع التجريبي' : 'Open test checkout')),
            const SizedBox(height: 12),
            OutlinedButton(
                key: const Key('check-sandbox-payment'),
                onPressed:
                    busy ? null : context.read<CheckoutCubit>().checkPayment,
                child: Text(widget.state.isChecking
                    ? (ar ? 'جارٍ التحقق...' : 'Checking...')
                    : (ar ? 'تحقق من نتيجة الدفع' : 'Check payment result'))),
            TextButton(
                onPressed:
                    busy ? null : context.read<CheckoutCubit>().leavePayment,
                child: Text(ar ? 'الرجوع للمراجعة' : 'Return to review')),
          ],
        )),
      ),
    );
  }
}
