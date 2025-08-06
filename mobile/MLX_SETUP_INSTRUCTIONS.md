# MLX オンデバイス推論セットアップ

## 📋 概要
このドキュメントでは、Gemma 3n E4B MLXモデルを使用したオフライン推論を有効にする手順を説明します。

## 実装ファイル

- `ios/Runner/GemmaMLXHandler.swift` - MLX推論ハンドラー
- `ios/Runner/SimplifiedMLXHandler.swift` - 簡易版 (MLXパッケージ不要)
- `lib/services/gemma_mlx_native_service.dart` - Flutterサービス
- `lib/screens/mlx_test/mlx_test_screen.dart` - テスト画面
- `download_mlx_model.sh` - モデルダウンロード

## 🚀 セットアップ手順

### ステップ 1: Xcodeでファイルを追加

1. Xcodeでプロジェクトを開く:
```bash
open ios/Runner.xcworkspace
```

2. **Runner**フォルダを右クリック → **Add Files to "Runner"**

3. 以下のファイルを追加:
   - `SimplifiedMLXHandler.swift` (まずはこれだけ)
   - `GemmaMLXHandler.swift` (MLXパッケージ追加後)

4. **✅ Copy items if needed** にチェック
5. **✅ Add to targets: Runner** にチェック

### ステップ 2: AppDelegate.swiftを確認

AppDelegate.swiftは既に設定済みです。

### ステップ 3: アプリをビルド＆実行

```bash
flutter run -d [device-id]
```

これで簡易版が動作します。MLXテスト画面で状態を確認できます。

## 🎯 完全なMLX実装を有効にする（オプション）

### ステップ 4: MLX Swiftパッケージを追加

1. Xcodeで **File → Add Package Dependencies**

2. 以下のパッケージを追加:
   - `https://github.com/ml-explore/mlx-swift`
   - `https://github.com/ml-explore/mlx-swift-examples`

3. 必要なライブラリを選択:
   - MLX, MLXNN, MLXOptimizers, MLXRandom
   - MLXLLM, MLXLMCommon (examples repoから)

### ステップ 5: GemmaMLXHandlerに切り替え

1. `GemmaMLXHandler.swift`をXcodeプロジェクトに追加

2. `AppDelegate.swift`を更新:
```swift
// SimplifiedMLXHandler を GemmaMLXHandler に変更
private var mlxHandler: GemmaMLXHandler?

// setupSimplifiedMLXChannel を setupMLXMethodChannel に変更
```

### ステップ 6: モデルをダウンロード

```bash
cd mobile
./download_mlx_model.sh
```

または、アプリ内のMLXテスト画面から「Download Model」をタップ

## 📱 動作要件

- **デバイス**: iPhone 14/15以上（6GB+ RAM）
- **iOS**: 17.0以上
- **ストレージ**: 約4GB（モデル用）
- **実機必須**: シミュレータ不可（Metal必須）

## 🧪 テスト方法

1. アプリを起動
2. メニューから「Test Screens」→「MLX On-Device Test」
3. 「Check Status」でモデル状態確認
4. 「Download Model」でモデル取得（初回のみ）
5. 「Test Agriculture」で農業アドバイス生成

## ⚠️ トラブルシューティング

### ビルドエラー: "Cannot find type 'GemmaMLXHandler'"
→ Swiftファイルがプロジェクトに追加されていません。ステップ1を確認

### エラー: "MLX packages not installed"
→ SimplifiedMLXHandlerが動作中。完全版にはステップ4-5が必要

### モデルダウンロードが失敗
→ git-lfsをインストール: `brew install git-lfs && git lfs install`

## 現在の状態

- SimplifiedMLXHandlerが有効（プレースホルダー）
- MLXパッケージ追加で完全版が利用可能

## 🔗 参考リンク

- [MLX Swift](https://github.com/ml-explore/mlx-swift)
- [MLX Examples](https://github.com/ml-explore/mlx-swift-examples)
- [Gemma 3n Model](https://huggingface.co/mlx-community/gemma-3n-E4B-it-lm-4bit)