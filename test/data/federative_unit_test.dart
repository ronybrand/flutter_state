import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FederativeUnit.fromJson (anti-corruption layer)', () {
    test('maps the wire contract (nome, sigla, ...) to the domain type', () {
      final unit = FederativeUnit.fromJson({
        'id': 7,
        'nome': 'São Paulo',
        'sigla': 'SP',
        'dataHoraCadastro': '2026-01-10T09:00:00',
        'dataHoraUltimaAtualizacao': '2026-02-11T10:30:00',
      });
      expect(unit.id, 7);
      expect(unit.name, 'São Paulo');
      expect(unit.abbreviation, 'SP');
      expect(unit.createdAt, DateTime(2026, 1, 10, 9));
      expect(unit.updatedAt, DateTime(2026, 2, 11, 10, 30));
    });

    test('a never-updated unit has no updatedAt', () {
      final unit = FederativeUnit.fromJson({
        'id': 1,
        'nome': 'Acre',
        'sigla': 'AC',
        'dataHoraCadastro': '2026-01-10T09:00:00',
        'dataHoraUltimaAtualizacao': null,
      });
      expect(unit.updatedAt, isNull);
    });

    test('fails loudly on a payload that breaks the contract', () {
      expect(
        () => FederativeUnit.fromJson({'id': 1}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('request bodies', () {
    test('NewFederativeUnit sends only nome and sigla', () {
      expect(
        const NewFederativeUnit(
          abbreviation: 'SP',
          name: 'São Paulo',
        ).toRequestJson(),
        {'nome': 'São Paulo', 'sigla': 'SP'},
      );
    });

    test('an update leaves the id to the url, out of the body', () {
      final unit = FederativeUnit(
        id: 3,
        name: 'Rio',
        abbreviation: 'RJ',
        createdAt: DateTime(2026),
      );
      expect(unit.toRequestJson(), {'nome': 'Rio', 'sigla': 'RJ'});
    });
  });

  test('copyWith replaces only what it is given', () {
    final unit = FederativeUnit(
      id: 3,
      name: 'Rio',
      abbreviation: 'RJ',
      createdAt: DateTime(2026),
    );
    final changed = unit.copyWith(name: 'Rio de Janeiro');
    expect(changed.name, 'Rio de Janeiro');
    expect(changed.abbreviation, 'RJ');
    expect(changed.id, 3);
  });
}
