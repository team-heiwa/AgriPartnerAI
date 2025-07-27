# AgriPartner AI バックエンド

このバックエンドサービスは、Google Cloud Storage (GCS) から音声・画像ファイルを取得し、Google Vertex AI を使用して大規模言語モデル (LLM) で処理するパイプラインを提供します。

## 概要

パイプラインは以下の流れで処理を行います：
1. GCS からメディアファイル（音声/画像）を取得
2. LLM での処理に適した形式に前処理
3. Vertex AI (Gemini) に送信して解析
4. 処理結果を GCS に保存

## プロジェクト構成

```
backend/
├── src/
│   ├── gcs/              # Google Cloud Storage 操作
│   ├── processors/       # メディア前処理（音声/画像）
│   ├── llm/             # Vertex AI / LLM 統合
│   ├── pipeline/        # メインパイプライン制御
│   └── utils/           # 共通ユーティリティとロギング
├── examples/            # 使用例スクリプト
├── tests/              # ユニット・統合テスト
├── docker/             # Docker 設定
├── pyproject.toml      # パッケージ依存関係（uv で管理）
├── ruff.toml          # Python リント設定
└── .env.example       # 環境変数テンプレート
```

## 前提条件

- Python 3.11 以上
- 課金が有効な Google Cloud プロジェクト
- 適切な権限を持つサービスアカウント
- ffmpeg（pydub での音声処理に必要）

## セットアップ

1. **リポジトリをクローンしてバックエンドに移動**
   ```bash
   cd AgriPartnerAI/backend
   ```

2. **uv を使用して依存関係をインストール**
   ```bash
   uv sync
   ```

3. **環境変数を設定**
   ```bash
   cp .env.example .env
   # .env ファイルを編集して設定を記入
   ```

4. **Google Cloud 認証を設定**
   ```bash
   # オプション 1: サービスアカウントキーファイル
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
   
   # オプション 2: gcloud auth を使用（開発用）
   gcloud auth application-default login
   ```

5. **GCP リソースを作成（未作成の場合）**
   ```bash
   cd ../infra/terraform
   terraform init
   terraform apply
   ```

## 設定

主要な環境変数：

- `GCP_PROJECT_ID`: Google Cloud プロジェクト ID
- `GCS_INPUT_BUCKET`: 入力メディアファイル用バケット
- `GCS_OUTPUT_BUCKET`: 処理結果用バケット
- `VERTEX_AI_MODEL`: 使用する LLM モデル（デフォルト: gemini-1.5-flash）
- `MAX_IMAGE_SIZE_MB`: 最大画像サイズ（MB）
- `MAX_AUDIO_DURATION_SECONDS`: 最大音声長（秒）

## 使用方法

### 基本的な例

```python
from src.pipeline import Pipeline

# パイプラインを初期化
pipeline = Pipeline()

# 画像を処理
result = await pipeline.process_image(
    bucket="my-input-bucket",
    file_path="images/photo.jpg",
    prompt="この画像に何が写っているか説明してください"
)

# 音声を処理
result = await pipeline.process_audio(
    bucket="my-input-bucket", 
    file_path="audio/recording.mp3",
    prompt="この音声を文字起こししてください"
)
```

### サンプルの実行

```bash
# 画像処理のサンプルを実行
uv run python examples/process_image.py

# 音声処理のサンプルを実行
uv run python examples/process_audio.py
```

## 開発

### コード品質

```bash
# リントを実行
uv run ruff check .

# コードをフォーマット
uv run ruff format .

# テストを実行
uv run pytest
```

### プロジェクトコマンド

```bash
# 開発用依存関係をインストール
uv sync --dev

# 新しい依存関係を追加
uv add package-name

# 依存関係を更新
uv lock --upgrade
```

## Docker サポート

Docker でビルド・実行：

```bash
# イメージをビルド
docker build -t agripartner-backend .

# コンテナを実行
docker run --env-file .env agripartner-backend
```

## API リファレンス

### Pipeline クラス

メディアファイル処理のメインオーケストレーター。

```python
class Pipeline:
    async def process_image(bucket: str, file_path: str, prompt: str) -> dict
    async def process_audio(bucket: str, file_path: str, prompt: str) -> dict
    async def process_batch(items: List[MediaItem]) -> List[dict]
```

### GCS クライアント

Google Cloud Storage の操作を処理。

```python
class GCSClient:
    async def download_file(bucket: str, file_path: str) -> bytes
    async def upload_file(bucket: str, file_path: str, content: bytes) -> str
    async def list_files(bucket: str, prefix: str) -> List[str]
```

### プロセッサー

メディア前処理ユーティリティ。

```python
class ImageProcessor:
    async def process(image_bytes: bytes) -> ProcessedImage
    
class AudioProcessor:
    async def process(audio_bytes: bytes) -> ProcessedAudio
```

## トラブルシューティング

### よくある問題

1. **インポートエラー**: スクリプトを実行する際は `uv run` を使用していることを確認
2. **ffmpeg が見つからない**: 音声処理のために ffmpeg をインストール
3. **認証エラー**: GOOGLE_APPLICATION_CREDENTIALS のパスを確認
4. **バケットアクセス拒否**: サービスアカウントの権限を確認

### ロギング

詳細なログを有効化：
```bash
export LOG_LEVEL=DEBUG
```

## ライセンス

[ライセンスをここに記載]