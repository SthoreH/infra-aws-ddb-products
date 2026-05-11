# tpl-infra-aws-ddb

Template repository da SthoreH para **infraestrutura pura** AWS (Terraform-only) — sem código de aplicação. Esse template específico parte de uma tabela **DynamoDB** single-table com 3 GSIs e IAM policies RO/RW, mas a estrutura de pipeline serve para **qualquer** repo de infra: ECS clusters, EventBus, Cognito, IAM roles cross-account, Step Functions, etc.

Use **"Use this template" → "Create a new repository"** no GitHub para gerar um novo repo de infra a partir desse esqueleto. Depois siga o checklist abaixo.

Para repos com **código de aplicação Lambda**, use [`tpl-app-aws-lbd-python`](https://github.com/SthoreH/tpl-app-aws-lbd-python) ou [`tpl-app-aws-lbd-nodejs`](https://github.com/SthoreH/tpl-app-aws-lbd-nodejs).

## Stack

- **IaC:** Terraform 1.14.8, AWS Provider 6.40.0, region `sa-east-1` (versão fixa em [.pipeline.yml](.pipeline.yml); o módulo externo `DanHenrique/terraform-aws-dynamodb@v1.2.2` pina exatamente 1.14.8)
- **Backend:** S3 partial config — bucket via `vars.TF_STATE_BUCKET`, key = `{repo-name}/terraform.tfstate`
- **CI/CD:** workflows reutilizáveis em [`shd-github-actions-workflows`](https://github.com/SthoreH/shd-github-actions-workflows) (pin atual: `@v1.6.0`)
- **Módulos exemplo neste template:** [`terraform-aws-dynamodb`](https://github.com/DanHenrique/terraform-aws-dynamodb), [`shd-terraform-aws-iam`](https://github.com/SthoreH/shd-terraform-aws-iam)

> **Importante:** as peças `ci-infra-terraform.yml` / `cd-infra-terraform.yml` foram introduzidas em **`v1.6.0`** do `shd-github-actions-workflows`. Confirme que essa versão (ou superior) está publicada antes de usar este template.

## Layout

- [terraform-aws/](terraform-aws/) — IaC (DynamoDB + IAM policies templated). Adapte ao tipo de infra que vai provisionar.
  - [terraform-aws/environments/](terraform-aws/environments/) — `dev.tfvars`, `prod.tfvars`.
  - [terraform-aws/iam_templates/policies/](terraform-aws/iam_templates/policies/) — policies RO/RW templated com `account_id`, `table_name`.
- [.pipeline.yml](.pipeline.yml) — **single source of truth** para versão Terraform, paths e por-ambiente.
- [.github/workflows/](.github/workflows/) — caller workflows (CI, CD, rollback, destroy). Lógica vive nos reusable workflows do shd.
- [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/) — templates de rollback/destroy.
- [.github/rulesets/](.github/rulesets/) — branch/tag protection (importar manualmente no GitHub).
- [.claude/](.claude/) — `CLAUDE.md` + `rules/` (apenas `terraform.md` + `repository.md`, sem `coding.md`/`testing.md`/`api-design.md`).

## Sobre a tabela (exemplo deste template)

Este template provisiona uma DynamoDB single-table:

| Atributo      | Tipo   | Papel                                      |
|---------------|--------|--------------------------------------------|
| `PK` / `SK`   | String | Chave primária composta                    |
| `GSI1PK/SK`, `GSI2PK/SK`, `entityType/createdAt` | String | 3 GSIs para padrões alternativos |
| `expiresAt`   | Number | TTL                                        |

- **Billing mode:** `PAY_PER_REQUEST`
- **Deletion protection:** `false` em dev, `true` em prod

Adapte (ou substitua inteiro) `terraform-aws/dynamo.tf` conforme o caso de uso real.

## Checklist de customização

Procure por `TODO` em todos os arquivos: `grep -rn "TODO" . --exclude-dir=.git`

1. **Renomear o repo** para `infra-aws-<recurso>-<dominio>` (ex.: `infra-aws-ddb-orders`, `infra-aws-ecs-cluster-prod`).
2. [`.claude/CLAUDE.md`](.claude/CLAUDE.md) — substituir nome do repositório e descrição.
3. [`.pipeline.yml`](.pipeline.yml) — preencher `environments.dev.role-arn` e `environments.prod.role-arn` com os ARNs OIDC reais.
4. [`terraform-aws/locals.tf`](terraform-aws/locals.tf) — definir `table_name` (ou substituir esses locals pelo que fizer sentido para o recurso real) e `Repository` URL.
5. [`terraform-aws/dynamo.tf`](terraform-aws/dynamo.tf) — adaptar (ou trocar) os recursos para o que vai provisionar.
6. [`terraform-aws/iam.tf`](terraform-aws/iam.tf) — manter, ajustar ou remover as policies RO/RW conforme necessidade.
7. [`terraform-aws/environments/dev.tfvars`](terraform-aws/environments/dev.tfvars) e `prod.tfvars` — variáveis específicas do ambiente.
8. [`.github/workflows/*`](.github/workflows/) — pins padronizados em `@v1.6.0`. Confirmar que a versão está publicada em [`shd-github-actions-workflows`](https://github.com/SthoreH/shd-github-actions-workflows) e bumpar se houver versão mais nova.

## Configuração no GitHub

Após customizar, no novo repo:

1. **GitHub Environments** — criar `dev` e `prod` em `Settings → Environments`. Em cada um, definir:
   - `vars.AWS_ROLE_ARN` — ARN da role OIDC para deploy.
   - `vars.TF_STATE_BUCKET` — bucket S3 do backend Terraform.
2. **Rulesets** — importar [`.github/rulesets/branches.ruleset.json`](.github/rulesets/branches.ruleset.json) e [`.github/rulesets/tags.ruleset.json`](.github/rulesets/tags.ruleset.json) em `Settings → Rules → Rulesets → New ruleset → Import a ruleset`.
3. **OIDC trust** — a role configurada em `AWS_ROLE_ARN` precisa aceitar OIDC do GitHub para esse repo.

## Pipeline

- [ci-dev.yml](.github/workflows/ci-dev.yml), [ci-prod.yml](.github/workflows/ci-prod.yml) — PR validation (terraform fmt/validate/plan).
- [deploy-dev.yml](.github/workflows/deploy-dev.yml), [deploy-prod.yml](.github/workflows/deploy-prod.yml) — deploys em push para `dev`/`main`. `prod` adicionalmente roda semantic-release.
- [rollback.yml](.github/workflows/rollback.yml) — re-aplica numa tag anterior via issue rotulada.
- [destroy.yml](.github/workflows/destroy.yml) — destrói infra de `dev` via issue rotulada (prod só por CLI manual).

## Operações

**Rollback** — abrir issue com o [rollback request template](.github/ISSUE_TEMPLATE/rollback_request.yml) e aplicar o label `rollback-approved`.

**Destroy** — abrir issue com o [destroy request template](.github/ISSUE_TEMPLATE/destroy_request.yml) e aplicar o label `destroy-approved`. Restrito a `dev`.

## Verificação local pós-customização

```bash
# Terraform validate offline (sem credenciais)
cd terraform-aws && terraform init -backend=false && terraform validate

# Confirmar que sobraram só TODOs intencionais
cd ..
grep -rn "TODO" . --exclude-dir=.git
```
