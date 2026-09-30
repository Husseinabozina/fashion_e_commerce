enum ProductSort {
  recommended,
  newest,
  priceLowToHigh,
  priceHighToLow,
}

class ProductSearchCriteria {
  const ProductSearchCriteria({
    this.query = '',
    this.category,
    this.brand,
    this.sort = ProductSort.recommended,
  });

  final String query;
  final String? category;
  final String? brand;
  final ProductSort sort;

  bool get hasFilters => category != null || brand != null;
}
