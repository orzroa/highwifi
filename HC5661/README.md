## a)获取HC5661的root权限
## b)下载文件
	
	cd ~
	curl -k https://raw.githubusercontent.com/orzroa/highwifi/master/HC5661/ss-install.sh -o ss-install.sh
	curl -k https://raw.githubusercontent.com/orzroa/highwifi/master/HC5661/ss-remove.sh  -o ss-remove.sh

## c)安装
	sh ss-install.sh  [server_ip] [server_port] [password]

## d)卸载
	sh ss-remove.sh
