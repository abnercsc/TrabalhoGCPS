# TrabalhoGCPS — Gestão de Configuração de Software

**Repositório:** [abnercsc/TrabalhoGCPS](https://github.com/abnercsc/TrabalhoGCPS)  
**Responsável:** [@abnercsc](https://github.com/abnercsc)  
**Par de revisão:** [@Thiago130126](https://github.com/Thiago130126)  
**Atividade:** N2–P2 — Gestão de Configuração de Software (GCS)

## Propósito

Repositório acadêmico demonstrativo para executar e documentar um processo de gestão de configuração de software. A organização e o fluxo de controle se inspiram na atividade da disciplina relacionada ao projeto **OngConecta**, sem copiar ou afirmar conter seu código original.

O projeto inclui um **protótipo estático** (`src/`) de catálogo de oportunidades de voluntariado para tornar o versionamento e as revisões demonstráveis. Não possui API, banco de dados ou publicação automática em servidor.

## Conteúdo

| Local | Item de configuração |
|---|---|
| `docs/Plano_GCS.md` | Plano de GCS: identificação, mudanças, versionamento, auditoria |
| `docs/GUIA_DE_ENTREGA.md` | Passo a passo da configuração e da coleta de evidências |
| `docs/evidencias/` | Logs e capturas genuínos do GitHub |
| `src/` | Protótipo HTML, CSS e JavaScript |
| `.github/workflows/validacao.yml` | CI para conferência dos arquivos básicos |
| `.github/workflows/ambientes.yml` | Execução manual dos jobs associados a `staging` e `production` |
| `.github/pull_request_template.md` | Modelo de solicitação de mudança |
| `configurar-github.ps1` | Assistente de configuração para Windows, com Git e GitHub CLI |

## Executar o protótipo

Abra `src/index.html` no navegador. O filtro permite procurar oportunidades cadastradas localmente. O protótipo é apenas um item de configuração de exemplo.

## Fluxo de alterações

`feature/*` ou `docs/*` → Pull Request → revisão por @Thiago130126 → validação → merge em `main` → ambiente `staging` ou `production` com aprovação de @abnercsc na produção.

A configuração de repositório **não é comprovada pela presença desses arquivos**. O professor deve verificar o estado real das regras do GitHub e as evidências anexadas.

## Estado de entrega

O preenchimento das caixas a seguir deve refletir verificações reais no GitHub, após a execução de `configurar-github.ps1` e a aceitação do convite pelo colaborador:

- [ ] Arquivos publicados no repositório, com `docs/Plano_GCS.md` versionado.
- [ ] Repositório público e acessível sem autenticação.
- [ ] Regra ativa exige Pull Request para mudanças em `main`.
- [ ] Push direto à `main` recusado de fato, com log e captura em `docs/evidencias/`.
- [ ] @Thiago130126 aceitou convite e possui escrita.
- [ ] Environments `staging` e `production` existentes.
- [ ] @abnercsc cadastrado como Required reviewer em `production`.
- [ ] PR com evidências revisada e integrada à `main`.

## Comandos de configuração no Windows

No PowerShell, dentro da pasta extraída:

```powershell
.\configurar-github.ps1
```

O script exige **Git** e **GitHub CLI (`gh`)** instalados. A autenticação ocorre no navegador, em sua própria conta. Ele publica os arquivos no repositório vazio, convida o par, configura regras e ambientes e tenta um push direto para coletar a recusa real; detalhes em `docs/GUIA_DE_ENTREGA.md`.
