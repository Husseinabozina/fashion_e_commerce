import 'package:fashion_e_commerce/features/brands/data/datasources/brands_data_source.dart';
import 'package:fashion_e_commerce/features/brands/domain/entities/brand.dart';

class InMemoryBrandsDataSource implements BrandsDataSource {
  static const List<Brand> _brands = <Brand>[
    Brand(
      id: 'new-balance',
      name: 'NEW BALANCE',
      tagline: 'GREY DAYS. FUTURE FORWARD.',
      description:
          'Performance roots, everyday comfort and layered street silhouettes.',
    ),
    Brand(
      id: 'nike',
      name: 'NIKE',
      tagline: 'MOVE DIFFERENT.',
      description:
          'Sport-driven design translated into everyday street rotation.',
    ),
    Brand(
      id: 'nova-select',
      name: 'NOVA SELECT',
      tagline: 'CURATED FOR THE ROTATION.',
      description:
          'A tight edit of street essentials, utility layers and daily footwear.',
    ),
  ];

  final Set<String> _following = <String>{};

  @override
  Future<Brand> readByName(String name) async {
    final normalized = name.trim().toUpperCase();

    return _brands.firstWhere(
      (brand) => brand.name == normalized,
      orElse: () => Brand(
        id: normalized.toLowerCase().replaceAll(' ', '-'),
        name: normalized,
        tagline: 'BUILT FOR YOUR ROTATION.',
        description:
            'A curated brand page with products currently available in NOVA.',
      ),
    );
  }

  @override
  Future<List<Brand>> readFollowing() async {
    return _brands
        .where((brand) => _following.contains(brand.id))
        .toList(growable: false);
  }

  @override
  Future<bool> isFollowing(String brandId) async {
    return _following.contains(brandId);
  }

  @override
  Future<bool> toggleFollow(String brandId) async {
    if (!_following.add(brandId)) {
      _following.remove(brandId);
      return false;
    }

    return true;
  }
}
