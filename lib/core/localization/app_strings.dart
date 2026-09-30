import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._(this.isArabic);

  final bool isArabic;

  factory AppStrings.of(BuildContext context) {
    return AppStrings._(
      Localizations.localeOf(context).languageCode == 'ar',
    );
  }

  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get shop => isArabic ? 'تسوق' : 'Shop';
  String get discover => isArabic ? 'اكتشف' : 'Discover';
  String get saved => isArabic ? 'المحفوظات' : 'Saved';
  String get account => isArabic ? 'الحساب' : 'Account';
  String get orders => isArabic ? 'الطلبات' : 'Orders';
  String get search => isArabic ? 'بحث' : 'Search';

  String get searchHint => isArabic
      ? 'ابحث عن منتجات أو علامات أو فئات...'
      : 'Search products, brands, categories...';
  String get newArrivals => isArabic ? 'وصل حديثًا' : 'NEW ARRIVALS';
  String get shopByCategory => isArabic ? 'تسوق حسب الفئة' : 'SHOP BY CATEGORY';
  String get view => isArabic ? 'عرض' : 'VIEW';
  String get streetEdit => isArabic ? 'اختيارات الشارع' : 'STREET EDIT';
  String get noRules => isArabic ? 'بدون قواعد.\nاختيارك أنت.' : 'NO RULES.\nJUST ROTATION.';
  String get discoverEdit => isArabic ? 'اكتشف المجموعة' : 'DISCOVER THE EDIT';

  String get selectSize => isArabic ? 'اختر المقاس' : 'SELECT SIZE';
  String get sizeGuide => isArabic ? 'دليل المقاسات' : 'SIZE GUIDE';
  String get addToBag => isArabic ? 'أضف إلى الحقيبة' : 'ADD TO BAG  →';
  String get selectASize => isArabic ? 'اختر مقاسًا' : 'SELECT A SIZE';
  String get color => isArabic ? 'اللون' : 'COLOR';
  String get fit => isArabic ? 'القَصّة' : 'FIT';
  String get freeDelivery => isArabic ? 'توصيل مجاني' : 'FREE DELIVERY';
  String get easyReturns => isArabic ? 'إرجاع سهل' : 'EASY RETURNS';
  String get viewBag => isArabic ? 'عرض الحقيبة' : 'VIEW BAG';

  String get yourBag => isArabic ? 'حقيبتك' : 'YOUR BAG';
  String get subtotal => isArabic ? 'المجموع الفرعي' : 'SUBTOTAL';
  String get delivery => isArabic ? 'التوصيل' : 'DELIVERY';
  String get total => isArabic ? 'الإجمالي' : 'TOTAL';
  String get checkout => isArabic ? 'إتمام الشراء' : 'CHECKOUT';
  String get emptyBag => isArabic ? 'حقيبتك فارغة' : 'YOUR BAG IS EMPTY';
  String get keepShopping => isArabic ? 'تابع التسوق' : 'KEEP SHOPPING';

  String get address => isArabic ? 'العنوان' : 'ADDRESS';
  String get payment => isArabic ? 'الدفع' : 'PAYMENT';
  String get review => isArabic ? 'المراجعة' : 'REVIEW';
  String get placeOrder => isArabic ? 'تأكيد الطلب' : 'PLACE ORDER  →';
  String get orderPlaced => isArabic ? 'تم\nتأكيد الطلب.' : 'ORDER\nPLACED.';
  String get viewOrder => isArabic ? 'عرض الطلب' : 'VIEW ORDER  →';
  String get backHome => isArabic ? 'العودة للرئيسية' : 'BACK TO HOME';

  String get orderDetails => isArabic ? 'تفاصيل الطلب' : 'ORDER DETAILS';
  String get tracking => isArabic ? 'تتبع الطلب' : 'TRACKING';
  String get items => isArabic ? 'المنتجات' : 'ITEMS';
  String get returnLabel => isArabic ? 'إرجاع' : 'RETURN';
  String get returnExchange => isArabic ? 'إرجاع /\nاستبدال' : 'RETURN /\nEXCHANGE';
  String get exchangeSize => isArabic ? 'تبديل المقاس' : 'EXCHANGE SIZE';
  String get reason => isArabic ? 'السبب' : 'REASON';
  String get newSize => isArabic ? 'المقاس الجديد' : 'NEW SIZE';
  String get submitRequest => isArabic ? 'إرسال الطلب' : 'SUBMIT REQUEST';

  String get guestMode => isArabic ? 'وضع\nالضيف.' : 'GUEST\nMODE.';
  String get guestDescription => isArabic
      ? 'تصفح بحرية، وسجل الدخول عندما تريد مزامنة بياناتك.'
      : 'Browse freely. Sign in when you want your account synced.';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'SIGN IN';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'SIGN OUT';
  String get ordersReturns => isArabic ? 'الطلبات والإرجاع' : 'ORDERS & RETURNS';
  String get savedItems => isArabic ? 'العناصر المحفوظة' : 'SAVED ITEMS';
  String get addresses => isArabic ? 'العناوين' : 'ADDRESSES';
  String get notifications => isArabic ? 'الإشعارات' : 'NOTIFICATIONS';
  String get languageRegion => isArabic ? 'اللغة والمنطقة' : 'LANGUAGE & REGION';
  String get english => 'English';
  String get arabic => 'العربية';

  String get filters => isArabic ? 'التصفية' : 'FILTERS';
  String get sort => isArabic ? 'الترتيب' : 'SORT';
  String get clear => isArabic ? 'مسح' : 'CLEAR';
  String get category => isArabic ? 'الفئة' : 'CATEGORY';
  String get brand => isArabic ? 'العلامة التجارية' : 'BRAND';
  String get noMatch => isArabic ? 'لا توجد نتائج.' : 'NO MATCH.';
  String get tryAnother => isArabic
      ? 'جرّب كلمة أخرى أو امسح عوامل التصفية.'
      : 'Try another keyword or clear your filters.';
}
