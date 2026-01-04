# 🚀 快速发布指南

## 一键发布新版本

```bash
# 1. 确保所有改动已提交
git status

# 2. 创建并推送标签（替换 x.y.z 为实际版本号）
git tag -a vx.y.z -m "Release vx.y.z"
git push origin vx.y.z

# 3. 完成！GitHub Actions 会自动：
#    ✓ 编译 Windows 和 macOS 版本
#    ✓ 创建 GitHub Release
#    ✓ 上传所有二进制文件
```

## 📋 发布检查清单

在创建标签前，确保：

- [ ] 所有代码已提交并推送
- [ ] 本地测试通过 (`go test ./...`)
- [ ] 本地编译成功 (`./build.sh all`)
- [ ] 更新了 CHANGELOG（如果有）
- [ ] 更新了版本号（在 `main.go` 中，可选）
- [ ] 文档已更新

## 🎯 版本号规则

使用[语义化版本](https://semver.org/lang/zh-CN/)：

- **主版本号** (v**1**.0.0): 不兼容的 API 修改
- **次版本号** (v1.**1**.0): 向下兼容的功能性新增
- **修订号** (v1.0.**1**): 向下兼容的问题修正

### 示例

```bash
# 首次发布
git tag -a v0.1.0 -m "Initial release"

# 添加新功能
git tag -a v0.2.0 -m "Add macOS support"

# 修复 bug
git tag -a v0.2.1 -m "Fix crash on empty directory"

# 重大更新
git tag -a v1.0.0 -m "First stable release"
```

## 🔄 撤销发布

如果发布出错，可以删除标签重新发布：

```bash
# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin :refs/tags/v1.0.0

# 在 GitHub 上手动删除 Release

# 重新创建正确的标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## 📊 查看发布状态

1. 访问 [Actions 页面](../../actions)
2. 查看 "Release" workflow 的运行状态
3. 等待所有任务完成（通常 5-10 分钟）
4. 访问 [Releases 页面](../../releases) 查看发布结果

## ⚠️ 常见问题

### Q: 标签推送后没有触发 workflow？

A: 确保标签以 `v` 开头，如 `v1.0.0`

### Q: Release 创建失败？

A: 检查仓库设置：
1. Settings > Actions > General
2. Workflow permissions 设置为 "Read and write permissions"

### Q: 编译失败？

A: 
1. 查看 Actions 日志找到具体错误
2. 本地运行 `go build` 验证代码
3. 确保所有依赖都在 `go.mod` 中

### Q: 想要添加 Linux 版本？

A: 编辑 `.github/workflows/release.yml`，添加 Linux 构建任务

## 🎉 发布后

- 在 Release 页面编辑发布说明
- 更新 README 中的版本号
- 通知用户新版本可用
- 在社交媒体分享（可选）

---

**提示**: 第一次发布建议使用 `v0.1.0`，等稳定后再发布 `v1.0.0`

