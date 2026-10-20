// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Estados Brasileiros';

  @override
  String get languageSwitchLabel => 'Mudar idioma';

  @override
  String get languageSaveError =>
      'Não foi possível salvar a preferência de idioma.';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get logOut => 'Sair';

  @override
  String get logIn => 'Entrar';

  @override
  String get newState => 'Novo estado';

  @override
  String get searchLabel => 'Buscar por nome ou sigla';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortAscending => 'crescente';

  @override
  String get sortDescending => 'decrescente';

  @override
  String get sortAbbreviation => 'Sigla';

  @override
  String get sortName => 'Nome';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get noStates => 'Nenhum estado cadastrado.';

  @override
  String get createFirstState => 'Criar o primeiro estado';

  @override
  String get deleteStateTitle => 'Excluir estado';

  @override
  String confirmDeleteState(String abbreviation) {
    return 'Tem certeza que deseja excluir $abbreviation?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String deleteState(String abbreviation) {
    return 'Excluir $abbreviation';
  }

  @override
  String editState(String abbreviation) {
    return 'Editar $abbreviation';
  }

  @override
  String created(String date) {
    return 'Criado: $date';
  }

  @override
  String updated(String date) {
    return 'Atualizado: $date';
  }

  @override
  String get loginTitle => 'Login';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get logInButton => 'Entrar';

  @override
  String get demoCredentials =>
      'Credenciais de demonstração (intencionalmente públicas): admin / Estado-Demo-2026';

  @override
  String get newStateTitle => 'Novo estado';

  @override
  String get editStateTitle => 'Editar estado';

  @override
  String get abbreviation => 'Sigla';

  @override
  String get name => 'Nome';

  @override
  String get nameHint => 'Digite o nome do estado...';

  @override
  String get save => 'Salvar';

  @override
  String get invalidState => 'Estado inválido.';

  @override
  String get abbreviationLengthError =>
      'Digite a sigla do estado com 2 letras.';

  @override
  String get abbreviationFormatError =>
      'Digite a sigla do estado com 2 letras maiúsculas.';

  @override
  String get duplicateAbbreviationError =>
      'Já existe um estado cadastrado com essa sigla.';

  @override
  String get nameMinLengthError =>
      'Digite o nome do estado com pelo menos 3 caracteres.';

  @override
  String get nameMaxLengthError =>
      'Digite o nome do estado com no máximo 100 caracteres.';

  @override
  String get invalidCredentialsError => 'Usuário ou senha inválidos.';

  @override
  String get loadStatesError => 'Falha ao buscar estados.';

  @override
  String get loadStateError => 'Falha ao buscar estado.';

  @override
  String get createStateError => 'Falha ao criar estado.';

  @override
  String get updateStateError => 'Falha ao atualizar estado.';

  @override
  String get deleteStateError => 'Falha ao excluir estado.';

  @override
  String get apiUnavailableMessage =>
      'A API está offline (pausada para reduzir custos). Ative-a pelo link abaixo; isso leva cerca de 1 minuto.';

  @override
  String get turnOnApi => 'Ativar a API';

  @override
  String referenceId(String id) {
    return 'ID de referência: $id';
  }

  @override
  String get loading => 'Carregando';

  @override
  String get pageNotFound => 'Página não encontrada';

  @override
  String get pageNotFoundDescription => 'A tela que você procura não existe.';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String appVersion(String version) {
    return 'app $version';
  }

  @override
  String backendVersion(String commit, String date) {
    return 'back $commit · $date';
  }
}
