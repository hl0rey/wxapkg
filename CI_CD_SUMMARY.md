# GitHub Actions CI/CD 配置总结

## 📦 已创建的文件

### Workflow 文件（3个）

| 文件 | 功能 | 触发条件 |
|------|------|----------|
| `.github/workflows/release.yml` | 自动发布 | 推送 `v*` 标签 |
| `.github/workflows/test.yml` | 自动测试 | Push/PR 到主分支 |
| `.github/workflows/goreleaser.yml` | GoReleaser 发布 | 推送 `v*` 标签 |

### 文档文件（2个）

| 文件 | 说明 |
|------|------|
| `.github/workflows/README.md` | Workflows 详细文档 |
| `.github/RELEASE_GUIDE.md` | 快速发布指南 |

---

## 🎯 核心功能

### 1. Release Workflow (`release.yml`)

**特点**:
- ✅ 完全自动化的发布流程
- ✅ 支持 Windows 和 macOS（Intel + Apple Silicon）
- ✅ 自动创建 GitHub Release
- ✅ 自动上传编译好的二进制文件
- ✅ 自动生成发布说明

**工作流程**:
```
推送标签 v1.0.0
    ↓
创建 Release
    ↓
并行编译 3 个平台
    ├─ Windows (amd64)
    ├─ macOS (amd64)
    └─ macOS (arm64)
    ↓
上传到 GitHub Release
```

**产物**:
- `wxapkg-windows-amd64.zip`
- `wxapkg-darwin-amd64.tar.gz`
- `wxapkg-darwin-arm64.tar.gz`

---

### 2. Test Workflow (`test.yml`)

**特点**:
- ✅ 多操作系统测试（Ubuntu, macOS, Windows）
- ✅ 多 Go 版本测试（1.19, 1.20, 1.21）
- ✅ 代码质量检查（vet, fmt）
- ✅ 单元测试和覆盖率
- ✅ 所有平台编译验证

**矩阵测试**:
- 3 个操作系统 × 3 个 Go 版本 = 9 个测试任务
- 5 个平台编译验证

---

### 3. GoReleaser Workflow (`goreleaser.yml`)

**特点**:
- ✅ 使用 GoReleaser 工具
- ✅ 配置简单，功能强大
- ✅ 自动生成 changelog
- ✅ 与 `.goreleaser.yml` 配置文件配合

**注意**: 与 `release.yml` 二选一使用

---

## 🚀 使用方法

### 快速发布

```bash
# 1. 创建标签
git tag -a v1.0.0 -m "Release v1.0.0"

# 2. 推送标签
git push origin v1.0.0

# 3. 等待 GitHub Actions 完成（5-10分钟）

# 4. 访问 Releases 页面下载
```

### 查看构建状态

