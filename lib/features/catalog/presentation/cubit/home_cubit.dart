import 'package:fashion_e_commerce/features/catalog/domain/entities/home_catalog.dart';
import 'package:fashion_e_commerce/features/catalog/domain/usecases/get_home_catalog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.catalog);

  final HomeCatalog catalog;
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeCatalog) : super(const HomeInitial());

  final GetHomeCatalog _getHomeCatalog;

  Future<void> load() async {
    emit(const HomeLoading());

    try {
      final catalog = await _getHomeCatalog();
      emit(HomeLoaded(catalog));
    } catch (_) {
      emit(
        const HomeFailure(
          'We could not load the drop. Check your connection and try again.',
        ),
      );
    }
  }
}
