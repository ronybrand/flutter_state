import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_state/core/format_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formats like the web apps: MM/dd/yyyy, hh:mm:ss AM/PM', () {
    expect(
      formatDate(DateTime(2026, 1, 2, 3, 4, 5)),
      '01/02/2026, 03:04:05 AM',
    );
    expect(
      formatDate(DateTime(2026, 12, 31, 15, 30)),
      '12/31/2026, 03:30:00 PM',
    );
  });

  test('shows a dash for a missing date', () {
    expect(formatDate(null), '-');
  });

  test('formats Brazilian Portuguese dates using day-first 24-hour time', () {
    expect(
      formatDate(DateTime(2026, 1, 2, 15, 4, 5), locale: 'pt'),
      '02/01/2026, 15:04:05',
    );
  });

  test('renders a UTC instant in local time', () {
    final utc = DateTime.utc(2026, 1, 2, 3, 4, 5);
    expect(formatDate(utc), formatDate(utc.toLocal()));
  });
}
