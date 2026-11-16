# Plano de Gestão de Configuração de Software (GCS)

**Projeto:** TrabalhoGCPS — estudo de caso de catálogo de voluntariado  
**Repositório:** `https://github.com/abnercsc/TrabalhoGCPS`  
**Responsável:** Abner (`@abnercsc`)  
**Revisor de mudanças:** Thiago (`@Thiago130126`)  
**Versão:** 1.0.0 | **Emissão:** 16/11/2026 | **Situação:** Plano estabelecido; controles remotos sujeitos a verificação

## 1. Objetivo e aplicação

O plano define práticas de identificação, controle, rastreabilidade, versionamento, revisão e auditoria dos itens de configuração mantidos no GitHub. Seu objetivo é evitar alterações não autorizadas na linha principal e permitir a reprodução do estado de cada entrega. Aplica-se ao protótipo de catálogo de oportunidades de voluntariado, aos documentos, scripts de automação e às configurações remotas do repositório.

## 2. Identificação dos itens de configuração

| Código | Item | Local | Responsável | Forma de controle |
|---|---|---|---|---|
| IC-01 | Front-end demonstrativo | `src/index.html`, `src/styles.css`, `src/app.js` | Abner | Commits, PR, revisão |
| IC-02 | Plano de GCS | `docs/Plano_GCS.md` | Abner | Histórico Git, PR e tag |
| IC-03 | Guias, registros e evidências | `docs/` | Abner | Histórico Git, PR |
| IC-04 | Pipeline de validação | `.github/workflows/validacao.yml` | Abner | PR e verificação automática |
| IC-05 | Pipeline de ambientes | `.github/workflows/ambientes.yml` | Abner | PR e controles GitHub Environments |
| IC-06 | Política de PR e revisão | `.github/pull_request_template.md` e regras do GitHub | Abner | PR, configuração GitHub e evidências |
| IC-07 | Permissões de colaboração | Configuração do repositório GitHub | Abner | Convite, aceitação, conferência de acesso |
| IC-08 | Ambientes `staging`, `production` | Settings → Environments | Abner | Aprovação e histórico de execução |

**Critério de identificação:** todo arquivo controlado pertence ao repositório e é identificado por caminho, commit e, quando aplicável, uma tag de versão. Configurações que vivem apenas na interface do GitHub são identificadas pelo nome e comprovadas por consulta/captura do estado remoto.

## 3. Papéis e responsabilidades

| Papel | Pessoa | Responsabilidades |
|---|---|---|
| Administrador e mantenedor | @abnercsc | Manter regras, planejar mudanças, integrar PRs, aprovar implantação em produção |
| Par revisor | @Thiago130126 | Aceitar convite de colaboração, revisar alterações e aprovar ou solicitar ajustes |
| Avaliador | Professor da disciplina | Conferir publicamente o repositório e as evidências de execução |

O convite enviado ao revisor **não equivale** à confirmação de escrita: a aceitação deve ser verificada no GitHub.

## 4. Estratégia de branches

- `main`: baseline estável, protegida; integração via Pull Request com ao menos uma aprovação de usuário distinto do autor.
- `feature/*`: implementação incremental do protótipo.
- `fix/*`: reparos.
- `docs/*`: melhorias no plano, nos registros e evidências.

Não há trabalho de desenvolvimento diretamente na `main` após sua configuração inicial. O commit de inicialização antecede a proteção, porque um repositório vazio ainda não possui branch `main` publicada.

## 5. Solicitação e controle de mudanças

1. Descrever a necessidade da mudança e os itens afetados.
2. Criar uma branch temática a partir da versão atual da `main`.
3. Alterar somente os itens previstos, com commits coerentes (`feat:`, `fix:`, `docs:`, `chore:`, `test:`).
4. Abrir Pull Request e preencher contexto, riscos e testes no modelo do projeto.
5. Solicitar revisão de @Thiago130126 (após aceitar acesso de escrita).
6. Confirmar aprovação, ausência de bloqueios e sucesso das verificações.
7. Integrar o Pull Request, criando um novo estado estável da `main`.
8. Se pertinente, marcar a release com uma tag `vX.Y.Z`.

