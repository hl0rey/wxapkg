# 🚀 GitHub Actions 快速参考

## 一键发布

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

等待 5-10 分钟，访问 [Releases](../../releases) 页面下载！

---

## 📋 Workflows 概览

| Workflow | 文件 | 触发 | 功能 |
|----------|------|------|------|
| **Release** | `release.yml` | 推送 `v*` 标签 | 编译并发布 Windows/macOS 版本 |
| **Test** | `test.yml` | Push/PR | 多平台测试和代码检查 |
| **GoReleaser** | `goreleaser.yml` | 推送 `v*` 标签 | 使用 GoReleaser 自动发布 |

---

## 🎯 选择哪个 Workflow？

### 推荐：release.yml
- ✅ 简单明了
- ✅ 完全控制
- ✅ 适合新手

### 高级：goreleaser.yml
- ✅ 功能强大
- ✅ 自动 changelog
- ✅ 配置简单

**注意**: 二选一使用，不要同时启用！

---

## 📦 发布产物

每次发布会自动生成：

- `wxapkg-windows-amd64.zip` (Windows 64位)
- `wxapkg-darwin-amd64.tar.gz` (macOS Intel)
- `wxapkg-darwin-arm64.tar.gz` (macOS Apple Silicon)

---

## 🔍 查看状态

1. 访问 [Actions](../../actions) 页面
2. 点击对应的 workflow run
3. 查看详细日志

---

## ⚙️ 首次设置

### 必须设置

1. **启用 Actions**
   - Settings > Actions > General
   - Allow all actions

2. **设置权限**
   - Settings > Actions > General > Workflow permissions
   - 选择 "Read and write permissions"

### 完成！

---

## 🐛 常见问题

| 问题 | 解决方案 |
|------|----------|
| 标签推送后没反应 | 确保标签以 `v` 开头 |
| Release 创建失败 | 检查 workflow 权限设置 |
| 编译失败 | 查看 Actions 日志，本地测试 `go build` |
| 想添加 Linux | 编辑 `release.yml` 添加 Linux 任务 |

---

## 📚 详细文档

- 📖 [Workflows 详细说明](.github/workflows/README.md)
- 🚀 [发布指南](.github/RELEASE_GUIDE.md)
- 📊 [CI/CD 总结](CI_CD_SUMMARY.md)

---

## 💡 提示

- 第一次发布使用 `v0.1.0`
- 使用语义化版本号
- 发布前本地测试：`./build.sh all`
- 查看 Actions 日志排查问题

---

**快速链接**:
- [Actions](../../actions) | [Releases](../../releases) | [Issues](../../issues)