1. 访问仓库的 [Actions](https://github.com/wux1an/wxapkg/actions) 页面
2. 查看对应 workflow 的运行状态
3. 点击查看详细日志

---

## 📊 Workflow 对比

| 特性 | release.yml | goreleaser.yml | test.yml |
|------|-------------|----------------|----------|
| 自动发布 | ✅ | ✅ | ❌ |
| 多平台编译 | ✅ | ✅ | ✅ |
| 自动测试 | ❌ | ❌ | ✅ |
| Changelog | 手动 | 自动 | N/A |
| 配置复杂度 | 中 | 低 | 中 |
| 灵活性 | 高 | 中 | 高 |

### 推荐使用

- **新手**: `release.yml`（清晰明了）
- **高级用户**: `goreleaser.yml`（功能强大）
- **开发测试**: `test.yml`（持续集成）

---

## 🔧 配置说明

### 需要的仓库设置

1. **启用 Actions**
   - Settings > Actions > General
   - Allow all actions and reusable workflows

2. **设置权限**
   - Settings > Actions > General > Workflow permissions
   - 选择 "Read and write permissions"
   - 勾选 "Allow GitHub Actions to create and approve pull requests"

3. **（可选）添加 Secrets**
   - 如果需要发布到其他平台，在 Settings > Secrets 中添加

---

## 📝 版本号规范

使用语义化版本 (Semantic Versioning):

```
v主版本号.次版本号.修订号

v1.0.0 - 首个稳定版本
v1.1.0 - 添加新功能（向下兼容）
v1.1.1 - 修复 bug（向下兼容）
v2.0.0 - 重大更新（可能不兼容）
```

### 标签示例

```bash
# 开发版本
v0.1.0, v0.2.0, v0.3.0

# 稳定版本
v1.0.0, v1.1.0, v1.2.0

# 补丁版本
v1.0.1, v1.0.2, v1.1.1
```

---

## 🎯 CI/CD 流程图

```
开发者推送代码
    │
    ├─→ 推送到分支
    │   └─→ test.yml 触发
    │       ├─→ 多平台测试
    │       ├─→ 代码检查
    │       └─→ 编译验证
    │
    └─→ 推送标签 v*
        └─→ release.yml 或 goreleaser.yml 触发
            ├─→ 创建 Release
            ├─→ 编译所有平台
            ├─→ 打包压缩
            └─→ 上传到 GitHub
```

---

## 🐛 故障排查

### 问题 1: Actions 没有运行

**检查**:
- 仓库是否启用了 Actions
- 标签格式是否正确（必须是 `v*`）
- workflow 文件是否在 `main` 分支

### 问题 2: Release 创建失败

**原因**: 权限不足

**解决**: 
1. Settings > Actions > General
2. Workflow permissions 改为 "Read and write permissions"

### 问题 3: 编译失败

**检查**:
1. 查看 Actions 日志
2. 本地运行 `go build` 测试
3. 检查 `go.mod` 和 `go.sum`

### 问题 4: 上传失败

**原因**: 文件路径错误或文件不存在

**解决**: 检查编译步骤是否成功生成文件

---

## 📈 性能优化

### 加速编译

1. **使用缓存**:
```yaml
- name: Cache Go modules
  uses: actions/cache@v3
  with:
    path: ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```

2. **并行构建**:
- `release.yml` 已使用 `strategy.matrix` 实现并行

3. **减少依赖下载**:
```yaml
- name: Get dependencies
  run: go mod download
```

---

## 🔐 安全建议

1. **不要在 workflow 中硬编码敏感信息**
   - 使用 GitHub Secrets

2. **限制 workflow 权限**
   - 只授予必要的权限

3. **审查第三方 Actions**
   - 使用官方或知名的 Actions
   - 固定版本号（如 `@v4` 而不是 `@main`）

4. **保护分支**
   - Settings > Branches > Add rule
   - 要求 PR review
   - 要求状态检查通过

---

## 📚 扩展功能

### 添加 Linux 支持

在 `release.yml` 中添加：

```yaml
build-linux:
  name: Build Linux
  needs: release
  runs-on: ubuntu-latest
  strategy:
    matrix:
      arch: [amd64, arm64]
  steps:
    # ... 类似 macOS 的步骤
```

### 添加自动化测试

在 `test.yml` 中添加：

```yaml
- name: Run integration tests
  run: go test -v -tags=integration ./...
```

### 添加代码覆盖率报告

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: ./coverage.txt
```

---

## 🎉 下一步

1. **测试 workflow**
   ```bash
   git tag -a v0.1.0 -m "Test release"
   git push origin v0.1.0
   ```

2. **监控第一次运行**
   - 访问 Actions 页面
   - 查看详细日志
   - 修复可能的问题

3. **优化配置**
   - 根据实际需求调整
   - 添加更多平台支持
   - 完善测试覆盖

4. **更新文档**
   - 在 README 中说明如何下载
   - 添加安装指南
   - 更新 CHANGELOG

---

## 🔗 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GoReleaser 文档](https://goreleaser.com/)
- [Go 交叉编译](https://golang.org/doc/install/source#environment)
- [语义化版本](https://semver.org/lang/zh-CN/)

---

**创建时间**: 2025-01-04  
**状态**: ✅ 完成  
**维护**: 定期更新以适应新的 GitHub Actions 特性