Aprovação de PR e aprovação de deployment são controles **independentes**.

## 6. Baselines e controle de versões

A baseline inicial é o primeiro commit na branch `main`. As alterações aprovadas são incorporadas à baseline por Pull Request. Tags seguem o padrão Semantic Versioning `vMAJOR.MINOR.PATCH` quando houver entrega funcional. A integridade pode ser auditada por SHA do commit e histórico das Pull Requests. Evitar reescrever o histórico compartilhado e não permitir force push na `main`.

## 7. Proteção da main

O ruleset `GCS - Proteger main` deve conter, no mínimo:

- alvo: `refs/heads/main`;
- estado: **Active**;
- **Require a pull request before merging**;
- ao menos **1 approving review**;
- bloqueio de remoção e de force push;
- ausência de exceções de bypass para o proprietário e para colaboradores.

**Teste exigido:** depois de ativar a regra, efetuar um commit de documentação na `main` local e tentar `git push origin main`. O servidor deve rejeitar o push por violação das regras. Preservar o log genuíno e uma captura da saída com contexto. Um erro de credenciais ou rede, sozinho, **não prova** a proteção da branch.

## 8. Acesso e revisão

O repositório precisa estar acessível para o avaliador, preferencialmente público. O par `@Thiago130126` deve ser convidado como colaborador, aceitar e possuir escrita. Sua aprovação de Pull Requests é separada da exigência de que `@abnercsc` revise implantações em `production`.

## 9. Ambientes e promoção

| Ambiente | Uso | Proteção |
|---|---|---|
| `staging` | Verificar a revisão candidata sem risco para produção | Workflow de execução manual e logs |
| `production` | Registrar aprovação final da versão | **Required reviewers**: `@abnercsc` |

O parâmetro **Prevent self-review** fica desativado porque a atividade solicita que o próprio proprietário seja revisor obrigatório do ambiente de produção. Quando o workflow for iniciado pelo próprio proprietário, ele poderá aprovar o job pendente. `production` é demonstrativo: o workflow confirma o processo de autorização, mas não publica software em um servidor externo.

## 10. Verificações e auditoria

| Controle | Evidência verificável | Frequência |
|---|---|---|
| Estrutura e plano | Árvore do repositório e arquivo `docs/Plano_GCS.md` | Cada entrega |
| Acesso do avaliador | Visibilidade `Public` ou acesso concedido | Antes da avaliação |
| Proteção da main | Configuração de Rulesets e log real de push recusado | Na configuração e após mudanças |
| Revisão independente | Colaborador com escrita, PR e aprovação | A cada PR |
| Environments | `staging`, `production` e configuração Required reviewers | Na configuração e após mudanças |
| Verificação automática | Execução CI com resultado de sucesso | A cada PR |

As capturas devem retratar ações que realmente aconteceram. O arquivo `docs/evidencias/README.md` contém o índice de evidências.

## 11. Controles complementares

- Não publicar senhas, credenciais, tokens nem arquivos de ambiente sensíveis.
- Usar `.gitignore` para arquivos temporários ou locais.
- Manter documentação coerente com o comportamento verificado, incluindo quaisquer limitações de plano/visibilidade do GitHub.
- Não considerar uma regra concluída até observar seu estado remoto.

## 12. Critério de conclusão da atividade

Concluir após: (a) plano e estrutura publicados; (b) acesso confirmado; (c) `main` protegida e push direto comprovadamente recusado; (d) @Thiago130126 com escrita e revisão; (e) `staging` e `production` com @abnercsc como Required reviewer em produção. Incluir as evidências em uma PR revisada antes da entrega.

## 13. Histórico do documento

| Versão | Data | Autor | Descrição |
|---|---|---|---|
| 1.0.0 | 16/11/2026 | Abner | Plano inicial para TrabalhoGCPS, com políticas de repositório e ambientes |
