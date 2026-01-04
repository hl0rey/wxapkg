# 编译指南

本项目提供了三种编译方式：Shell 脚本、批处理脚本和 Makefile，可根据你的操作系统和喜好选择使用。

## 📋 前置要求

- Go 1.19 或更高版本
- Git（用于获取 commit 信息）

## 🚀 快速开始

### macOS / Linux

```bash
# 方式1: 使用 Shell 脚本（推荐）
./build.sh current          # 编译当前平台
./build.sh all              # 编译所有平台

# 方式2: 使用 Makefile
make build                  # 编译当前平台
make build-all              # 编译所有平台
```

### Windows

```batch
REM 方式1: 使用批处理脚本（推荐）
build.bat current           REM 编译当前平台
build.bat all               REM 编译所有平台

REM 方式2: 使用 Makefile（需要安装 make）
make build                  REM 编译当前平台
make build-all              REM 编译所有平台
```

## 📖 详细用法

### 1. Shell 脚本 (build.sh)

适用于 macOS 和 Linux 系统。

#### 命令

```bash
./build.sh [命令] [选项]
```

| 命令 | 说明 |
|------|------|
| `current` | 编译当前平台（默认） |
| `all` | 编译所有平台 |
| `clean` | 清理编译产物 |
| `install` | 编译并安装到 GOPATH |
| `help` | 显示帮助信息 |

#### 示例

```bash
# 编译当前平台
./build.sh current
# 或直接运行
./build.sh

# 编译所有平台
./build.sh all

# 指定版本号编译
VERSION=v1.0.0 ./build.sh all

# 安装到本地
./build.sh install

# 清理编译产物
./build.sh clean
```

#### 输出

编译产物位于 `dist/` 目录：
```
dist/
├── wxapkg-windows-amd64.zip
├── wxapkg-darwin-amd64.tar.gz
├── wxapkg-darwin-arm64.tar.gz
├── wxapkg-linux-amd64.tar.gz
└── wxapkg-linux-arm64.tar.gz
```

---

### 2. 批处理脚本 (build.bat)

适用于 Windows 系统。

#### 命令

```batch
build.bat [命令]
```

| 命令 | 说明 |
|------|------|
| `current` | 编译当前平台（默认） |
| `all` | 编译所有平台 |
| `clean` | 清理编译产物 |
| `install` | 编译并安装到 GOPATH |
| `help` | 显示帮助信息 |

#### 示例

```batch
REM 编译当前平台
build.bat current

REM 编译所有平台
build.bat all

REM 指定版本号编译
set VERSION=v1.0.0
build.bat all

REM 安装到本地
build.bat install

REM 清理编译产物
build.bat clean
```

---

### 3. Makefile

适用于所有支持 `make` 的系统。

#### 命令

```bash
make [目标]
```

| 目标 | 说明 |
|------|------|
| `build` | 编译当前平台（默认） |
| `build-all` | 编译所有平台 |
| `install` | 编译并安装到 GOPATH |
| `clean` | 清理编译产物 |
| `test` | 运行测试 |
| `fmt` | 格式化代码 |
| `vet` | 代码检查 |
| `deps` | 更新依赖 |
| `run` | 运行程序 |
| `version` | 显示版本信息 |
| `help` | 显示帮助信息 |

#### 示例

```bash
# 编译当前平台
make build
# 或直接运行
make

# 编译所有平台
make build-all

# 指定版本号编译
VERSION=v1.0.0 make build-all

# 安装到本地
make install

# 运行程序（传递参数）
make run ARGS='scan --help'
make run ARGS='unpack -r /path/to/wxapkg'

# 代码检查和格式化
make fmt
make vet

# 运行测试
make test

# 清理
make clean
```

---

## 🎯 编译目标平台

所有编译脚本都支持以下平台：

| 平台 | 架构 | 文件名 |
|------|------|--------|
| Windows | amd64 | `wxapkg-windows-amd64.zip` |
| macOS (Intel) | amd64 | `wxapkg-darwin-amd64.tar.gz` |
| macOS (Apple Silicon) | arm64 | `wxapkg-darwin-arm64.tar.gz` |
| Linux | amd64 | `wxapkg-linux-amd64.tar.gz` |
| Linux | arm64 | `wxapkg-linux-arm64.tar.gz` |

---

## 🔧 自定义编译

### 设置版本号

所有脚本都支持通过环境变量设置版本号：

```bash
# macOS / Linux
VERSION=v1.0.0 ./build.sh all
VERSION=v1.0.0 make build-all

# Windows
set VERSION=v1.0.0
build.bat all
```

### 编译参数说明

编译时使用的参数：

- `-trimpath`: 移除文件系统路径
- `-ldflags="-s -w"`: 去除调试信息，减小文件大小
- `-X main.version`: 注入版本号
- `-X main.commit`: 注入 Git commit hash
- `CGO_ENABLED=0`: 禁用 CGO，生成纯静态二进制

---

## 📦 发布流程

使用 goreleaser 进行正式发布：

```bash
# 安装 goreleaser
go install github.com/goreleaser/goreleaser@latest

# 创建标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 发布
goreleaser release --clean
```

---

## ❓ 常见问题

### Q: 为什么编译后的文件很大？

A: 如果你使用的是开发版本的脚本，文件可能包含调试信息。使用 `build.sh`、`build.bat` 或 `Makefile` 编译会自动去除调试信息。

### Q: 如何交叉编译？

A: 所有脚本都支持交叉编译。使用 `all` 命令即可编译所有平台。

### Q: Windows 上无法执行 Makefile 怎么办？

A: 可以使用 `build.bat` 脚本，或者安装 [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm) 或使用 WSL。

### Q: 编译失败提示权限错误？

A: 
- macOS/Linux: 确保脚本有执行权限 `chmod +x build.sh`
- Windows: 以管理员身份运行命令提示符

### Q: 如何验证编译是否成功？

A: 运行编译后的程序查看版本：
```bash
./dist/wxapkg-*/wxapkg --version
```

---

## 🛠️ 开发模式

开发时推荐使用以下命令：

```bash
# 快速编译当前平台
go build -o wxapkg .

# 运行
./wxapkg scan

# 或直接运行（不生成二进制）
go run . scan
```

---

## 📝 注意事项

1. 首次编译会下载依赖，可能需要较长时间
2. 编译所有平台需要较多磁盘空间（约 50MB）
3. 确保网络连接正常，以便下载 Go 模块
4. 建议在编译前运行 `git commit` 以获取正确的 commit hash

---

## 📄 许可证

本编译脚本与项目本体使用相同的许可证。

