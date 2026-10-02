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
  String get noRules =>
      isArabic ? 'بدون قواعد.\nاختيارك أنت.' : 'NO RULES.\nJUST ROTATION.';
  String get discoverEdit => isArabic ? 'اكتشف المجموعة' : 'DISCOVER THE EDIT';

  String get selectSize => isArabic ? 'اختر المقاس' : 'SELECT SIZE';
  String get size => isArabic ? 'المقاس' : 'Size';
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
  String get free => isArabic ? 'مجاني' : 'FREE';
  String get orderRetry => isArabic
      ? 'تعذر تأكيد الطلب. اختياراتك محفوظة، حاول مرة أخرى.'
      : 'Could not place your order. Your choices are saved. Please try again.';
  String get cartCleanupFailed => isArabic
      ? 'تم تأكيد طلبك، لكن تعذر تحديث الحقيبة. لا تكرر الطلب.'
      : 'Your order is placed, but the bag could not be updated. Do not place it again.';

  String promotionTitle(String title) => !isArabic
      ? title
      : switch (title) {
          'Street Drop 10%' => 'خصم ١٠٪ على اختيارات الشارع',
          'NOVA 500 EGP Off' => 'خصم ٥٠٠ جنيه من NOVA',
          _ => title,
        };

  String promotionMessage(String message) {
    if (!isArabic) return message;
    if (message == 'Invalid promotion code.') return 'كود الخصم غير صحيح.';
    final minimum =
        RegExp(r'^Minimum subtotal is (\d+) EGP\.$').firstMatch(message);
    if (minimum != null) {
      return 'الحد الأدنى للمجموع الفرعي ${minimum[1]} جنيه.';
    }
    if (message.endsWith(' applied.')) {
      return 'تم تطبيق ${message.replaceFirst(' applied.', '')}.';
    }
    return 'تعذر تطبيق كود الخصم. حاول مرة أخرى.';
  }

  String deliveryTitle(String title) => !isArabic
      ? title
      : switch (title) {
          'Standard Delivery' => 'توصيل عادي',
          'Express Delivery' => 'توصيل سريع',
          _ => title,
        };

  String deliveryEta(String eta) => !isArabic
      ? eta
      : switch (eta) {
          '2–4 business days' => 'من يومين إلى ٤ أيام عمل',
          'Next business day' => 'يوم العمل التالي',
          'Delivered 27 Sep' => 'تم التوصيل ٢٧ سبتمبر',
          _ => eta,
        };

  String paymentTitle(String title) => !isArabic
      ? title
      : switch (title) {
          'Card' => 'بطاقة بنكية',
          'Cash on Delivery' => 'الدفع عند الاستلام',
          'Wallet' => 'محفظة إلكترونية',
          _ => title,
        };

  String paymentSubtitle(String subtitle) => !isArabic
      ? subtitle
      : switch (subtitle) {
          'Visa · Mastercard' => 'فيزا · ماستركارد',
          'Test cards · no real charge' => 'كروت اختبار · من غير خصم فلوس',
          'Pay when your order arrives' => 'ادفع عند وصول طلبك',
          'Digital wallet' => 'محفظة رقمية',
          _ => subtitle,
        };

  String orderStatus(String status) => !isArabic
      ? status
      : switch (status) {
          'Order placed' => 'تم تأكيد الطلب',
          'Confirmed' => 'تم قبول الطلب',
          'Preparing' => 'جارٍ التجهيز',
          'Shipped' => 'تم الشحن',
          'Out for delivery' => 'في الطريق إليك',
          'Delivered' => 'تم التوصيل',
          'Cancelled' => 'تم الإلغاء',
          'Return requested' => 'تم طلب الإرجاع',
          'Returned' => 'تم الإرجاع',
          'Refunded' => 'تم رد المبلغ',
          _ => status,
        };

  String checkoutFailure(String message) => !isArabic
      ? message
      : switch (message) {
          'Your bag is empty.' => 'حقيبتك فارغة.',
          _ => 'تعذر تحميل خطوات الشراء. حاول مرة أخرى.',
        };

  String get orderDetails => isArabic ? 'تفاصيل الطلب' : 'ORDER DETAILS';
  String get tracking => isArabic ? 'تتبع الطلب' : 'TRACKING';
  String get items => isArabic ? 'المنتجات' : 'ITEMS';
  String get returnLabel => isArabic ? 'إرجاع' : 'RETURN';
  String get returnExchange =>
      isArabic ? 'إرجاع /\nاستبدال' : 'RETURN /\nEXCHANGE';
  String get exchangeSize => isArabic ? 'تبديل المقاس' : 'EXCHANGE SIZE';
  String get reason => isArabic ? 'السبب' : 'REASON';
  String get newSize => isArabic ? 'المقاس الجديد' : 'NEW SIZE';
  String get submitRequest => isArabic ? 'إرسال الطلب' : 'SUBMIT REQUEST';

  String get guestMode => isArabic ? 'وضع\nالضيف.' : 'GUEST\nMODE.';
  String get guestDescription => isArabic
      ? 'تصفح بحرية، وجرّب تسجيل الدخول لاستكشاف حسابك.'
      : 'Browse freely. Try signing in to explore your account.';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'SIGN IN';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'SIGN OUT';
  String get ordersReturns =>
      isArabic ? 'الطلبات والإرجاع' : 'ORDERS & RETURNS';
  String get savedItems => isArabic ? 'العناصر المحفوظة' : 'SAVED ITEMS';
  String get addresses => isArabic ? 'العناوين' : 'ADDRESSES';
  String get notifications => isArabic ? 'الإشعارات' : 'NOTIFICATIONS';
  String get languageRegion =>
      isArabic ? 'اللغة والمنطقة' : 'LANGUAGE & REGION';
  String get english => 'English';
  String get arabic => 'العربية';

  String returnReason(String value) => !isArabic
      ? value
      : switch (value) {
          'Wrong size' => 'مقاس غير مناسب',
          'Too small' => 'صغير جدًا',
          'Too large' => 'كبير جدًا',
          'Changed mind' => 'غيّرت رأيي',
          'Different from images' => 'مختلف عن الصور',
          'Damaged' => 'منتج تالف',
          _ => value,
        };
  String get tryAgain => isArabic ? 'حاول مرة أخرى' : 'TRY AGAIN';
  String loadFailure(String message) =>
      isArabic ? 'تعذر تحميل البيانات. حاول مرة أخرى.' : message;
  String get newLabel => isArabic ? 'جديد' : 'NEW';
  String get shopTheDrop => isArabic ? 'تسوق المجموعة' : 'SHOP THE DROP';
  String get limitedRelease => isArabic ? 'إصدار محدود' : 'LIMITED RELEASE';
  String get exploreProducts =>
      isArabic ? 'استكشف المنتجات' : 'EXPLORE PRODUCTS';
  String get saveRotation =>
      isArabic ? 'احفظ اختياراتك.' : 'SAVE YOUR\nROTATION.';
  String get saveDescription => isArabic
      ? 'اضغط على القلب لحفظ المنتجات التي تحبها والعودة إليها لاحقًا.'
      : 'Tap the heart on products you want to come back to.';
  String get saveProduct => isArabic ? 'حفظ المنتج' : 'Save product';
  String get removeSavedProduct =>
      isArabic ? 'إزالة من المحفوظات' : 'Remove from saved';
  String get invalidEmail =>
      isArabic ? 'أدخل بريدًا إلكترونيًا صحيحًا' : 'Enter a valid email';
  String get invalidPassword => isArabic
      ? 'كلمة المرور ٤ أحرف على الأقل'
      : 'Password must be at least 4 characters';
  String get requiredField => isArabic ? 'هذا الحقل مطلوب' : 'Required';
  String get createAccount => isArabic ? 'إنشاء حساب' : 'CREATE ACCOUNT';
  String get resetPassword =>
      isArabic ? 'نسيت كلمة المرور؟' : 'FORGOT PASSWORD?';
  String authError(String code) => switch (code) {
        'email-already-in-use' => isArabic
            ? 'البريد مستخدم بالفعل. سجّل الدخول بحسابك.'
            : 'This email already has an account. Please sign in.',
        'weak-password' => isArabic
            ? 'استخدم كلمة مرور أقوى، ٦ أحرف على الأقل.'
            : 'Use a stronger password, at least 6 characters.',
        'network-request-failed' => isArabic
            ? 'تعذر الاتصال. راجع الإنترنت وحاول مرة أخرى.'
            : 'Could not connect. Check your connection and retry.',
        'too-many-requests' => isArabic
            ? 'محاولات كثيرة. انتظر قليلًا وحاول مرة أخرى.'
            : 'Too many attempts. Please wait and try again.',
        'user-disabled' => isArabic
            ? 'هذا الحساب غير متاح حاليًا.'
            : 'This account is currently unavailable.',
        'invalid-email' => invalidEmail,
        _ => isArabic
            ? 'تعذر إكمال الطلب. راجع البيانات وحاول مرة أخرى.'
            : 'Could not complete the request. Check your details and retry.',
      };
  String get signInFailed => isArabic
      ? 'تعذر تسجيل الدخول. راجع البريد وكلمة المرور.'
      : 'Could not sign in. Check your email and password.';
  String get removeAddress => isArabic ? 'حذف العنوان' : 'Remove address';
  String addedToBag(String name, String size) => isArabic
      ? 'تمت إضافة $name · المقاس $size إلى الحقيبة'
      : 'Added $name · Size $size';
  String categoryName(String value) => !isArabic
      ? value
      : switch (value) {
          'Sneakers' => 'أحذية رياضية',
          'Hoodies' => 'هوديز',
          'Jackets' => 'جاكيتات',
          'T-Shirts' => 'تيشيرتات',
          'Bags' => 'حقائب',
          _ => value,
        };
  String colorName(String value) => !isArabic
      ? value
      : switch (value) {
          'Select' => 'اختر اللون',
          'Black' => 'أسود',
          'Grey' => 'رمادي',
          'Sand' => 'رملي',
          'White' => 'أبيض',
          'Red' => 'أحمر',
          'Olive' => 'زيتوني',
          _ => value,
        };
  String productFit(String value) => !isArabic
      ? value
      : switch (value) {
          'Regular fit' => 'قَصّة عادية',
          'True to size' => 'مطابق للمقاس',
          'Slightly narrow' => 'ضيق قليلًا',
          'Oversized fit' => 'قَصّة واسعة',
          'Relaxed fit' => 'قَصّة مريحة',
          _ => value,
        };
  String sortOption(String value) => !isArabic
      ? value
      : switch (value) {
          'Recommended' => 'مقترح لك',
          'Newest first' => 'الأحدث أولًا',
          'Price: low to high' => 'السعر: من الأقل للأعلى',
          'Price: high to low' => 'السعر: من الأعلى للأقل',
          _ => value,
        };
  String notificationText(String value) => !isArabic
      ? value
      : switch (value) {
          'Your order is moving' => 'طلبك في الطريق',
          'NOVA-025884 has left the warehouse.' =>
            'غادر الطلب NOVA-025884 المخزن.',
          'Size 44 is back' => 'المقاس ٤٤ متوفر مجددًا',
          'NEW BALANCE 9060 is available again in Black.' =>
            'يتوفر NEW BALANCE 9060 مجددًا باللون الأسود.',
          _ => value,
        };
  String brandCopy(String value) => !isArabic
      ? value
      : switch (value) {
          'GREY DAYS. FUTURE FORWARD.' => 'درجات الرمادي. خطوة نحو المستقبل.',
          'MOVE DIFFERENT.' => 'تحرك بطريقتك.',
          'CURATED FOR THE ROTATION.' => 'اختيارات تناسب ستايلك.',
          'BUILT FOR YOUR ROTATION.' => 'مصمم لستايلك.',
          'Performance roots, everyday comfort and layered street silhouettes.' =>
            'أداء رياضي، وراحة يومية، وتصاميم تناسب إطلالات الشارع.',
          'Sport-driven design translated into everyday street rotation.' =>
            'تصميم مستوحى من الرياضة لإطلالاتك اليومية.',
          'A tight edit of street essentials, utility layers and daily footwear.' =>
            'تشكيلة مختارة من أساسيات الشارع، والقطع العملية، والأحذية اليومية.',
          'A curated brand page with products currently available in NOVA.' =>
            'مجموعة مختارة من منتجات العلامة المتوفرة حاليًا في NOVA.',
          _ => value,
        };
  String productDescription(String value) => !isArabic
      ? value
      : switch (value) {
          'A layered street runner with an oversized sole and everyday cushioning.' =>
            'حذاء بطبقات متداخلة ونعل بارز، مع توسيد مريح للاستخدام اليومي.',
          'A clean everyday sneaker with visible cushioning and a bold color story.' =>
            'حذاء يومي بتصميم بسيط، وتوسيد ظاهر، وألوان جريئة.',
          'Minimal street runner selected for daily rotation and clean styling.' =>
            'حذاء بتصميم بسيط، يناسب الاستخدام اليومي والإطلالات المتنوعة.',
          'Low-profile court styling with a clean upper and versatile neutral finish.' =>
            'حذاء منخفض بتصميم مستوحى من الملاعب وألوان محايدة سهلة التنسيق.',
          'Heavyweight brushed cotton hoodie cut oversized for street layering.' =>
            'هودي من قطن ثقيل وناعم، بقَصّة واسعة تناسب تنسيق الطبقات.',
          'Structured utility layer with roomy pockets and a relaxed silhouette.' =>
            'قطعة عملية بجيوب واسعة وقَصّة مريحة.',
          _ => value,
        };

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
