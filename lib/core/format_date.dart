import 'package:intl/intl.dart';

final _formatter = DateFormat('MM/dd/yyyy, hh:mm:ss a', 'en_US');

/// The same format as the web apps, in the device's local time.
String formatDate(DateTime? date) =>
    date == null ? '-' : _formatter.format(date.toLocal());
