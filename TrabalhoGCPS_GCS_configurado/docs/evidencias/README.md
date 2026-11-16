# Índice de evidências — GCS

As evidências são **registros de execução real** (não gerados artificialmente). O script prepara o log da tentativa de push e uma PR para arquivá-lo.

| Arquivo recomendado | Conteúdo |
|---|---|
| `01-estrutura-repositorio.png` | Repositório com diretórios e plano GCS publicados |
| `02-ruleset-main.png` | Ruleset ativo, alvo `main`, PR obrigatório e revisão |
| `03-push-recusado.png` | Terminal com recusa do GitHub por violação de branch protegida |
| `03-tentativa-push-main.txt` | Log genuíno produzido durante o teste de push |
| `04-par-revisor.png` | @Thiago130126 aceito, com acesso de escrita |
| `05-environment-staging.png` | Ambiente `staging` cadastrado |
| `06-environment-production.png` | `production` com @abnercsc em Required reviewers |
| `07-aprovacao-production.png` | Aprovação real de job de deployment no GitHub Actions |
| `08-pr-aprovado.png` | Pull Request aprovada pelo colaborador |

**Não cole tokens ou senhas em prints.** Revise os logs antes de publicar. O próprio repositório pode ser acessado pelo professor para confirmar os controles.
