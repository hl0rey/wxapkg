.PHONY: all build build-all clean install help test fmt vet

# 项目信息
BINARY_NAME=wxapkg
VERSION?=v0.0.1
COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')

# Go 编译参数
GOBASE=$(shell pwd)
GOBIN=$(GOBASE)/bin
DIST_DIR=$(GOBASE)/dist
LDFLAGS=-s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT)

# 默认目标
all: build

# 编译当前平台
build:
	@echo ">>> 编译 $(BINARY_NAME) for $(shell go env GOOS)/$(shell go env GOARCH)..."
	@mkdir -p $(GOBIN)
	@CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -o $(GOBIN)/$(BINARY_NAME) .
	@echo ">>> 编译完成: $(GOBIN)/$(BINARY_NAME)"

# 编译所有平台
build-all: clean
	@echo ">>> 编译所有平台..."
	@echo "版本: $(VERSION)"
	@echo "提交: $(COMMIT)"
	@echo ""
	@$(MAKE) build-windows-amd64
	@$(MAKE) build-darwin-amd64
	@$(MAKE) build-darwin-arm64
	@$(MAKE) build-linux-amd64
	@$(MAKE) build-linux-arm64
	@echo ""
	@echo ">>> 所有平台编译完成！"
	@echo ""
	@echo "编译产物:"
	@ls -lh $(DIST_DIR)/*.{zip,tar.gz} 2>/dev/null | awk '{print "  " $$9 " (" $$5 ")"}' || true

# Windows
build-windows-amd64:
	@echo ">>> 编译 windows/amd64..."
	@mkdir -p $(DIST_DIR)/wxapkg-windows-amd64
	@CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "$(LDFLAGS)" -o $(DIST_DIR)/wxapkg-windows-amd64/$(BINARY_NAME).exe .
	@cd $(DIST_DIR)/wxapkg-windows-amd64 && zip -q ../wxapkg-windows-amd64.zip $(BINARY_NAME).exe
	@echo "✓ 完成: $(DIST_DIR)/wxapkg-windows-amd64.zip"

# macOS Intel
build-darwin-amd64:
	@echo ">>> 编译 darwin/amd64..."
	@mkdir -p $(DIST_DIR)/wxapkg-darwin-amd64
	@CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -trimpath -ldflags "$(LDFLAGS)" -o $(DIST_DIR)/wxapkg-darwin-amd64/$(BINARY_NAME) .
	@cd $(DIST_DIR)/wxapkg-darwin-amd64 && tar -czf ../wxapkg-darwin-amd64.tar.gz $(BINARY_NAME)
	@echo "✓ 完成: $(DIST_DIR)/wxapkg-darwin-amd64.tar.gz"

# macOS Apple Silicon
build-darwin-arm64:
	@echo ">>> 编译 darwin/arm64..."
	@mkdir -p $(DIST_DIR)/wxapkg-darwin-arm64
	@CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags "$(LDFLAGS)" -o $(DIST_DIR)/wxapkg-darwin-arm64/$(BINARY_NAME) .
	@cd $(DIST_DIR)/wxapkg-darwin-arm64 && tar -czf ../wxapkg-darwin-arm64.tar.gz $(BINARY_NAME)
	@echo "✓ 完成: $(DIST_DIR)/wxapkg-darwin-arm64.tar.gz"

# Linux
build-linux-amd64:
	@echo ">>> 编译 linux/amd64..."
	@mkdir -p $(DIST_DIR)/wxapkg-linux-amd64
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags "$(LDFLAGS)" -o $(DIST_DIR)/wxapkg-linux-amd64/$(BINARY_NAME) .
	@cd $(DIST_DIR)/wxapkg-linux-amd64 && tar -czf ../wxapkg-linux-amd64.tar.gz $(BINARY_NAME)
	@echo "✓ 完成: $(DIST_DIR)/wxapkg-linux-amd64.tar.gz"

build-linux-arm64:
	@echo ">>> 编译 linux/arm64..."
	@mkdir -p $(DIST_DIR)/wxapkg-linux-arm64
	@CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags "$(LDFLAGS)" -o $(DIST_DIR)/wxapkg-linux-arm64/$(BINARY_NAME) .
	@cd $(DIST_DIR)/wxapkg-linux-arm64 && tar -czf ../wxapkg-linux-arm64.tar.gz $(BINARY_NAME)
	@echo "✓ 完成: $(DIST_DIR)/wxapkg-linux-arm64.tar.gz"

# 安装到 GOPATH
install:
	@echo ">>> 安装 $(BINARY_NAME)..."
	@go install -trimpath -ldflags "$(LDFLAGS)" .
	@echo ">>> 安装完成！"
	@echo "安装位置: $$(which $(BINARY_NAME))"
	@$(BINARY_NAME) --version

# 清理编译产物
clean:
	@echo ">>> 清理编译产物..."
	@rm -rf $(GOBIN) $(DIST_DIR)
	@echo ">>> 清理完成"

# 运行测试
test:
	@echo ">>> 运行测试..."
	@go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

# 代码格式化
fmt:
	@echo ">>> 格式化代码..."
	@go fmt ./...
	@echo ">>> 格式化完成"

# 代码检查
vet:
	@echo ">>> 代码检查..."
	@go vet ./...
	@echo ">>> 检查完成"

# 下载依赖
deps:
	@echo ">>> 下载依赖..."
	@go mod download
	@go mod tidy
	@echo ">>> 依赖更新完成"

# 运行程序
run:
	@go run . $(ARGS)

# 显示版本信息
version:
	@echo "版本: $(VERSION)"
	@echo "提交: $(COMMIT)"
	@echo "构建时间: $(BUILD_TIME)"

# 帮助信息
help:
	@echo "wxapkg Makefile 帮助"
	@echo ""
	@echo "用法: make [目标]"
	@echo ""
	@echo "目标:"
	@echo "  build              编译当前平台 (默认)"
	@echo "  build-all          编译所有平台 (Windows, macOS, Linux)"
	@echo "  install            编译并安装到 GOPATH"
	@echo "  clean              清理编译产物"
	@echo "  test               运行测试"
	@echo "  fmt                格式化代码"
	@echo "  vet                代码检查"
	@echo "  deps               更新依赖"
	@echo "  run                运行程序 (使用 ARGS 传递参数)"
	@echo "  version            显示版本信息"
	@echo "  help               显示此帮助信息"
	@echo ""
	@echo "示例:"
	@echo "  make build                    # 编译当前平台"
	@echo "  make build-all                # 编译所有平台"
	@echo "  make install                  # 安装到本地"
	@echo "  make clean                    # 清理"
	@echo "  make run ARGS='scan --help'   # 运行程序并传参"
	@echo "  VERSION=v1.0.0 make build-all # 指定版本编译"
	@echo ""

