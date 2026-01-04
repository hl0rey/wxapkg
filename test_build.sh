#!/bin/bash

# 简单的构建测试脚本

echo "测试构建脚本..."
echo ""

echo "1. 检查 Go 环境..."
if command -v go &> /dev/null; then
    echo "✓ Go 已安装: $(go version)"
else
    echo "✗ Go 未安装"
    exit 1
fi

echo ""
echo "2. 检查项目文件..."
if [ -f "main.go" ]; then
    echo "✓ main.go 存在"
else
    echo "✗ main.go 不存在"
    exit 1
fi

echo ""
echo "3. 检查构建脚本..."
for script in build.sh build.bat Makefile; do
    if [ -f "$script" ]; then
        echo "✓ $script 存在"
    else
        echo "✗ $script 不存在"
    fi
done

echo ""
echo "4. 测试简单编译..."
go build -o /tmp/wxapkg-test .
if [ $? -eq 0 ]; then
    echo "✓ 编译成功"
    /tmp/wxapkg-test --version
    rm -f /tmp/wxapkg-test
else
    echo "✗ 编译失败"
    exit 1
fi

echo ""
echo "所有测试通过！✓"

