import 'package:makanak/core/utils/app_strings.dart';

typedef OrderDateParts = ({String date, String? time});

OrderDateParts formatOrderDate(DateTime? value) {
  if (value == null) {
    return (date: AppStrings.orderDateUnavailable, time: null);
  }

  return (
    date: '${value.day}-${value.month}-${value.year}',
    time: _formatOrderTime(value),
  );
}

String _formatOrderTime(DateTime value) {
  final hour =
      value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour < 12 ? 'ص' : 'م';

  return '$hour:$minute $period';
}
