# fargate-ecs-app
Deploying ECS Application with Fargate

## GitHub Actions promotion flow

Environment-specific Terraform variable files are available in the [environments](environments) folder:
- [environments/development.tfvars](environments/development.tfvars)
- [environments/staging.tfvars](environments/staging.tfvars)
- [environments/production.tfvars](environments/production.tfvars)

The repository now uses a promotion model where:
- pull requests are only allowed from development to staging
- pull requests are only allowed from staging to production
- staging and production deployments require manual approval through GitHub Environments

The workflow definitions are in [.github/workflows/deploy-ecr.yml](.github/workflows/deploy-ecr.yml) and [.github/workflows/promote-environments.yml](.github/workflows/promote-environments.yml).

The database password should be supplied from GitHub secrets during deployment, rather than stored in the repository. Recommended secrets:
- `DEV_DATABASE_PASSWORD`
- `STAGING_DATABASE_PASSWORD`
- `PROD_DATABASE_PASSWORD`

## GitHub Actions ECR deployment

A workflow is included at [.github/workflows/deploy-ecr.yml](.github/workflows/deploy-ecr.yml) to build and push the frontend and backend images to Amazon ECR.

Set these repository secrets before enabling it:
- `AWS_ACCOUNT_ID`
- `AWS_ROLE_TO_ASSUME`

The workflow pushes both images with a `latest` tag and writes the resulting ECR image URIs to `terraform.tfvars` so Terraform uses the newest images on the next deployment.
