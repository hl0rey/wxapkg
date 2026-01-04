#!/bin/bash

# wxapkg 编译脚本
# 支持多平台交叉编译

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 版本信息
VERSION=${VERSION:-"v0.0.1"}
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
BUILD_TIME=$(date -u '+%Y-%m-%d_%H:%M:%S')

# 输出目录
OUTPUT_DIR="dist"

# 清理函数
clean() {
    echo -e "${YELLOW}[+] 清理旧的编译文件...${NC}"
    rm -rf ${OUTPUT_DIR}
    echo -e "${GREEN}[✓] 清理完成${NC}"
}

# 编译函数
build() {
    local GOOS=$1
    local GOARCH=$2
    local OUTPUT_NAME=$3
    
    echo -e "${BLUE}[*] 编译 ${GOOS}/${GOARCH}...${NC}"
    
    # 设置输出文件名
    local BINARY_NAME="wxapkg"
    if [ "$GOOS" = "windows" ]; then
        BINARY_NAME="wxapkg.exe"
    fi
    
    local OUTPUT_PATH="${OUTPUT_DIR}/${OUTPUT_NAME}/${BINARY_NAME}"
    
    # 创建输出目录
    mkdir -p "${OUTPUT_DIR}/${OUTPUT_NAME}"
    
    # 编译参数
    LDFLAGS="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT}"
    
    # 执行编译
    CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build \
        -trimpath \
        -ldflags="${LDFLAGS}" \
        -o "${OUTPUT_PATH}" \
        .
    
    if [ $? -eq 0 ]; then
        local SIZE=$(du -h "${OUTPUT_PATH}" | cut -f1)
        echo -e "${GREEN}[✓] 编译成功: ${OUTPUT_PATH} (${SIZE})${NC}"
        
        # 创建压缩包
        cd "${OUTPUT_DIR}/${OUTPUT_NAME}"
        if [ "$GOOS" = "windows" ]; then
            zip -q "../${OUTPUT_NAME}.zip" "${BINARY_NAME}"
            echo -e "${GREEN}[✓] 创建压缩包: ${OUTPUT_DIR}/${OUTPUT_NAME}.zip${NC}"
        else
            tar -czf "../${OUTPUT_NAME}.tar.gz" "${BINARY_NAME}"
            echo -e "${GREEN}[✓] 创建压缩包: ${OUTPUT_DIR}/${OUTPUT_NAME}.tar.gz${NC}"
        fi
        cd - > /dev/null
    else
        echo -e "${RED}[✗] 编译失败: ${GOOS}/${GOARCH}${NC}"
        return 1
    fi
}

# 构建所有平台
build_all() {
    echo -e "${YELLOW}[+] 开始编译所有平台...${NC}"
    echo -e "${BLUE}版本: ${VERSION}${NC}"
    echo -e "${BLUE}提交: ${COMMIT}${NC}"
    echo -e "${BLUE}时间: ${BUILD_TIME}${NC}"
    echo ""
    
    # Windows
    build "windows" "amd64" "wxapkg-windows-amd64"
    
    # macOS
    build "darwin" "amd64" "wxapkg-darwin-amd64"
    build "darwin" "arm64" "wxapkg-darwin-arm64"
    
    # Linux
    build "linux" "amd64" "wxapkg-linux-amd64"
    build "linux" "arm64" "wxapkg-linux-arm64"
    
    echo ""
    echo -e "${GREEN}[✓] 所有平台编译完成！${NC}"
    echo ""
    echo -e "${YELLOW}编译产物:${NC}"
    ls -lh ${OUTPUT_DIR}/*.{zip,tar.gz} 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
}

# 构建当前平台
build_current() {
    echo -e "${YELLOW}[+] 编译当前平台...${NC}"
    echo -e "${BLUE}版本: ${VERSION}${NC}"
    echo -e "${BLUE}提交: ${COMMIT}${NC}"
    echo ""
    
    local GOOS=$(go env GOOS)
    local GOARCH=$(go env GOARCH)
    
    build "$GOOS" "$GOARCH" "wxapkg-${GOOS}-${GOARCH}"
}

# 安装到本地
install() {
    echo -e "${YELLOW}[+] 编译并安装到本地...${NC}"
    
    LDFLAGS="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT}"
    
    go install -trimpath -ldflags="${LDFLAGS}" .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] 安装成功！${NC}"
        echo -e "${BLUE}安装位置: $(which wxapkg)${NC}"
        wxapkg --version
    else
        echo -e "${RED}[✗] 安装失败${NC}"
        return 1
    fi
}

# 显示帮助
show_help() {
    cat << EOF
wxapkg 编译脚本

用法: ./build.sh [命令] [选项]

命令:
  all       编译所有平台 (Windows, macOS, Linux)
  current   编译当前平台
  clean     清理编译产物
  install   编译并安装到本地 GOPATH
  help      显示此帮助信息

选项:
  VERSION   设置版本号 (默认: v0.0.1)
            示例: VERSION=v1.0.0 ./build.sh all

示例:
  ./build.sh all              # 编译所有平台
  ./build.sh current          # 编译当前平台
  ./build.sh clean            # 清理编译产物
  ./build.sh install          # 安装到本地
  VERSION=v1.0.0 ./build.sh all  # 指定版本编译

EOF
}

# 主函数
main() {
    # 检查 Go 环境
    if ! command -v go &> /dev/null; then
        echo -e "${RED}[✗] 错误: 未找到 Go 编译器，请先安装 Go${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}       wxapkg 编译脚本${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
    
    case "${1:-current}" in
        all)
            clean
            build_all
            ;;
        current)
            mkdir -p ${OUTPUT_DIR}
            build_current
            ;;
        clean)
            clean
            ;;
        install)
            install
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}[✗] 未知命令: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

