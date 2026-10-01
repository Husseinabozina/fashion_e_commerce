import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';
import 'package:fashion_e_commerce/features/brands/domain/usecases/get_following_brands.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class FollowingBrandsState {
  const FollowingBrandsState();
}

final class FollowingBrandsLoading extends FollowingBrandsState {
  const FollowingBrandsLoading();
}

final class FollowingBrandsLoaded extends FollowingBrandsState {
  const FollowingBrandsLoaded(this.brands);

  final List<Brand> brands;
}

final class FollowingBrandsFailure extends FollowingBrandsState {
  const FollowingBrandsFailure(this.message);

  final String message;
}

class FollowingBrandsCubit extends Cubit<FollowingBrandsState> {
  FollowingBrandsCubit(this._getFollowingBrands)
      : super(const FollowingBrandsLoading());

  final GetFollowingBrands _getFollowingBrands;

  Future<void> load() async {
    emit(const FollowingBrandsLoading());

    try {
      emit(FollowingBrandsLoaded(await _getFollowingBrands()));
    } catch (_) {
      emit(const FollowingBrandsFailure('Following brands could not be loaded.'));
    }
  }
}
