#!/bin/bash

echo "=== SSH密钥配置与GitHub推送 ==="
echo ""

# 1. 检查现有密钥
echo "1. 检查现有SSH密钥..."
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "   发现现有密钥: ~/.ssh/id_rsa.pub"
else
    echo "   未发现现有密钥，将生成新密钥..."
fi

# 2. 生成新密钥（如果需要）
echo "2. 生成SSH密钥..."
read -p "   请输入你的GitHub邮箱: " user_email
if [ -z "$user_email" ]; then
    user_email="your-email@example.com"
fi

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "$user_email" -f ~/.ssh/id_rsa -N ""
    echo "   ✅ SSH密钥已生成"
else
    echo "   ℹ️ 使用现有SSH密钥"
fi

# 3. 启动SSH代理
echo "3. 启动SSH代理..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# 4. 显示公钥
echo "4. 请将以下公钥添加到GitHub："
echo "   ========================================="
cat ~/.ssh/id_rsa.pub
echo "   ========================================="
echo ""
echo "   请完成以下步骤："
echo "   1. 复制上面的公钥内容（全选复制）"
echo "   2. 访问 https://github.com/settings/keys"
echo "   3. 点击 'New SSH key'"
echo "   4. Title: '开发机密钥'（或自定义）"
echo "   5. Key: 粘贴复制的公钥"
echo "   6. 点击 'Add SSH key'"
echo ""
read -p "   完成上述步骤后按回车继续..." dummy

# 5. 测试连接
echo "5. 测试GitHub连接..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "   ✅ SSH连接测试成功"
else
    echo "   ❌ SSH连接失败"
    echo "   请检查："
    echo "   1. 是否已将公钥添加到GitHub"
    echo "   2. 网络连接是否正常"
    exit 1
fi

# 6. 推送代码
echo "6. 推送到GitHub..."
cd /home/dataset-assist-0

# 检查远程仓库配置
if ! git remote | grep -q origin; then
    git remote add origin git@github.com:Mega-M/report-evaluation.git
fi

# 推送
if git push -u origin main 2>&1; then
    echo "   ✅ 推送成功！"
    echo "   仓库地址: https://github.com/Mega-M/report-evaluation"
else
    echo "   ❌ 推送失败，尝试强制推送..."
    git push -u origin main --force
fi

echo ""
echo "=== 完成 ==="
