# 6.828
学习6.828的过程

<h3>
    <li><a href="#ubuntu">Linux环境配置</a></li>
</h3>

<h4><a name = "ubuntu">Linux环境配置</a></h4>

这里我用的是wsl ubuntu18.04版本。

> 注意：wsl如果没有18.04这几个字，那么可能是20.04。可以使用 sudo lsb_release -a 命令来查看ubuntu版本

在根据官方教程输入

```
objdump -i
gcc -m32 -print-libgcc-file-name
```

但是！！！就算出现了官方教程中预期的结果，也**并不代表你的环境OK**。

我在这一步上尝试了大概3-4次。所以这一次，无论咋样，果断执行了下面两条命令

```
sudo apt-get install gcc-multilib
sudo apt-get install -y build-essential gdb
```

**注意！！！不要换源！不要换源！不要换源！用原来的Ubuntu源！用原来的Ubuntu源！用原来的Ubuntu源！**

具体为什么我也解释不清，但是的确可执行了。换源之后不可执行。

接着clone qemu

```
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
```

如果过程中出现了类似如下的错误：

error: RPC failed; curl 56 GnuTLS recv error (-54): Error in the pull function.

fatal: The remote end hung up unexpectedly

fatal: 过早的文件结束符（EOF）

fatal: index-pack failed

可以输入下面这个命令：

```
git config --global http.postBuffer  524288000
```

大概的意思就是扩充了缓冲区。

下载一些包：

```
sudo apt install libsdl1.2-dev
sudo apt install libtool-bin
sudo apt install libglib2.0-dev
sudo apt install libz-dev
sudo apt install libpixman-1-dev
```

我还是没有换源，中间没有出现错误。

```
./configure --disable-kvm --disable-werror --prefix=PFX --target-list="i386-softmmu x86_64-softmmu"
```

输入这个命令。“--prefix=PFX” 可以选择不填，默认存在usr/local里。

这里有个疑问，我的文件结构是6.828文件下clone的qemu。当我在6.828位置执行这个命令时，会提醒我没有configure文件。我尝试着去qemu文件下执行此命令，有反应了，不知道是不是正确操作。

没有python2的，记得安装一下python2。

```
sudo apt install python
```

然后是

```
make
sudo make install
```

接着回到6.828文件下

```
git clone https://pdos.csail.mit.edu/6.828/2018/jos.git lab
```

然后在lab文件夹下

```
make
make qemu-nox
```

最后一步略有不同，原因我给个链接，非常nice。

> [为什么是qemu-nox](https://blog.csdn.net/w55100/article/details/89447461)

#### 总结：

```
mkdir 6.828
cd 6.828
objdump -i
gcc -m32 -print-libgcc-file-name
sudo apt-get install gcc-multilib
sudo apt-get install -y build-essential gdb
git config --global http.postBuffer  524288000
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
sudo apt install libsdl1.2-dev
sudo apt install libtool-bin
sudo apt install libglib2.0-dev
sudo apt install libz-dev
sudo apt install libpixman-1-dev
cd qemu
./configure --disable-kvm --disable-werror --target-list="i386-softmmu x86_64-softmmu"
sudo apt install python
make
sudo make install
cd ..
git clone https://pdos.csail.mit.edu/6.828/2018/jos.git lab
cd lab
make
make qemu-nox
```

完成！