## What's ngx_mruby
__ngx_murby is A Fast and Memory-Efficient Web Server Extension Mechanism Using Scripting Language mruby for nginx.__

- ngx_mruby is to provide an alternative to [mod_mruby](http://matsumoto-r.github.io/mod_mruby/) for nginx. 
- You can implemet nginx modules by Ruby scripts on nginx!
- Supported nginx __1.2/1.3/1.4/1.5.*__

```ruby
# location /proxy {
#   mruby_set $backend "/path/to/proxy.rb";
#   proxy_pass   http://$backend;
# }

backends = [
  "test1",
  "test2",
  "test3",
]

r = Redis.new "192.168.12.251", 6379
r.get backends[rand(backends.length)]
```

## Abstract

As the increase of large-scale and complex Web services, not only a development of Web applications but also an implementation of Web server extensions is required in many cases. The Web server extensions were mainly implemented in C language because of fast and memory-efficient behavior, but extension methods using scripting language are proposed with consideration of maintainability and productivity. However, if the existing methods primarily intended to enhance not the implementation of Web applications but the implementation of internal processing of the Web server, the problem remains in terms of fast, memory-efficiency and safety. Therefore, we propose a fast and memory-efficient Web server extension mechanism using scripting language. We design the architecture that a server process create the region to save the state of the interpreter at the server process startup, and multiple scripts share the region in order to process fast when the script is called as internal processing from a Web server process. The server process free the global variables table, the exception flag and the byte-code which cause the increase of memory usage mainly, in order to reduce the memory usage and extend safely by preventing interference between each scripts because of sharing the region. We implement the mechanism that can extend the internal processing of nginx easily by Ruby scripts using nginx and embeddable scripting language mruby. It's called "ngx_mruby".

## How to use

### 1. Download

    git clone git://github.com/matsumoto-r/ngx_mruby.git
    cd ngx_mruby
    git submodule init
    git submodule update

### 2. Build
* configure example

        ./configure --with-ngx-src-root=${NGINX_SRC} --with-ngx-config-opt="--prefix=/usr/local/nginx"

* mruby build

        make build_mruby

* ngx_mruby build

        make 
or  

        cd ${NGINX_SRC}
        ./configure --prefix=/usr/local/nginx --add-module=${NGX_MRUBY_SRC} --add-module=${SOME_MODULE}
        make


### 3. Install

    sudo make install

### 4. Add setting

    location /mruby {
        mruby_content_handler /usr/local/nginx122/html/hello.rb;
    }

### 5. Create mruby script /usr/local/nginx/html/hello.rb

    Nginx.rputs(Time.now.to_s + "hello mruby world for nginx.")

### 6. Start nginx

    /usr/local/nginx/sbin/nginx

### 7. Access http://example.com/mruby (sed/example.com/mydomain/)

    Sat Jul 28 18:05:51 2012 hello mruby world for nginx.

Display above. Welcome mruby world for nginx!!



# License
under the MIT License:

* http://www.opensource.org/licenses/mit-license.php
