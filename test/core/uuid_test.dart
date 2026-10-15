import 'package:flutter_state/core/uuid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uuidV4 produces a well-formed version 4 uuid', () {
    expect(
      uuidV4(),
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('uuidV4 does not repeat', () {
    final seen = {for (var i = 0; i < 500; i++) uuidV4()};
    expect(seen, hasLength(500));
  });

  group('isUuid', () {
    test('accepts a uuid, any case', () {
      expect(isUuid('123e4567-e89b-12d3-a456-426614174000'), isTrue);
      expect(isUuid('123E4567-E89B-12D3-A456-426614174000'), isTrue);
    });

    test('rejects anything else', () {
      expect(isUuid('not-a-uuid'), isFalse);
      expect(isUuid('123e4567-e89b-12d3-a456-42661417400'), isFalse);
      expect(isUuid('<script>'), isFalse);
    });
  });
}
