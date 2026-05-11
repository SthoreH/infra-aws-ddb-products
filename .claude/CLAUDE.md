# Repo: <TODO: nome do repositório, ex.: infra-aws-ddb-orders>

<TODO: descrição em uma linha do que esse repo de infra provisiona (ex.: tabela DynamoDB orders, ECS cluster, EventBus, etc.)>

## Layout

- [terraform-aws/](../terraform-aws/) — IaC (recursos AWS + IAM policies templated).
- [.pipeline.yml](../.pipeline.yml) — pipeline configuration consumed by the shared workflows. **Single source of truth** for terraform version, paths, and per-env values. Do not hardcode any of these in workflows or rules.
- [.github/workflows/](../.github/workflows/) — caller workflows. Thin wrappers; logic lives upstream.

## Pipeline is delegated

CI/CD lives in [shd-github-actions-workflows](../../../shd/shd-github-actions-workflows/). Caller workflows here only invoke reusable workflows or composite actions there. **If a step needs to change, change it in shd and bump the pin.** Do not inline pipeline logic locally.

Current pin: `@v1.6.0` (versão que introduziu `ci-infra-terraform.yml` / `cd-infra-terraform.yml` — confirme que está publicada antes de aterrissar este repo).

## Granular rules

Topic-specific guidance lives in [.claude/rules/](rules/) — `terraform.md` e `repository.md`. Repos de infra pura **não têm** `coding.md`/`testing.md`/`api-design.md`.
