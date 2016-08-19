# iosdc-slimane-chat

This is the demo app for iOSDC Aug 19 2016

## Installation

### Ubuntu
```sh
wget https://swift.org/builds/development/ubuntu1404/swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a/swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a-ubuntu14.04.tar.gz
tar xzvf swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a-ubuntu14.04.tar.gz
echo "PATH=/your/path/to/swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a-ubuntu14.04/usr/bin:$PATH" >> ~/.bashrc

~/.bashrc
swift -v
```

#### Install build tools for native libraries

#### apt-get
```sh
# Install build tools and libssl-dev
sudo apt-get upgrade
sudo apt-get install build-essential libtool libssl-dev
sudo apt-get install automake clang
```

#### Build and Install native libraries

```sh
# build and install libuv
git clone https://github.com/libuv/libuv.git && cd libuv
sh autogen.sh
./configure
make
make install

# build and install hiredis
git clone https://github.com/redis/hiredis && cd hiredis
make
make install
```

### Mac OSX

* Download https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a/swift-DEVELOPMENT-SNAPSHOT-2016-08-15-a-osx.pkg
* Double Click and install
```sh
swift -v
```

#### brew

```sh
brew install libuv openssl hiredis
brew link libuv --force
brew link openssl --force
brew link -f hiredis
```

## Build
```sh
make
```


## Starting Server
```
.build/release/IosdcSlimaneChat
```

## Trouble Shooting

### LD_LIBRARY_PATH
If You got `error while loading shared libraries: libuv.so.1: cannot open shared object file: No such file or directory`,
Add /usr/local/lib into LD_LIBRARY_PATH

```sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
```
