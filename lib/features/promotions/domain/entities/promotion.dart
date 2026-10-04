enum DiscountType {
  percentage,
  fixed,
}

class Promotion {
  const Promotion({
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    this.minimumSubtotal = 0,
    this.maximumDiscount,
  });

  final String code;
  final String title;
  final DiscountType type;
  final double value;
  final double minimumSubtotal;
  final double? maximumDiscount;

  double discountFor(double subtotal) {
    if (subtotal < minimumSubtotal) return 0;

    final rawDiscount = switch (type) {
      DiscountType.percentage => subtotal * (value / 100),
      DiscountType.fixed => value,
    };

    final capped = maximumDiscount == null
        ? rawDiscount
        : rawDiscount.clamp(0, maximumDiscount!).toDouble();

    return capped.clamp(0, subtotal).toDouble();
  }
}
