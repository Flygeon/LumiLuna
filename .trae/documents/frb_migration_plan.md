# Flutter Rust Bridge 接入与媒体扫描迁移计划

## 一、项目现状分析

### 1.1 已存在的基础结构

| 组件 | 状态 | 说明 |
|------|------|------|
| `pubspec.yaml` | ✅ 已配置 | 包含 `flutter_rust_bridge: 2.12.0` 和 `lumiluna_rust` 依赖 |
| `flutter_rust_bridge.yaml` | ✅ 已配置 | `rust_input: crate::api`, `rust_root: rust/`, `dart_output: lib/src/rust` |
| `rust/Cargo.toml` | ✅ 已配置 | `crate-type = ["cdylib", "staticlib"]`, `flutter_rust_bridge = "=2.12.0"` |
| `rust/src/lib.rs` | ✅ 已配置 | `pub mod api;`, `mod frb_generated;` |
| `rust/src/api/mod.rs` | ✅ 已配置 | `pub mod media_scan;`, `pub fn init_app()` |
| `rust/src/api/media_scan.rs` | ✅ 已有基础实现 | 包含 `RustMediaItem` 和 `scan_media()` 函数 |
| `rust_builder/` | ✅ 已配置 | Windows/Android/iOS/Linux/macOS 构建脚本 |
| `lib/src/rust/` | ❌ 不存在 | FRB 代码生成目标目录为空 |

### 1.2 当前 Dart 媒体扫描流程

```
MediaScannerService.scan(folders)
  ├── compute(_scanIsolate, folders)        // Isolate 中遍历文件系统
  │     └── _walk() -> List<MediaItem>
  └── _enrichAudioMetadataParallel(items)   // 并行解析音频元数据
        └── compute(_processAudioChunk, args) -> 写入 Drift
```

### 1.3 需要实现的功能

| 功能 | 优先级 | 说明 |
|------|--------|------|
| FRB 环境变量配置 | 高 | 添加 `flutter_rust_bridge_codegen` 到 PATH |
| FRB 代码生成 | 高 | 生成 Dart 绑定代码 |
| Rust ping 函数 | 高 | 用于验证 Rust 链路可用性 |
| Rust 稳定 hash | 高 | 用于文件路径去重 |
| Rust 媒体扫描 | 高 | 目录遍历 + 文件类型识别 |
| Flutter 批量接收 | 高 | 接收 Rust 结果并写入 Drift |
| 回退机制 | 高 | Rust 失败时回退到 Dart |
| Windows 构建链路 | 高 | 确保 Windows 编译通过 |
| Android 构建链路 | 高 | 确保 Android 编译通过 |
| Rust 单元测试 | 中 | 测试扫描和 hash 逻辑 |
| Flutter 单元测试 | 中 | 测试扫描服务和回退 |
| 跨语言对照测试 | 中 | 验证 Rust/Dart 结果一致性 |

---

## 二、实施步骤

### 阶段一：环境配置（Step 1-2）

#### Step 1：检查 Rust 工具链并配置环境变量

**目标：** 确保 Rust 工具链可用，并添加 `flutter_rust_bridge_codegen` 到环境变量

**操作：**
1. 检查 `cargo` 和 `rustc` 是否安装
2. 将 `C:\Users\Admin\Flutter\flutter_rust_bridge_codegen.exe` 添加到系统 PATH
3. 安装 Android 目标：`rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android`
4. 配置 `ANDROID_NDK_HOME` 环境变量

**影响文件：**
- 系统环境变量（PATH, ANDROID_NDK_HOME）

#### Step 2：安装 Rust 依赖并验证构建

**目标：** 确保 Rust crate 能正常编译

**操作：**
1. 进入 `rust/` 目录，运行 `cargo build`（Windows）
2. 验证 `rust_builder/windows/CMakeLists.txt` 配置正确

**影响文件：**
- `rust/Cargo.lock`（自动生成）

---

### 阶段二：FRB 代码生成（Step 3-4）

