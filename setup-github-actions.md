# GitHub Actions セットアップガイド

## 1. Workload Identity Federationの設定

### ステップ1: GitHubリポジトリ情報の更新
`infra/terraform/github_actions.tf` の以下の行を編集してください：

```hcl
# 行100付近
member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/YOUR_GITHUB_USERNAME/AgriPartnerAI"
```

`YOUR_GITHUB_USERNAME` を実際のGitHubユーザー名に置き換えてください。

### ステップ2: Terraformでリソース作成

```bash
cd infra/terraform
terraform apply
```

### ステップ3: 出力値の確認

```bash
terraform output wif_provider
terraform output wif_service_account
```

## 2. GitHub Secretsの設定

GitHubリポジトリの設定 → Secrets and variables → Actions で以下のシークレットを追加：

### 必要なSecrets:
- `WIF_PROVIDER`: terraform outputの `wif_provider` の値
- `WIF_SERVICE_ACCOUNT`: terraform outputの `wif_service_account` の値

### 例:
```
WIF_PROVIDER: projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider
WIF_SERVICE_ACCOUNT: github-actions-dev@agripartnerai.iam.gserviceaccount.com
```

## 3. 有効なワークフロー

### Cloud Functions デプロイ
- **トリガー**: `backend/functions/` 内のファイル変更
- **ファイル**: `.github/workflows/deploy-functions.yml`

### Backend API デプロイ  
- **トリガー**: `backend/` 内のファイル変更（functions除く）
- **ファイル**: `.github/workflows/deploy-backend.yml`

### Infrastructure デプロイ
- **トリガー**: `infra/terraform/` 内のファイル変更
- **ファイル**: `.github/workflows/deploy-infrastructure.yml`

## 4. テスト方法

1. `backend/functions/main.py` にコメントを追加
2. GitHubにpush
3. Actions タブでワークフローの実行を確認

## 5. 注意事項

- mainブランチにpushした時のみ自動デプロイされます
- 手動実行も可能（Actions → workflow → Run workflow）
- エラーが発生した場合はActionsログを確認してください