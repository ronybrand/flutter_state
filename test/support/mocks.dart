import 'package:flutter_state/data/auth_repository.dart';
import 'package:flutter_state/data/ask_repository.dart';
import 'package:flutter_state/data/federative_unit.dart';
import 'package:flutter_state/data/info_repository.dart';
import 'package:flutter_state/data/state_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStateRepository extends Mock implements StateRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAskRepository extends Mock implements AskRepository {}

class MockInfoRepository extends Mock implements InfoRepository {}

class FakeUnit extends Fake implements FederativeUnit {}

class FakeNewUnit extends Fake implements NewFederativeUnit {}

void registerFallbacks() {
  registerFallbackValue(FakeUnit());
  registerFallbackValue(FakeNewUnit());
}

FederativeUnit unit({
  int id = 1,
  String name = 'São Paulo',
  String abbreviation = 'SP',
  DateTime? createdAt,
  DateTime? updatedAt,
}) => FederativeUnit(
  id: id,
  name: name,
  abbreviation: abbreviation,
  createdAt: createdAt ?? DateTime(2026, 1, 2, 3, 4, 5),
  updatedAt: updatedAt,
);
