import 'package:fashion_e_commerce/features/addresses/domain/entities/saved_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/get_addresses.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/remove_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/save_address.dart';
import 'package:fashion_e_commerce/features/addresses/domain/usecases/set_default_address.dart';
import 'package:fashion_e_commerce/features/checkout/domain/entities/shipping_address.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AddressesState {
  const AddressesState();
}

final class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

final class AddressesLoaded extends AddressesState {
  const AddressesLoaded(this.items);

  final List<SavedAddress> items;
}

final class AddressesFailure extends AddressesState {
  const AddressesFailure(this.message);

  final String message;
}

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(
    this._getAddresses,
    this._saveAddress,
    this._removeAddress,
    this._setDefaultAddress,
  ) : super(const AddressesLoading());

  final GetAddresses _getAddresses;
  final SaveAddress _saveAddress;
  final RemoveAddress _removeAddress;
  final SetDefaultAddress _setDefaultAddress;

  Future<void> load() async {
    emit(const AddressesLoading());

    try {
      emit(AddressesLoaded(await _getAddresses()));
    } catch (_) {
      emit(const AddressesFailure('Addresses could not be loaded.'));
    }
  }

  Future<void> add({
    required String label,
    required ShippingAddress address,
  }) async {
    final item = SavedAddress(
      id: 'address-' + DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      address: address,
    );

    emit(AddressesLoaded(await _saveAddress(item)));
  }

  Future<void> remove(String id) async {
    emit(AddressesLoaded(await _removeAddress(id)));
  }

  Future<void> setDefault(String id) async {
    emit(AddressesLoaded(await _setDefaultAddress(id)));
  }
}
