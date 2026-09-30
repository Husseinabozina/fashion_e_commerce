import 'package:fashion_e_commerce/features/catalog/domain/entities/product.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/usecases/get_recently_viewed.dart';
import 'package:fashion_e_commerce/features/recently_viewed/domain/usecases/track_recently_viewed.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class RecentlyViewedState {
  const RecentlyViewedState();
}

final class RecentlyViewedLoading extends RecentlyViewedState {
  const RecentlyViewedLoading();
}

final class RecentlyViewedLoaded extends RecentlyViewedState {
  const RecentlyViewedLoaded(this.items);

  final List<Product> items;
}

class RecentlyViewedCubit extends Cubit<RecentlyViewedState> {
  RecentlyViewedCubit(
    this._getRecentlyViewed,
    this._trackRecentlyViewed,
  ) : super(const RecentlyViewedLoading());

  final GetRecentlyViewed _getRecentlyViewed;
  final TrackRecentlyViewed _trackRecentlyViewed;

  Future<void> load() async {
    emit(RecentlyViewedLoaded(await _getRecentlyViewed()));
  }

  Future<void> track(Product product) async {
    emit(RecentlyViewedLoaded(await _trackRecentlyViewed(product)));
  }
}
