# Arquitetura técnica: flutter_state

Cliente Flutter do CRUD de unidades federativas (estados), sobre a API do projeto `estado`. Mesmo comportamento do `android_state` e do `react_native_state`; um código para Android, iOS e web.

## 1. Stack

Flutter 3.47 e Dart 3.13, Riverpod 3 (estado), go_router (navegação com `redirect`), dio (rede), flutter_secure_storage (token).

## 2. Estrutura

```
lib/
  core/      cliente dio e interceptors, token, config, utilidades
  data/      repositórios e modelos
  state/     providers do Riverpod (sessão, lista, formulário)
  screens/   telas e widgets
```

## 3. Estado e navegação

Os providers do Riverpod são a fonte de verdade: sessão, lista de estados e operações. A UI só lê providers e dispara ações. O go_router usa um `redirect` como guarda: sem sessão válida, qualquer rota protegida vai para o login; com sessão, o login vai para a lista. Como o redirecionamento depende do provider da sessão, o fim da sessão (401 ou expiração) navega sozinho.

## 4. Rede

Interceptors do dio, em ordem: `X-Request-Id` (preservado entre tentativas), `Authorization: Bearer`, retry de GET com backoff e tratamento de 401 que encerra a sessão uma vez. Erros viram um tipo próprio com mensagem e `request_id`, exibido ao usuário. A validação do formulário repete as regras e mensagens do back-end.

## 5. Segurança

Token no `flutter_secure_storage` (Keystore no Android, Keychain no iOS). Release assinado; o CI verifica a assinatura com uma chave descartável e o workflow `release-android` gera o pacote. Trivy varre o repositório.

## 6. Testes

- 194 testes (unitários e de widget), cerca de 96% de linhas, piso 90%, escritos com o teste primeiro.
- **Acessibilidade**: as guidelines do próprio framework (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, contraste) rodam em cada tela. É a cobertura automática mais completa das três stacks mobile.
- **Não há E2E.** O app é exercitado por testes de widget e pelo build web.

## 7. Qualidade e CI

`flutter analyze --fatal-infos`, `dart format`, testes com cobertura, Trivy, verificação da assinatura de release. O CodeQL não analisa Dart; não há SBOM nem emulador. Sem hook de pré-commit.

## 8. Pendências

E2E em emulador, SBOM, chave de upload e ficha de loja, assinatura iOS.

## 9. Trade-offs

| Escolha | Ganho | Custo |
|---|---|---|
| Um código para várias plataformas | menos retrabalho | UI própria do Flutter, não nativa |
| Riverpod | estado testável, redirect reativo | curva de aprendizado e geradores opcionais |
| Guidelines de acessibilidade do framework | checagem automática pronta | não substitui leitor de tela real |
| Sem E2E | CI mais rápido | regressões de integração ficam sem rede de proteção |
