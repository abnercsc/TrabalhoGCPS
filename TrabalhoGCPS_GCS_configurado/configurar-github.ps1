# Assistente para Windows — uso: powershell -ExecutionPolicy Bypass -File .\configurar-github.ps1
# Executar na pasta extraida do projeto. Requer Git e GitHub CLI (gh).
# Nao solicita tokens e nao realiza force push.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Owner = 'abnercsc'
$Repo = 'TrabalhoGCPS'
$Collaborator = 'Thiago130126'
$FullRepo = "$Owner/$Repo"
$Url = "https://github.com/$FullRepo.git"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $Root

function VerificarSaida($contexto) {
    if ($LASTEXITCODE -ne 0) { throw "$contexto falhou. Confira a mensagem anterior." }
}
function ChamarApiJson($metodo, $endpoint, $corpo) {
    $arquivo = [IO.Path]::GetTempFileName()
    try {
        $json = ConvertTo-Json -InputObject $corpo -Depth 20 -Compress
        [IO.File]::WriteAllText($arquivo, $json, [System.Text.UTF8Encoding]::new($false))
        $resposta = & gh api --method $metodo $endpoint --input $arquivo
        VerificarSaida "API $metodo $endpoint"
        if ($resposta) { return (($resposta | Out-String) | ConvertFrom-Json) }
        return $null
    } finally {
        Remove-Item -LiteralPath $arquivo -Force -ErrorAction SilentlyContinue
    }
}

Write-Host '== TrabalhoGCPS | Assistente de configuracao GCS ==' -ForegroundColor Cyan
foreach ($programa in @('git','gh')) {
    if (-not (Get-Command $programa -ErrorAction SilentlyContinue)) {
        throw "Programa $programa nao encontrado. Instale Git e GitHub CLI. Consulte docs/GUIA_DE_ENTREGA.md."
    }
}

$Antes = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& gh auth status --hostname github.com *> $null
$CodigoAuth = $LASTEXITCODE
$ErrorActionPreference = $Antes
if ($CodigoAuth -ne 0) {
    Write-Host 'Autorize a GitHub CLI no navegador com a conta abnercsc.' -ForegroundColor Yellow
    & gh auth login --hostname github.com --web --git-protocol https
    VerificarSaida 'Login no GitHub'
}
& gh auth setup-git
VerificarSaida 'Configuracao da autenticacao do Git'

$Usuario = (& gh api user --jq '.login' | Out-String).Trim()
VerificarSaida 'Consulta do usuario GitHub'
$Id = [int]((& gh api user --jq '.id' | Out-String).Trim())
VerificarSaida 'Consulta do ID GitHub'
if ($Usuario -ine $Owner) { throw "Autenticado como $Usuario. Use a conta $Owner antes de continuar." }

$RepoInfo = ((& gh api "repos/$FullRepo") | Out-String) | ConvertFrom-Json
VerificarSaida 'Consulta do repositorio'
if ($RepoInfo.visibility -ne 'public') {
    throw 'Repositorio nao e publico. Para os controles GitHub Free funcionarem, deixe-o Public (se permitido) em Settings.'
}
Write-Host "Repositorio verificado: $FullRepo (publico)" -ForegroundColor Green

if (-not (Test-Path '.git')) {
    & git init -b main
    VerificarSaida 'git init'
}
$remote = & git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    & git remote add origin $Url
    VerificarSaida 'Configuracao do remoto origin'
} elseif ($remote.Trim() -notmatch 'github\.com[:/]abnercsc/TrabalhoGCPS(\.git)?$') {
    throw "Remote origin inesperado: $remote. Nao sera alterado automaticamente."
}

$nomeGit = (& git config user.name | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($nomeGit)) { & git config user.name $Usuario }
$emailGit = (& git config user.email | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($emailGit)) {
    & git config user.email "$Id+$Usuario@users.noreply.github.com"
}

