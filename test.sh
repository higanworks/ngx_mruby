#!/bin/sh

# Default install and test
#   download nginx into ./build/
#   build into ./build/nginx
#   test on ./build/nginx

set -e

. ./nginx_version

NGINX_INSTALL_DIR=`pwd`'/build/nginx'
NGINX_CONFIG_OPT="--prefix=${NGINX_INSTALL_DIR} --with-http_stub_status_module"

if [ "$NUM_THREADS_ENV" != "" ]; then
    NUM_THREADS=$NUM_THREADS_ENV
else
    NUM_PROCESSORS=`getconf _NPROCESSORS_ONLN`
    if [ $NUM_PROCESSORS -gt 1 ]; then
        NUM_THREADS=$(expr $NUM_PROCESSORS / 2)
    else
        NUM_THREADS=1
    fi
fi

echo "NGINX_CONFIG_OPT=$NGINX_CONFIG_OPT"
echo "NUM_THREADS=$NUM_THREADS"

if [ ! -d "./mruby/src" ]; then
    echo "mruby Downloading ..."
    git submodule init
    git submodule update
    echo "mruby Downloading ... Done"
fi

if [ "$ONLY_BUILD_NGX_MRUBY" = "" ]; then

  echo "nginx Downloading ..."
  if [ -d "./build" ]; then
      echo "build directory was found"
  else
      mkdir build
  fi
  cd build
  if [ ! -e ${NGINX_SRC_VER} ]; then
      wget http://nginx.org/download/${NGINX_SRC_VER}.tar.gz
      echo "nginx Downloading ... Done"
      tar xf ${NGINX_SRC_VER}.tar.gz
  fi
  ln -sf ${NGINX_SRC_VER} nginx_src
  NGINX_SRC=`pwd`'/nginx_src'
  cd ..

  echo "ngx_mruby configure ..."
  ./configure --with-ngx-src-root=${NGINX_SRC} --with-ngx-config-opt="${NGINX_CONFIG_OPT}"
  echo "ngx_mruby configure ... Done"

  echo "mruby building ..."
  make build_mruby NUM_THREADS=$NUM_THREADS -j $NUM_THREADS
  echo "mruby building ... Done"

  echo "ngx_mruby building ..."
  make NUM_THREADS=$NUM_THREADS -j $NUM_THREADS
else
  make make_ngx_mruby NUM_THREADS=$NUM_THREADS -j $NUM_THREADS
fi

echo "ngx_mruby building ... Done"

echo "ngx_mruby testing ..."
make install
ps -C nginx && killall nginx
sed -e "s|__NGXDOCROOT__|${NGINX_INSTALL_DIR}/html/|g" test/conf/nginx.conf > ${NGINX_INSTALL_DIR}/conf/nginx.conf
cp -pr test/html/* ${NGINX_INSTALL_DIR}/html/.

${NGINX_INSTALL_DIR}/sbin/nginx &
#sleep 2
cp -p test/build_config.rb ./mruby_test/.
cd mruby_test
rake
./bin/mruby ../test/t/ngx_mruby.rb
killall nginx
echo "ngx_mruby testing ... Done"

echo "test.sh ... successful"
