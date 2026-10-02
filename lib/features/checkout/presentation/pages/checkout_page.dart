import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/routing/routes.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/delivery_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/payment_option.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/order_receipt.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:fashion_e_commerce/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sandbox_payment_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return switch (state) {
          CheckoutLoading() => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            ),
          CheckoutFailure(:final message) => Scaffold(
              appBar: AppBar(),
              body: Center(
                  child: Text(AppStrings.of(context).checkoutFailure(message))),
            ),
          CheckoutCompleted(:final receipt, :final cartCleared) =>
            _OrderSuccessPage(receipt: receipt, cartCleared: cartCleared),
          CheckoutReady() => _CheckoutFlow(state: state),
          CheckoutPaymentPending() => SandboxPaymentPage(state: state),
        };
      },
    );
  }
}

class _CheckoutFlow extends StatelessWidget {
  const _CheckoutFlow({required this.state});

  final CheckoutReady state;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !state.isSubmitting && state.step == CheckoutStep.address,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.isSubmitting) {
          context.read<CheckoutCubit>().goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: state.isSubmitting
                ? null
                : state.step == CheckoutStep.address
                    ? Navigator.of(context).pop
                    : context.read<CheckoutCubit>().goBack,
            icon: Icon(AppIcons.arrowLeft),
          ),
          title: Text(AppStrings.of(context).checkout.toUpperCase()),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _CheckoutProgress(step: state.step),
              const Divider(height: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (state.step) {
                    CheckoutStep.address => _AddressStep(
                        key: const ValueKey<String>('address'),
                        initialAddress: state.address,
                      ),
                    CheckoutStep.delivery => _DeliveryStep(
                        key: const ValueKey<String>('delivery'),
                        state: state,
                      ),
                    CheckoutStep.payment => _PaymentStep(
                        key: const ValueKey<String>('payment'),
                        state: state,
                      ),
                    CheckoutStep.review => _ReviewStep(
                        key: const ValueKey<String>('review'),
                        state: state,
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutProgress extends StatelessWidget {
  const _CheckoutProgress({required this.step});

  final CheckoutStep step;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final labels = <String>[
      strings.address,
      strings.delivery,
      strings.payment,
      strings.review,
    ];
    final current = step.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index <= current;

          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3,
                  color: active ? AppColors.acidLime : AppColors.concrete,
                ),
                const SizedBox(height: 7),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: active ? AppColors.nearBlack : AppColors.midGray,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AddressStep extends StatefulWidget {
  const _AddressStep({
    required this.initialAddress,
    super.key,
  });

  final ShippingAddress? initialAddress;

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _area;
  late final TextEditingController _street;
  late final TextEditingController _building;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    _name = TextEditingController(text: address?.fullName ?? '');
    _phone = TextEditingController(text: address?.phone ?? '');
    _city = TextEditingController(text: address?.city ?? '');
    _area = TextEditingController(text: address?.area ?? '');
    _street = TextEditingController(text: address?.street ?? '');
    _building = TextEditingController(text: address?.building ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _area.dispose();
    _street.dispose();
    _building.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(
            AppStrings.of(context).isArabic
                ? 'إلى أين\nنرسل الطلب؟'
                : 'WHERE SHOULD\nWE SEND IT?',
            style: AppTheme.displayFor(context, fontSize: 34),
          ),
          const SizedBox(height: 20),
          _CheckoutField(
            controller: _name,
            label:
                AppStrings.of(context).isArabic ? 'الاسم الكامل' : 'FULL NAME',
          ),
          _CheckoutField(
            controller: _phone,
            label: AppStrings.of(context).isArabic ? 'رقم الهاتف' : 'PHONE',
            keyboardType: TextInputType.phone,
          ),
          Row(
            children: [
              Expanded(
                child: _CheckoutField(
                  controller: _city,
                  label: AppStrings.of(context).isArabic ? 'المدينة' : 'CITY',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CheckoutField(
                  controller: _area,
                  label: AppStrings.of(context).isArabic ? 'المنطقة' : 'AREA',
                ),
              ),
            ],
          ),
          _CheckoutField(
            controller: _street,
            label: AppStrings.of(context).isArabic ? 'الشارع' : 'STREET',
          ),
          _CheckoutField(
            controller: _building,
            label: AppStrings.of(context).isArabic ? 'المبنى' : 'BUILDING',
          ),
          const SizedBox(height: 8),
          _PrimaryCheckoutButton(
            label: AppStrings.of(context).isArabic
                ? 'متابعة إلى التوصيل  ←'
                : 'CONTINUE TO DELIVERY  →',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              FocusScope.of(context).unfocus();

              context.read<CheckoutCubit>().saveAddress(
                    ShippingAddress(
                      fullName: _name.text.trim(),
                      phone: _phone.text.trim(),
                      city: _city.text.trim(),
                      area: _area.text.trim(),
                      street: _street.text.trim(),
                      building: _building.text.trim(),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: ValueKey<String>(label),
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.of(context).isArabic ? 'مطلوب' : 'Required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({
    required this.state,
    super.key,
  });

  final CheckoutReady state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          AppStrings.of(context).isArabic
              ? 'اختر سرعة\nالتوصيل.'
              : 'CHOOSE YOUR\nDELIVERY SPEED.',
          style: AppTheme.displayFor(context, fontSize: 34),
        ),
        const SizedBox(height: 20),
        ...state.options.deliveryOptions.map(
          (option) => _DeliveryCard(option: option),
        ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.option});

  final DeliveryOption option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.read<CheckoutCubit>().selectDelivery(option),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.concrete),
          ),
          child: Row(
            children: [
              Icon(AppIcons.delivery),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.of(context)
                          .deliveryTitle(option.title)
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppStrings.of(context).deliveryEta(option.eta),
                      style: const TextStyle(color: AppColors.midGray),
                    ),
                  ],
                ),
              ),
              Text(
                option.price == 0
                    ? (AppStrings.of(context).isArabic ? 'مجاني' : 'FREE')
                    : '${option.price.toStringAsFixed(0)} EGP',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.state,
    super.key,
  });

  final CheckoutReady state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          AppStrings.of(context).isArabic
              ? 'كيف تريد\nالدفع؟'
              : 'HOW DO YOU\nWANT TO PAY?',
          style: AppTheme.displayFor(context, fontSize: 34),
        ),
        const SizedBox(height: 20),
        ...state.options.paymentOptions.map(
          (option) => _PaymentCard(option: option),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.option});

  final PaymentOption option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.read<CheckoutCubit>().selectPayment(option),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.concrete),
          ),
          child: Row(
            children: [
              Icon(AppIcons.payment),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.of(context)
                          .paymentTitle(option.title)
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppStrings.of(context).paymentSubtitle(option.subtitle),
                      style: const TextStyle(color: AppColors.midGray),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.arrowRight),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.state,
    super.key,
  });

  final CheckoutReady state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          AppStrings.of(context).isArabic
              ? 'المراجعة النهائية.'
              : 'FINAL CHECK.',
          style: AppTheme.displayFor(context, fontSize: 34),
        ),
        const SizedBox(height: 18),
        _ReviewBlock(
          title: AppStrings.of(context).isArabic ? 'التوصيل إلى' : 'SHIP TO',
          value:
              '${state.address!.fullName}\n${state.address!.compactLabel}\n${state.address!.phone}',
        ),
        _ReviewBlock(
          title: AppStrings.of(context).delivery.toUpperCase(),
          value:
              '${AppStrings.of(context).deliveryTitle(state.delivery!.title)}\n${AppStrings.of(context).deliveryEta(state.delivery!.eta)}',
        ),
        _ReviewBlock(
          title: AppStrings.of(context).payment.toUpperCase(),
          value: AppStrings.of(context).paymentTitle(state.payment!.title),
        ),
        const Divider(height: 32),
        _ReviewPriceRow(
          label: AppStrings.of(context).subtotal.toUpperCase(),
          value: '${state.subtotal.toStringAsFixed(0)} EGP',
        ),
        if (state.discount > 0) ...[
          const SizedBox(height: 8),
          _ReviewPriceRow(
            label: AppStrings.of(context).isArabic
                ? 'الخصم · ${state.promotion!.code}'
                : 'DISCOUNT · ${state.promotion!.code}',
            value: '-${state.discount.toStringAsFixed(0)} EGP',
          ),
        ],
        const SizedBox(height: 8),
        _ReviewPriceRow(
          label: AppStrings.of(context).delivery.toUpperCase(),
          value: state.delivery!.price == 0
              ? AppStrings.of(context).free
              : '${state.delivery!.price.toStringAsFixed(0)} EGP',
        ),
        const Divider(height: 32),
        _ReviewPriceRow(
          label: AppStrings.of(context).total.toUpperCase(),
          value: '${state.total.toStringAsFixed(0)} EGP',
          emphasized: true,
        ),
        const SizedBox(height: 20),
        if (state.hasSubmissionError) ...[
          Text(
            AppStrings.of(context).orderRetry,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        _PrimaryCheckoutButton(
          label: state.isSubmitting
              ? (AppStrings.of(context).isArabic
                  ? 'جارٍ تأكيد الطلب...'
                  : 'PLACING ORDER...')
              : state.payment!.id == 'card'
                  ? (AppStrings.of(context).isArabic
                      ? 'المتابعة للدفع التجريبي'
                      : 'CONTINUE TO TEST PAYMENT')
                  : AppStrings.of(context).placeOrder,
          onPressed: state.isSubmitting
              ? null
              : context.read<CheckoutCubit>().submitOrder,
        ),
      ],
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  const _ReviewBlock({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

class _ReviewPriceRow extends StatelessWidget {
  const _ReviewPriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value,
            style: style,
            textDirection: value.contains('EGP') ? TextDirection.ltr : null),
      ],
    );
  }
}

