
#CentOS
```
cd /tmp

# 编译环境准备&安装依赖包
yum install -y gcc make libtool build-essential git
yum install -y curl curl-devel zlib-devel openssl-devel perl perl-devel pcre pcre-devel cpio expat-devel gettext-devel asciidoc xmlto

# Installation of autoconf
export AUTOCONF_VER=2.69
rpm -e --nodeps autoconf-2.63
wget http://ftp.gnu.org/gnu/autoconf/autoconf-$AUTOCONF_VER.tar.gz
tar -xzf autoconf-AUTOCONF_VER.tar.gz 
pushd mbedtls-$MBEDTLS_VER
./configure 
make && make install
popd
sudo ldconfig

# Installation of MbedTLS
export MBEDTLS_VER=2.4.2
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
popd
sudo ldconfig

# Installation of Libsodium
export LIBSODIUM_VER=1.0.12
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig

# 克隆源码
git clone --recursive https://github.com/shadowsocks/shadowsocks-libev.git
# 开始编译
cd shadowsocks-libev
./autogen.sh
./configure --prefix=/usr && make
make install
# 准备必须的文件
mkdir -p /etc/shadowsocks-libev
cp ./rpm/SOURCES/etc/init.d/shadowsocks-libev /etc/init.d/shadowsocks-libev
cp ./debian/config.json /etc/shadowsocks-libev/config.json
chmod +x /etc/init.d/shadowsocks-libev
# 编辑配置文件
vim /etc/shadowsocks-libev/config.json
# 添加开机自启动服务
chkconfig --add shadowsocks-libev
chkconfig shadowsocks-libev on
# 启动服务
service shadowsocks-libev start
```