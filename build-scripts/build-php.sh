#!/bin/bash

# Copyright 2015 Google Inc.
# Copyright 2016 Aptible Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# A shell script for installing PHP
set -xe

PHP_SRC=/usr/src/php

curl -fsSL "http://php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror" -o php.tar.gz
curl -fsSL "http://us2.php.net/get/php-${PHP_VERSION}.tar.gz.asc/from/this/mirror" -o php.tar.gz.asc

# Create combined binary keys
cat /gpgkeys/* | gpg --dearmor > /gpgkeys/combined.gpg

# Verify only with specific public keys
gpg --no-default-keyring --keyring /gpgkeys/combined.gpg --verify php.tar.gz.asc

mkdir -p "$PHP_SRC"
tar -zxf php.tar.gz -C "$PHP_SRC" --strip-components=1
rm php.tar.gz
rm php.tar.gz.asc

pushd ${PHP_SRC}
rm -f configure
./buildconf --force
./configure \
    --prefix="${PHP_DIR}" \
    --with-config-file-scan-dir="${PHP_DIR}/lib/conf.d" \
    --disable-cgi \
    --disable-memcached-sasl \
    --enable-apc \
    --enable-apcu \
    --enable-bcmath=shared \
    --enable-calendar=shared \
    --enable-exif=shared \
    --enable-ftp=shared \
    --enable-gd-native-ttf \
    --enable-intl=shared \
    --enable-mailparse \
    --enable-mbstring=shared \
    --enable-memcached=shared \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-pcntl=shared \
    --enable-shared \
    --enable-shmop=shared \
    --enable-soap=shared \
    --enable-sockets \
    --enable-zip \
    --enable-phpdbg=no \
    --with-bz2 \
    --with-mcrypt \
    --with-curl \
    --with-gettext=shared \
    --with-gd=shared \
    --with-pdo_sqlite=shared,/usr \
    --with-sqlite3=shared,/usr \
    --with-xmlrpc=shared \
    --with-xsl=shared \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-pgsql \
    --with-pgsql \
    --with-openssl \
    --with-pcre-regex \
    --with-readline \
    --with-recode \
    --with-zlib \
    --with-apxs2

make -j"$(nproc)"
make install
make clean
popd
rm -rf "${PHP_SRC}"

# Create a directory for additional config files.
mkdir -p "${PHP_DIR}/lib/conf.d"

rm -rf /tmp/pear
