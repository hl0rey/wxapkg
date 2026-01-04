# GitHub Actions Workflows

本项目包含多个 GitHub Actions workflows 用于自动化构建、测试和发布。

## 📋 Workflows 列表

### 1. Release Workflow (`release.yml`)

**触发条件**: 推送版本标签（如 `v1.0.0`）

**功能**:
- 自动创建 GitHub Release
- 编译 Windows 和 macOS 版本
- 上传编译好的二进制文件到 Release

**支持平台**:
- Windows (amd64)
- macOS (amd64 - Intel)
- macOS (arm64 - Apple Silicon)

**使用方法**:
```bash
# 1. 确保代码已提交
git add .
git commit -m "Release v1.0.0"

# 2. 创建并推送标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 3. GitHub Actions 会自动触发，编译并发布
```

---

### 2. Test Workflow (`test.yml`)

**触发条件**: 
- 推送到 main/master/develop 分支
- 创建 Pull Request

**功能**:
- 在多个操作系统上测试（Ubuntu, macOS, Windows）
- 测试多个 Go 版本（1.19, 1.20, 1.21）
- 运行代码检查（`go vet`, `go fmt`）
- 运行单元测试
- 上传测试覆盖率到 Codecov
- 验证所有平台的编译

**矩阵测试**:
- OS: Ubuntu, macOS, Windows
- Go: 1.19, 1.20, 1.21
- 平台: windows/amd64, darwin/amd64, darwin/arm64, linux/amd64, linux/arm64

---

### 3. GoReleaser Workflow (`goreleaser.yml`)

**触发条件**: 推送版本标签（如 `v1.0.0`）

**功能**:
- 使用 GoReleaser 自动化发布流程
- 根据 `.goreleaser.yml` 配置编译多平台版本
- 自动生成 changelog
- 创建 GitHub Release

**优势**:
- 配置简单，功能强大
- 自动生成 changelog
- 支持更多自定义选项

**注意**: 此 workflow 与 `release.yml` 二选一使用

---

## 🚀 如何发布新版本

### 方式 1: 使用 release.yml（推荐新手）

```bash
# 1. 更新版本号（可选，在 main.go 中）
# var version = "v1.0.0"

# 2. 提交代码
git add .
git commit -m "chore: prepare for v1.0.0 release"
git push

# 3. 创建标签并推送
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 4. 等待 GitHub Actions 完成
# 访问 https://github.com/你的用户名/wxapkg/actions 查看进度
```

### 方式 2: 使用 goreleaser.yml（推荐高级用户）

```bash
# 1. 确保 .goreleaser.yml 配置正确

# 2. 创建标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 3. GoReleaser 会自动处理一切
```

### 方式 3: 本地使用 GoReleaser

```bash
# 安装 GoReleaser
go install github.com/goreleaser/goreleaser@latest

# 测试发布（不会真正发布）
goreleaser release --snapshot --clean

# 正式发布
git tag -a v1.0.0 -m "Release v1.0.0"
goreleaser release --clean
```

---

## 📊 工作流程图

```
推送标签 v1.0.0
    │
    ├─→ release.yml
    │   ├─→ 创建 Release
    │   ├─→ 编译 Windows (amd64)
    │   ├─→ 编译 macOS (amd64)
    │   ├─→ 编译 macOS (arm64)
    │   └─→ 上传所有文件到 Release
    │
    └─→ goreleaser.yml (可选)
        └─→ 使用 GoReleaser 完成所有步骤

推送代码 / PR
    │
    └─→ test.yml
        ├─→ 多平台测试
        ├─→ 代码检查
        ├─→ 单元测试
        └─→ 编译验证
```

---

## 🔧 自定义配置

### 修改支持的平台

编辑 `release.yml`:

```yaml
strategy:
  matrix:
    include:
      - goos: windows
        goarch: amd64
      - goos: darwin
        goarch: amd64
      - goos: darwin
        goarch: arm64
      - goos: linux    # 添加 Linux 支持
        goarch: amd64
```

### 修改 Go 版本

编辑任意 workflow 文件:

```yaml
- name: Set up Go
  uses: actions/setup-go@v5
  with:
    go-version: '1.21'  # 修改版本号
```

### 添加编译参数

编辑 `release.yml`:

```yaml
run: |
  go build -trimpath \
    -ldflags "-s -w -X main.version=${{ needs.release.outputs.version }}" \
    -tags "netgo" \  # 添加 build tags
    -o wxapkg .
```

---

## 🐛 故障排查

### 问题 1: Release 创建失败

**原因**: 可能是权限问题

**解决**:
1. 确保仓库设置中启用了 Actions
2. 检查 `Settings > Actions > General > Workflow permissions`
3. 选择 "Read and write permissions"

### 问题 2: 编译失败

**原因**: 依赖下载失败或代码错误

**解决**:
1. 检查 Actions 日志
2. 本地运行 `go build` 验证
3. 确保 `go.mod` 和 `go.sum` 已提交

### 问题 3: 标签推送后没有触发

**原因**: 标签格式不匹配

**解决**:
- 确保标签以 `v` 开头，如 `v1.0.0`
- 不要使用 `1.0.0` 这样的格式

### 问题 4: 多个 Release Workflows 冲突

**原因**: `release.yml` 和 `goreleaser.yml` 同时运行

**解决**:
- 二选一，删除或禁用其中一个
- 推荐使用 `goreleaser.yml`（功能更强大）

---

## 📝 最佳实践

1. **版本号规范**: 使用语义化版本 (Semantic Versioning)
   - `v1.0.0` - 主版本
   - `v1.1.0` - 次版本
   - `v1.1.1` - 补丁版本

2. **提交信息规范**: 使用约定式提交 (Conventional Commits)
   - `feat: 添加新功能`
   - `fix: 修复 bug`
   - `docs: 更新文档`
   - `chore: 构建/工具链变更`

3. **发布前检查**:
   - ✅ 所有测试通过
   - ✅ 代码已经 review
   - ✅ 文档已更新
   - ✅ CHANGELOG 已更新

4. **标签管理**:
   ```bash
   # 查看所有标签
   git tag
   
   # 删除本地标签
   git tag -d v1.0.0
   
   # 删除远程标签
   git push origin :refs/tags/v1.0.0
   ```

---

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GoReleaser 文档](https://goreleaser.com/)
- [语义化版本](https://semver.org/lang/zh-CN/)
- [约定式提交](https://www.conventionalcommits.org/zh-hans/)

---

## 💡 提示

- 首次发布建议使用 `v0.1.0` 作为起始版本
- 可以在 Actions 页面手动触发 workflow（如果配置了 `workflow_dispatch`）
- 发布前建议先在本地测试编译：`./build.sh all`