# O primeiro commit precisa ser enviado ANTES da protecao de main.
$Heads = & git ls-remote --heads origin main
VerificarSaida 'Verificacao da main remota'
if ([string]::IsNullOrWhiteSpace(($Heads | Out-String))) {
    Write-Host 'Criando commit inicial no repositorio vazio...' -ForegroundColor Cyan
    & git switch -C main
    VerificarSaida 'Selecao da main'
    & git add -A
    VerificarSaida 'git add'
    & git commit -m 'chore: inicia repositorio e plano de GCS'
    VerificarSaida 'Commit inicial'
    & git push -u origin main
    VerificarSaida 'Publicacao inicial'
} else {
    Write-Host 'main remota ja existe; nao sobrescrevendo commits.' -ForegroundColor Yellow
}

# Habilitar protecao com PR e revisao, sem bypass.
$Rulesets = @(((& gh api "repos/$FullRepo/rulesets") | Out-String) | ConvertFrom-Json)
VerificarSaida 'Leitura de rulesets'
$Existente = @($Rulesets | Where-Object { $_.name -eq 'GCS - Proteger main' })
if ($Existente.Count -eq 0) {
    $Body = @{
        name = 'GCS - Proteger main'
        target = 'branch'
        enforcement = 'active'
        bypass_actors = @()
        conditions = @{ ref_name = @{ include = @('refs/heads/main'); exclude = @() } }
        rules = @(
            @{ type = 'deletion' }
            @{ type = 'non_fast_forward' }
            @{ type = 'pull_request'; parameters = @{
                allowed_merge_methods = @('merge','squash','rebase')
                dismiss_stale_reviews_on_push = $true
                require_code_owner_review = $false
                require_last_push_approval = $false
                required_approving_review_count = 1
                required_review_thread_resolution = $true
            } }
        )
    }
    $null = ChamarApiJson 'POST' "repos/$FullRepo/rulesets" $Body
    Write-Host 'Ruleset da main criado e ativado.' -ForegroundColor Green
} else {
    Write-Host 'Ruleset GCS ja existe. Confira seu estado em Settings > Rules.' -ForegroundColor Yellow
}

# Convidar o revisor. O convite somente sera efetivo depois de aceito.
& gh api --method PUT "repos/$FullRepo/collaborators/$Collaborator" | Out-Null
VerificarSaida 'Convite do colaborador'
Write-Host "Convite enviado/verificado para @$Collaborator. Ele precisa aceitar." -ForegroundColor Yellow

# Criar environments; em production, o proprio proprietario deve aprovar.
$null = ChamarApiJson 'PUT' "repos/$FullRepo/environments/staging" @{}
$null = ChamarApiJson 'PUT' "repos/$FullRepo/environments/production" @{
    wait_timer = 0
    prevent_self_review = $false
    reviewers = @(@{type='User'; id=$Id})
    deployment_branch_policy = $null
}
Write-Host 'Environments staging e production criados.' -ForegroundColor Green

# Confirmar que o GitHub realmente registrou a regra e o revisor.
$Rules = @(((& gh api "repos/$FullRepo/rules/branches/main") | Out-String) | ConvertFrom-Json)
VerificarSaida 'Verificacao de regras de main'
$HasPRRule = @($Rules | Where-Object {$_.type -eq 'pull_request'}).Count -gt 0
if (-not $HasPRRule) { throw 'Regra pull_request nao apareceu na main. Nao e seguro considerar a protecao concluida.' }
$Prod = ((& gh api "repos/$FullRepo/environments/production") | Out-String) | ConvertFrom-Json
VerificarSaida 'Verificacao de production'
$Revisores = @($Prod.protection_rules | Where-Object {$_.type -eq 'required_reviewers'})
if ($Revisores.Count -eq 0) { throw 'production nao possui Required reviewers. Verifique seu plano/visibilidade.' }
$EhRevisor = $false
foreach ($proteca in $Revisores) {
    foreach ($elemento in $proteca.reviewers) {
        if ($elemento.reviewer.login -ieq $Owner) { $EhRevisor = $true }
    }
}
if (-not $EhRevisor) { throw 'O revisor @abnercsc nao apareceu no ambiente production.' }
Write-Host 'Regras e reviewer de production verificados pela API.' -ForegroundColor Green

