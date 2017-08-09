## a)获取HC5661A的root权限
## b)下载文件
	
	cd ~
	curl -k https://github.com/orzroa/highwifi/raw/master/HC5661A/ss-install.sh -o ss-install.sh
	curl -k https://github.com/orzroa/highwifi/raw/master/HC5661A/ss-remove.sh -o ss-remove.sh

## c)安装
	./ss-install.sh  [server_ip] [server_port] [local_port] [password]

## d)卸载
	./ss-remove.sh
