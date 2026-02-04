#!/bin/bash
# GitHub Actions 运行器磁盘清理脚本

set -euo pipefail

echo "========================================"
echo "GitHub Actions 运行器磁盘清理脚本"
echo "========================================"
echo ""
echo "清理前磁盘状态:"
df -h /home/runner
echo ""

# 清理 apt 缓存（立即执行）
echo "[1/6] 清理 apt 缓存..."
sudo apt-get clean -y
sudo apt-get autoremove -y --purge
echo "  完成"
echo ""

# 移除 Docker 及容器工具（占用空间最大）
echo "[2/6] 移除 Docker 及容器工具..."
sudo apt-get remove -y --purge \
    docker.io \
    docker-compose \
    docker-doc \
    containerd \
    runc \
    cri-containerd \
    cri-containerd-cni \
    2>/dev/null || true
echo "  完成"
echo ""

# 移除 Node.js 生态系统
echo "[3/6] 移除 Node.js 生态系统..."
sudo apt-get remove -y --purge \
    nodejs \
    npm \
    yarn \
    corepack \
    2>/dev/null || true
# 清理 nvm（如果存在）
rm -rf ~/.nvm 2>/dev/null || true
echo "  完成"
echo ""

# 移除其他编程语言运行时
echo "[4/6] 移除其他编程语言运行时..."
sudo apt-get remove -y --purge \
    ruby \
    ruby-dev \
    rubygems-integration \
    php \
    php-cli \
    php-common \
    golang-go \
    scala \
    sbt \
    2>/dev/null || true
echo "  完成"
echo ""

# 移除数据库客户端
echo "[5/6] 移除数据库客户端..."
sudo apt-get remove -y --purge \
    mysql-client \
    mysql-common \
    postgresql-client-common \
    postgresql-client \
    redis-tools \
    mongodb-clients \
    2>/dev/null || true
echo "  完成"
echo ""

# 移除大型文档工具
echo "[6/6] 移除大型文档工具..."
sudo apt-get remove -y --purge \
    texlive-full \
    texlive-latex-extra \
    texlive-fonts-recommended \
    libreoffice-writer \
    asciidoc \
    asciidoctor \
    2>/dev/null || true
echo "  完成"
echo ""

# 再次清理 apt
sudo apt-get autoremove -y --purge
sudo apt-get clean
echo ""

echo "========================================"
echo "清理后磁盘状态:"
df -h /home/runner
echo "========================================"
echo ""
echo "预估释放空间: 约 5-10 GB"
echo "注意: 实际释放空间取决于运行器配置和已安装的软件包"
