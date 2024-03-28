#!/bin/bash

# 域名
DOMAIN="1.1.1.1"  # 替换成您要解析的域名

# 模板文件路径
TEMPLATE_FILE="gateway.json.mb"

# JSON文件路径
JSON_FILE="gateway.json"

# 获取域名的真实IP地址
get_real_ip() {
    local real_ip=$(nslookup "$DOMAIN" | awk '/^Address: / { print $2 }' | tail -n1)
    echo "$real_ip"
}

# 比较原JSON文件中的IP地址与解析得到的IP地址是否相同
compare_ip() {
    local real_ip="$1"
    local json_ip=$(sed -n '8s/.*"\(.*\)",/\1/p' "$JSON_FILE")
    if [ "$real_ip" = "$json_ip" ]; then
        echo "JSON文件中的IP地址 ($json_ip) 与解析得到的IP地址 ($real_ip) 相同。无需更新。"
        exit 0
    else
        echo "JSON文件中的IP地址 ($json_ip) 与解析得到的IP地址 ($real_ip) 不同。"
        echo "执行 bash sh stopPkgGateWay.sh"
        # 在更新完文件后执行 startPkgGateWay.sh 脚本
        bash sh stopPkgGateWay.sh
        # 更新模板文件中的IP地址并创建新的JSON文件
        update_template_file "$real_ip"
    fi
}

# 更新模板文件中的IP地址
update_template_file() {
    local new_ip="$1"
    cp "$TEMPLATE_FILE" "$JSON_FILE"
    sed -i "s/\$newip/$new_ip/g" "$JSON_FILE"
    echo "已更新模板文件中的IP地址为 $new_ip"
    echo "执行 bash sh startPkgGateWay.sh"
    # 在更新完文件后执行 startPkgGateWay.sh 脚本
    bash sh startPkgGateWay.sh
}

# 创建新的JSON文件
create_json_file() {
    cp "$TEMPLATE_FILE" "$JSON_FILE"
    echo "已创建新的JSON文件: $JSON_FILE"
}

# 主循环，每隔20分钟执行一次
while true; do
    # 获取真实IP地址
    real_ip=$(get_real_ip)

    if [ -z "$real_ip" ]; then
        echo "无法解析域名 $DOMAIN"
        sleep 5
        continue
    fi

    # 比较原JSON文件中的IP地址与解析得到的IP地址是否相同
    compare_ip "$real_ip"

    # 每20分钟执行一次
    sleep $((20 * 60))
done
