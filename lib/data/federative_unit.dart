/// A Brazilian federative unit (a "state"). Named after the domain term because
/// `State` is already Flutter's own widget-state class.
///
/// The backend's JSON uses Portuguese names (`nome`, `sigla`, ...); that is the
/// real wire contract and is not translated. [fromJson] and [toRequestJson] are
/// the anti-corruption layer, so the rest of the app only ever sees English.
class FederativeUnit {
  const FederativeUnit({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.createdAt,
    this.updatedAt,
  });

  factory FederativeUnit.fromJson(Map<String, Object?> json) {
    try {
      final updated = json['dataHoraUltimaAtualizacao'] as String?;
      return FederativeUnit(
        id: json['id']! as int,
        name: json['nome']! as String,
        abbreviation: json['sigla']! as String,
        createdAt: DateTime.parse(json['dataHoraCadastro']! as String),
        updatedAt: updated == null ? null : DateTime.parse(updated),
      );
    } on Object catch (error) {
      throw FormatException('Unexpected federative unit payload: $error');
    }
  }

  final int id;
  final String name;
  final String abbreviation;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// The id identifies the resource through the url (PUT /estado/{id}), so it is
  /// not part of the body.
  Map<String, Object?> toRequestJson() => {'nome': name, 'sigla': abbreviation};

  FederativeUnit copyWith({String? name, String? abbreviation}) =>
      FederativeUnit(
        id: id,
        name: name ?? this.name,
        abbreviation: abbreviation ?? this.abbreviation,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// What the form produces: validated, trimmed, upper-cased.
class NewFederativeUnit {
  const NewFederativeUnit({required this.abbreviation, required this.name});

  final String abbreviation;
  final String name;

  Map<String, Object?> toRequestJson() => {'nome': name, 'sigla': abbreviation};
}