#### Step 3：更新 Rust API 层

**目标：** 添加 ping、hash 和完善媒体扫描函数

**操作：**
1. 修改 `rust/src/api/mod.rs`：导出新函数
2. 修改 `rust/src/api/media_scan.rs`：
   - 添加 `#[derive(frb)]` 宏到 `RustMediaItem`
   - 添加 `ping()` 函数（返回 "pong"）
   - 添加 `stable_hash(path: String) -> u64` 函数（使用 xxhash 或 sha2）
   - 完善 `scan_media()` 函数签名

**新增依赖：**
- `xxhash-rust` 或 `sha2`（用于稳定 hash）

**影响文件：**
- `rust/Cargo.toml`（添加依赖）
- `rust/src/api/mod.rs`
- `rust/src/api/media_scan.rs`

#### Step 4：运行 FRB 代码生成

**目标：** 生成 Dart 绑定代码到 `lib/src/rust/`

**操作：**
1. 运行命令：`flutter_rust_bridge_codegen generate`
2. 验证生成的文件：
   - `lib/src/rust/bridge_definitions.dart`
   - `lib/src/rust/frb_generated.dart`
   - `rust/src/frb_generated.rs`

**影响文件：**
- `lib/src/rust/`（新增目录和文件）
- `rust/src/frb_generated.rs`（自动生成）

---

### 阶段三：Flutter 集成（Step 5-7）

#### Step 5：创建 Rust 扫描服务封装

**目标：** 在 Flutter 端封装 Rust 调用，提供统一接口

**操作：**
1. 创建 `lib/services/rust_scanner_service.dart`：
   - 初始化 Rust 桥接
   - 封装 `ping()`、`stableHash()`、`scanMedia()` 方法
   - 添加错误处理和日志

**影响文件：**
- `lib/services/rust_scanner_service.dart`（新建）

#### Step 6：修改 MediaScannerService 支持双模式

**目标：** 保留现有 Dart 实现，添加 Rust 模式并支持回退

**操作：**
1. 修改 `lib/services/media_scanner_service.dart`：
   - 添加 `scanWithRust(List<String> folders)` 方法
   - 修改 `scan()` 方法：优先使用 Rust，失败时回退到 Dart
   - 添加 `useRustScanning` 配置开关

**影响文件：**
- `lib/services/media_scanner_service.dart`

#### Step 7：批量接收结果并写入 Drift

**目标：** 优化大量媒体文件的处理性能

**操作：**
1. 修改 `lib/services/database/app_database.dart`：
   - 添加批量 upsert 方法（使用 batch）
2. 在 `MediaScannerService` 中：
   - 将 Rust 返回的结果分批写入数据库
   - 保持音频元数据解析逻辑不变（仍使用 Dart 的 `_enrichAudioMetadataParallel`）

**影响文件：**
- `lib/services/database/app_database.dart`
- `lib/services/media_scanner_service.dart`

---

### 阶段四：构建链路验证（Step 8-9）

#### Step 8：验证 Windows 构建

**目标：** 确保 Windows 平台能正常编译和运行

**操作：**
1. 运行 `flutter build windows`
2. 验证生成的可执行文件能启动并扫描媒体

**影响文件：**
- `windows/CMakeLists.txt`（如需要调整）

#### Step 9：验证 Android 构建

**目标：** 确保 Android 平台能正常编译

**操作：**
1. 运行 `flutter build apk`
2. 检查 `rust_builder/android/build.gradle` 配置
3. 确保 NDK 版本兼容

**影响文件：**
- `rust_builder/android/build.gradle`（如需要调整）

---

### 阶段五：测试覆盖（Step 10-12）

#### Step 10：添加 Rust 单元测试

**目标：** 测试 Rust 端的核心功能

**操作：**
1. 创建 `rust/src/api/media_scan_test.rs`：
   - 测试 `ping()` 返回 "pong"
   - 测试 `stable_hash()` 的一致性
   - 测试 `scan_media()` 的基本扫描功能（使用临时目录）

