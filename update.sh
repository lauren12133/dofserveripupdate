#!/bin/bash

directory="/home/neople/game/cfg" #cfg文件夹

while true; do
    # 提取siroco11.cfg文件中的IP地址
    siroco11_cfg="$directory/siroco11.cfg"
    old_ip=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$siroco11_cfg" | head -n1)

    if [ -z "$old_ip" ]; then
        echo "无法获取siroco11.cfg文件中的IP地址"
		sleep 20
		continue
    fi

    echo "siroco11.cfg文件中的IP地址为: $old_ip"

    # 解析域名
    domain_ip=$(curl -s 4.ipw.cn)

    if [ -z "$domain_ip" ]; then
        echo "无法解析域名的IP地址"
		sleep 20
		continue
    fi

    echo "得到的IP地址为: $domain_ip"

    if [ "$domain_ip" == "$old_ip" ]; then
        echo "siroco11.cfg文件中的IP地址与域名解析得到的IP地址相同，不进行替换"
    else
        echo "siroco11.cfg文件中的IP地址与域名解析得到的IP地址不同，执行./stop并等待5秒"
        sudo ./stop
        sleep 5
        echo "执行再次执行./stop"
        sudo ./stop
        
        echo "修改并替换所有cfg文件中的IP地址为域名解析得到的IP地址"
        find "$directory" -type f -name "*.cfg" -exec sed -i "s|$old_ip|$domain_ip|g" {} +
        echo "完成替换"
        sudo ./run
        echo "已成功替换为“$domain_ip”旧ip为“$old_ip”"
    fi

    echo "等待20分钟后继续执行脚本..."
    sleep 1200  # 20分钟
done

echo "脚本执行完毕"
