import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

abstract final class AppIcons {
  static final IconData home = PhosphorIcons.house();
  static final IconData homeActive =
      PhosphorIcons.house(PhosphorIconsStyle.bold);
  static final IconData shop = PhosphorIcons.squaresFour();
  static final IconData shopActive =
      PhosphorIcons.squaresFour(PhosphorIconsStyle.bold);
  static final IconData discover = PhosphorIcons.compass();
  static final IconData discoverActive =
      PhosphorIcons.compass(PhosphorIconsStyle.bold);
  static final IconData saved = PhosphorIcons.heart();
  static final IconData savedActive =
      PhosphorIcons.heart(PhosphorIconsStyle.fill);
  static final IconData account = PhosphorIcons.user();
  static final IconData accountActive =
      PhosphorIcons.user(PhosphorIconsStyle.bold);

  static final IconData search = PhosphorIcons.magnifyingGlass();
  static final IconData notifications = PhosphorIcons.bell();
  static final IconData notificationsActive =
      PhosphorIcons.bellRinging(PhosphorIconsStyle.fill);
  static final IconData bag = PhosphorIcons.shoppingBag();
  static final IconData bagOpen = PhosphorIcons.shoppingBagOpen();
  static final IconData arrowRight = PhosphorIcons.arrowRight();
  static final IconData arrowLeft = PhosphorIcons.arrowLeft();
  static final IconData wifiOff = PhosphorIcons.wifiSlash();
  static final IconData check =
      PhosphorIcons.check(PhosphorIconsStyle.bold);
  static final IconData share = PhosphorIcons.shareNetwork();
  static final IconData plus = PhosphorIcons.plus();
  static final IconData minus = PhosphorIcons.minus();
  static final IconData trash = PhosphorIcons.trashSimple();
  static final IconData tag = PhosphorIcons.tag();
  static final IconData filter = PhosphorIcons.fadersHorizontal();
  static final IconData sort = PhosphorIcons.arrowsDownUp();
  static final IconData inventory = PhosphorIcons.package();
  static final IconData priceDrop = PhosphorIcons.trendDown();
  static final IconData delivery = PhosphorIcons.truck();
  static final IconData payment = PhosphorIcons.creditCard();
  static final IconData returns = PhosphorIcons.arrowCounterClockwise();
  static final IconData storefront = PhosphorIcons.storefront();
  static final IconData location = PhosphorIcons.mapPin();
  static final IconData language = PhosphorIcons.globe();
  static final IconData receipt = PhosphorIcons.receipt();
  static final IconData product = PhosphorIcons.hoodie();
  static final IconData star = PhosphorIcons.star();
  static final IconData starFilled =
      PhosphorIcons.star(PhosphorIconsStyle.fill);
}
