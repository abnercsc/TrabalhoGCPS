# Guia de entrega: TrabalhoGCPS

**Link que será enviado ao professor:** https://github.com/abnercsc/TrabalhoGCPS

## Passo 1 — instalar as ferramentas (apenas se necessário)

No Windows, instale o Git e a GitHub CLI (`gh`), por exemplo usando `winget` em um PowerShell:

```powershell 
winget install --id Git.Git -e 
winget install --id GitHub.cli -e
```

Feche e reabra o PowerShell após instalar, para atualizar o PATH. O script usa o login via navegador da GitHub CLI, sem exigir que você cole tokens ou senhas em arquivos.

## Passo 2 — enviar e configurar

1. Extraia **todo** o ZIP em uma pasta local, preservando `.github/`.
2. Abra o PowerShell nessa pasta.
3. Execute:

```powershell
powershell -ExecutionPolicy Bypass -File .\configurar-github.ps1
```

4. Se o GitHub solicitar autenticação, finalize a autorização no navegador usando **@abnercsc**.
5. Aguarde o resumo de execução no terminal e leia quaisquer avisos apresentados.

O script, quando as permissões e recursos do repositório permitem, faz:

- primeiro commit na `main` do repositório **vazio**;
- criação do ruleset ativo para bloquear push direto e exigir PR com aprovação;
- convite para `@Thiago130126` como colaborador;
- criação do environment `staging`;
- criação do environment `production` com `@abnercsc` como required reviewer;
- tentativa **real** de push direto na `main`, salvando o resultado em um log;
- criação de branch e Pull Request para guardar o log sem violar a proteção.

O script **não força push**, **não remove regras existentes** e não concede bypass.

## Passo 3 — ação necessária do Thiago

Peça para [@Thiago130126](https://github.com/Thiago130126) aceitar o convite em suas notificações do GitHub. Depois, em **Settings → Collaborators**, confirme que ele está como colaborador ativo (com escrita). Se o PR de evidências estiver aberto, solicite a revisão dele.

## Passo 4 — finalizar o PR de evidências

Abra **Pull requests** no repositório. Solicite uma aprovação de @Thiago130126 e, depois da aprovação e dos checks, faça merge do PR. Assim `docs/evidencias/03-tentativa-push-main.txt` entra na `main` e fica disponível para o professor.

**Captura importante:** um arquivo de log real ajuda, mas tire também uma captura da saída do terminal exibindo a recusa da `main`; salve como `docs/evidencias/03-push-recusado.png`. Para anexá-la, crie uma nova branch `docs/capturas`, envie a imagem e faça uma PR revisada; não tente enviar imagens diretamente à `main` protegida.

## Passo 5 — comprovar a aprovação em produção

No GitHub, abra **Actions → Demonstração de ambientes → Run workflow**. Escolha `production` e execute. O job deve aguardar revisão. Na execução, escolha **Review deployments** e aprove com @abnercsc. Faça capturas da regra e do histórico. Execute `staging` para verificar o outro environment.

> Para que `@abnercsc` aprove uma execução que ele próprio iniciou, mantenha **Prevent self-review** desativado. É uma exigência particular da atividade acadêmica, não um modelo de segregação de responsabilidades para sistemas de produção reais.

## Passo 6 — fotos de verificação

Em `docs/evidencias/README.md` está a tabela completa de capturas. A regra da `main` e o revisor de environment são dois itens distintos. Não inclua imagens de configurações simuladas.

## Se algum passo não funcionar

- Repositório privado em plano gratuito: altere para público (se permitido) ou verifique as limitações da sua assinatura. Regras e required reviewers podem não ser aplicáveis em privados.
- Rejeição de push por falha de internet ou autenticação: não a utilize como evidência da proteção. Corrija o problema e teste novamente.
- GitHub CLI informa `Resource not accessible`: confira se o login é **@abnercsc** e se a conta possui administração do repositório.
- O convite foi enviado, mas Thiago não aparece como colaborador ativo: ele precisa aceitar primeiro.
- O PR não pode ser mesclado: uma aprovação independente está pendente, ou a verificação automática falhou.

## Conferência manual opcional

- [Repositório](https://github.com/abnercsc/TrabalhoGCPS)
- [Rulesets](https://github.com/abnercsc/TrabalhoGCPS/settings/rules)
- [Collaborators](https://github.com/abnercsc/TrabalhoGCPS/settings/access)
- [Environments](https://github.com/abnercsc/TrabalhoGCPS/settings/environments)
- [Pull requests](https://github.com/abnercsc/TrabalhoGCPS/pulls)
- [Actions](https://github.com/abnercsc/TrabalhoGCPS/actions)