# Gerar uma evidência autêntica de recusa. Nao deve confundir rede/credenciais com bloqueio.
& git switch main
VerificarSaida 'Selecao da main para teste'
& git pull --ff-only origin main
VerificarSaida 'Atualizacao da main'
$DataAtual = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
$ArquivoTeste = 'docs/evidencias/registro-teste-main.txt'
"Tentativa de alteracao direta em main: $DataAtual (registro demonstrativo)." | Set-Content -LiteralPath $ArquivoTeste -Encoding UTF8
& git add -- $ArquivoTeste
VerificarSaida 'Preparacao do commit de teste'
& git commit -m 'test: valida bloqueio de push direto na main'
VerificarSaida 'Criacao de commit de teste'
Write-Host 'Tentando push direto na main para capturar a rejeicao real...' -ForegroundColor Cyan
$Antes = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$SaidaPush = (& git push origin main 2>&1 | Out-String)
$CodigoPush = $LASTEXITCODE
$ErrorActionPreference = $Antes
Write-Host $SaidaPush
$RecusaDaRegra = ($CodigoPush -ne 0) -and ($SaidaPush -match 'GH013|GH006|repository rule violations|protected branch|rule violations|Changes must be made through a pull request|protected branch update failed')
$Log = 'docs/evidencias/03-tentativa-push-main.txt'
@(
    'Registro autentico do comando git push origin main'
    "Data: $DataAtual"
    "Repositorio: https://github.com/$FullRepo"
    "Codigo de saida: $CodigoPush"
    "Recusa atribuida a regra de main: $RecusaDaRegra"
    '--- Saida recebida do GitHub ---'
    $SaidaPush
) | Set-Content -LiteralPath $Log -Encoding UTF8
if (-not $RecusaDaRegra) {
    Write-Warning 'NAO FOI CONFIRMADA recusa por regra da main. Consulte o log. Pode ter sido rede/autenticacao ou uma regra nao aplicada.'
    Write-Warning 'Nao apresente o log como prova de bloqueio ate diagnosticar.'
    return
}

# O commit local rejeitado e preservado em branch de evidencias e revisado via PR.
$Branch = 'docs/evidencia-main-' + (Get-Date -Format 'yyyyMMddHHmmss')
& git switch -c $Branch
VerificarSaida 'Criacao da branch de evidencias'
& git add -- $Log
VerificarSaida 'Preparacao do log'
& git commit -m 'docs: registra evidencia de push direto recusado'
VerificarSaida 'Commit do log'
& git push -u origin $Branch
VerificarSaida 'Push da branch de evidencias'
$PR = & gh pr create --repo $FullRepo --base main --head $Branch --title 'docs: registra recusa de push direto na main' --body 'Inclui log autentico de tentativa de push recusada pelo ruleset da main. Solicitar aprovacao a @Thiago130126 apos aceite do convite.'
VerificarSaida 'Abertura do Pull Request de evidencias'
Write-Host "PR aberta: $PR" -ForegroundColor Green

Write-Host ''
Write-Host 'PROXIMAS ACOES OBRIGATORIAS:' -ForegroundColor Cyan
Write-Host '1. Thiago130126 aceita o convite e aprova a PR.'
Write-Host '2. Voce faz merge da PR apos a aprovacao.'
Write-Host '3. Tire print da recusa (log no arquivo docs/evidencias/03-tentativa-push-main.txt).'
Write-Host '4. Em Actions, execute Demonstracao de ambientes / production e aprove o job.'
Write-Host "5. Entregue: https://github.com/$FullRepo"