**影响文件：**
- `rust/src/api/media_scan_test.rs`（新建）

#### Step 11：添加 Flutter 单元测试

**目标：** 测试 Flutter 端的扫描服务和回退机制

**操作：**
1. 创建 `test/rust_scanner_test.dart`：
   - 测试 Rust 桥接初始化
   - 测试 `ping()` 调用
   - 测试回退机制（模拟 Rust 失败时使用 Dart）

**影响文件：**
- `test/rust_scanner_test.dart`（新建）

#### Step 12：添加跨语言对照测试

**目标：** 验证 Rust 和 Dart 扫描结果的一致性

**操作：**
1. 创建 `test/cross_language_scan_test.dart`：
   - 使用相同的测试目录分别调用 Rust 和 Dart 扫描
   - 验证返回的文件数量和路径一致
   - 验证 hash 结果一致

**影响文件：**
- `test/cross_language_scan_test.dart`（新建）

---

## 三、文件变更清单

### 新增文件

| 文件路径 | 说明 |
|----------|------|
| `lib/src/rust/bridge_definitions.dart` | FRB 自动生成 |
| `lib/src/rust/frb_generated.dart` | FRB 自动生成 |
| `lib/services/rust_scanner_service.dart` | Rust 扫描服务封装 |
| `rust/src/frb_generated.rs` | FRB 自动生成 |
| `rust/src/api/media_scan_test.rs` | Rust 单元测试 |
| `test/rust_scanner_test.dart` | Flutter 单元测试 |
| `test/cross_language_scan_test.dart` | 跨语言对照测试 |

### 修改文件

| 文件路径 | 修改内容 |
|----------|----------|
| `rust/Cargo.toml` | 添加 xxhash 依赖 |
| `rust/src/api/mod.rs` | 导出新函数 |
| `rust/src/api/media_scan.rs` | 添加 frb 宏、ping、hash 函数 |
| `lib/services/media_scanner_service.dart` | 添加 Rust 模式和回退 |
| `lib/services/database/app_database.dart` | 添加批量 upsert |

---

## 四、风险与注意事项

### 4.1 构建风险

| 风险 | 应对措施 |
|------|----------|
| Rust 工具链未安装 | 先检查并安装 rustup |
| Android NDK 版本不兼容 | 使用与 Flutter 推荐版本匹配的 NDK |
| Windows 编译失败 | 确保安装了 Visual Studio Build Tools |

### 4.2 兼容性风险

| 风险 | 应对措施 |
|------|----------|
| FRB 版本不匹配 | 确保 Dart 和 Rust 端使用相同版本（2.12.0） |
| 序列化失败 | 使用 `#[derive(frb)]` 宏并检查类型兼容性 |
| 大量数据传输内存压力 | 分批处理，避免一次性传输所有结果 |

### 4.3 功能风险

| 风险 | 应对措施 |
|------|----------|
| Rust 扫描结果与 Dart 不一致 | 添加跨语言对照测试 |
| 权限问题（Android） | 使用 `MediaPermissionService` 请求权限 |
| 符号链接处理 | 保持与 Dart 实现一致的处理方式 |

---

## 五、验证标准

### 功能验证

- [ ] `ping()` 返回 "pong"
- [ ] `stable_hash()` 对相同路径返回相同值
- [ ] Rust 扫描能发现媒体文件
- [ ] Flutter 能接收并显示 Rust 扫描结果
- [ ] 音频元数据解析正常（回退到 Dart 的解析逻辑）
- [ ] 结果正确写入 Drift 数据库
- [ ] Rust 失败时自动回退到 Dart

### 构建验证

- [ ] `flutter build windows` 成功
- [ ] `flutter build apk` 成功
- [ ] 应用能正常启动

### 测试验证

- [ ] Rust 单元测试通过
- [ ] Flutter 单元测试通过
- [ ] 跨语言对照测试通过
