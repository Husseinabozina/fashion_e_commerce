import 'package:fashion_e_commerce/core/config/app_theme.dart';
import 'package:fashion_e_commerce/core/config/app_icons.dart';
import 'package:fashion_e_commerce/core/localization/app_strings.dart';
import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/presentation/cubit/addresses_cubit.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.addresses.toUpperCase()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddress(context),
        icon: Icon(AppIcons.plus),
        label: Text(strings.isArabic ? 'إضافة عنوان' : 'ADD ADDRESS'),
      ),
      body: BlocBuilder<AddressesCubit, AddressesState>(
        builder: (context, state) {
          return switch (state) {
            AddressesLoading() => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.nearBlack,
                ),
              ),
            AddressesFailure(:final message) =>
              Center(child: Text(message)),
            AddressesLoaded(:final items) when items.isEmpty =>
              Center(
                child: Text(
                  strings.isArabic
                      ? 'لا توجد عناوين محفوظة.'
                      : 'NO SAVED ADDRESSES.',
                  style: AppTheme.displayFor(context, fontSize: 28),
                ),
              ),
            AddressesLoaded(:final items) =>
              _AddressList(items: items),
          };
        },
      ),
    );
  }

  void _showAddAddress(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AddressesCubit>(),
        child: const _AddAddressSheet(),
      ),
    );
  }
}

class _AddressList extends StatelessWidget {
  const _AddressList({required this.items});

  final List<SavedAddress> items;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: item.isDefault
                  ? AppColors.nearBlack
                  : AppColors.concrete,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    item.label.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  if (item.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      color: AppColors.acidLime,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      child: Text(
                        strings.isArabic ? 'افتراضي' : 'DEFAULT',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context.read<AddressesCubit>().remove(item.id);
                    },
                    icon: Icon(AppIcons.trash),
                  ),
                ],
              ),
              Text(item.address.fullName),
              const SizedBox(height: 3),
              Text(
                item.address.compactLabel,
                style: const TextStyle(color: AppColors.midGray),
              ),
              const SizedBox(height: 3),
              Text(
                item.address.phone,
                style: const TextStyle(color: AppColors.midGray),
              ),
              if (!item.isDefault) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context.read<AddressesCubit>().setDefault(item.id);
                  },
                  child: Text(
                    strings.isArabic
                        ? 'اجعله الافتراضي'
                        : 'SET AS DEFAULT',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _label = TextEditingController(text: 'Home');
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _area = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
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
    final strings = AppStrings.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _label,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'اسم العنوان' : 'LABEL',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText:
                      strings.isArabic ? 'الاسم الكامل' : 'FULL NAME',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'رقم الهاتف' : 'PHONE',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _city,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'المدينة' : 'CITY',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _area,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'المنطقة' : 'AREA',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _street,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'الشارع' : 'STREET',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _building,
                decoration: InputDecoration(
                  labelText: strings.isArabic ? 'المبنى' : 'BUILDING',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    if (_name.text.trim().isEmpty ||
                        _phone.text.trim().isEmpty ||
                        _city.text.trim().isEmpty ||
                        _street.text.trim().isEmpty) {
                      return;
                    }

                    await context.read<AddressesCubit>().add(
                          label: _label.text.trim().isEmpty
                              ? 'Address'
                              : _label.text.trim(),
                          address: ShippingAddress(
                            fullName: _name.text.trim(),
                            phone: _phone.text.trim(),
                            city: _city.text.trim(),
                            area: _area.text.trim(),
                            street: _street.text.trim(),
                            building: _building.text.trim(),
                          ),
                        );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    strings.isArabic ? 'حفظ العنوان' : 'SAVE ADDRESS',
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
