// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Runner",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    dependencies: [
        // MLX Swift core packages
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.18.0"),
        
        // MLX Swift examples (includes MLXLLM for language models)
        .package(url: "https://github.com/ml-explore/mlx-swift-examples", branch: "main"),
    ],
    targets: [
        .target(
            name: "Runner",
            dependencies: [
                // Core MLX packages
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"),
                .product(name: "MLXOptimizers", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
                .product(name: "MLXFFT", package: "mlx-swift"),
                .product(name: "MLXLinalg", package: "mlx-swift"),
                
                // Language model support from examples
                .product(name: "MLXLLM", package: "mlx-swift-examples"),
                .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
            ]
        )
    ]
)