class _PrimaryCheckoutButton extends StatelessWidget {
  const _PrimaryCheckoutButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minHeight: 52, minWidth: double.infinity),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.acidLime,
          foregroundColor: AppColors.nearBlack,
          disabledBackgroundColor: AppColors.concrete,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _OrderSuccessPage extends StatelessWidget {
  const _OrderSuccessPage({required this.receipt, required this.cartCleared});

  final OrderReceipt receipt;
  final bool cartCleared;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.home, (route) => false);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.nearBlack,
          body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Spacer(),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.7, end: 1),
                                  duration: const Duration(milliseconds: 420),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 74,
                                    height: 74,
                                    decoration: const BoxDecoration(
                                      color: AppColors.acidLime,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      AppIcons.check,
                                      textDirection: TextDirection.ltr,
                                      size: 44,
                                      color: AppColors.nearBlack,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  AppStrings.of(context).orderPlaced,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.displayFor(
                                    context,
                                    fontSize: 48,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '#${receipt.orderId}',
                                  textDirection: TextDirection.ltr,
                                  style: const TextStyle(
                                    color: AppColors.concrete,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (receipt.sandboxPayment != null) ...[
                                  Text(
                                      AppStrings.of(context).isArabic
                                          ? 'تم التحقق من دفع تجريبي: 1 د.ك'
                                          : 'Sandbox payment verified: 1 KWD',
                                      style: const TextStyle(
                                          color: AppColors.acidLime)),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  '${AppStrings.of(context).total} ${receipt.total.toStringAsFixed(0)} EGP · ${AppStrings.of(context).deliveryEta(receipt.deliveryEta)}',
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                ),
                                const Spacer(),
                                if (!cartCleared) ...[
                                  Text(AppStrings.of(context).cartCleanupFailed,
                                      style: const TextStyle(
                                          color: AppColors.white)),
                                  const SizedBox(height: 12),
                                ],
                                _PrimaryCheckoutButton(
                                  label: AppStrings.of(context).viewOrder,
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      Routes.orderDetails,
                                      ModalRoute.withName(Routes.home),
                                      arguments: receipt.orderId,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      Routes.home,
                                      (route) => false,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.white,
                                    side: const BorderSide(
                                        color: AppColors.white),
                                  ),
                                  child: Text(AppStrings.of(context).backHome),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}
