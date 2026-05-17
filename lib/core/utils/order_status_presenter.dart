import 'package:makanak/core/utils/app_strings.dart';

abstract final class OrderStatusPresenter {
  const OrderStatusPresenter._();

  static const pendingKey = 'تحت المراجعة';
  static const preparingKey = 'يتم تحضيره';
  static const outForDeliveryKey = 'خرج للتوصيل';
  static const deliveredKey = 'تم توصيله';
  static const rejectedKey = 'ملغي';

  static const orderStatuses = [
    pendingKey,
    preparingKey,
    outForDeliveryKey,
    deliveredKey,
    rejectedKey,
  ];

  static String label(String rawStatus) {
    final normalized = normalize(rawStatus);
    if (orderStatuses.contains(normalized)) {
      return normalized;
    }

    return normalized.isEmpty ? AppStrings.orderStatus : normalized;
  }

  static String notificationBody(String rawStatus) {
    return AppStrings.orderStatusUpdated(label(rawStatus));
  }

  static String normalize(String rawStatus) {
    final normalized = rawStatus.trim();

    switch (normalized) {
      case pendingKey:
      case preparingKey:
      case outForDeliveryKey:
      case deliveredKey:
      case rejectedKey:
        return normalized;
      default:
        return normalized;
    }
  }
}
