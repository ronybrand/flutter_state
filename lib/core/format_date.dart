import 'package:intl/intl.dart';

/// Formats dates using the active app locale and the device's local time.
String formatDate(DateTime? date, {String locale = 'en_US'}) {
  if (date == null) return '-';

  final format = locale.startsWith('pt')
      ? DateFormat('dd/MM/yyyy, HH:mm:ss', 'pt_BR')
      : DateFormat('MM/dd/yyyy, hh:mm:ss a', 'en_US');
  return format.format(date.toLocal());
}
