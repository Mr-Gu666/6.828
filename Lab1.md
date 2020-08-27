实模式地址：物理地址 = 16*段地址+偏移。

BIOS 储存在ROM中，为操作系统和应用程序提供基本的I/O服务。

<h3>
    Part1:  电脑引导程序
</h3>

目的是介绍x86汇编语言*`(已完成，看文件夹pcasm-book)`*和电脑引导的过程，并且教会使用QEMU和QEMU/GDB进行debug。在这部分不用写代码，但是需要弄清楚下面的这些问题。

<h4>开始x86汇编</h4>

如果对汇编语言不熟悉，pcasm-book是一本很好的书。但是它是nasm汇编语言，我们要使用的是GNU汇编语言。在下面这个的 *Brennan‘s Guide to Inline Assembly* 中介绍了如何将他们互相转换。

**练习1：**

熟悉下面这个连接中的汇编语言，不需要现在去阅读，可以将它们作为参考。

> https://pdos.csail.mit.edu/6.828/2018/reference.html

建议阅读[Brennan's Guide to Inline Assembly](http://www.delorie.com/djgpp/doc/brennan/brennan_att_inline_djgpp.html)的语法部分，他很好地描述了我们在JOS中会用到的GNU汇编语言。

这里给出了两个*Intel80386*的参考连接。

> 1.https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm
>
> 2.https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html?iid=tech_vt_tech+64-32_manuals

<h4>模拟x86</h4>

我们不会把操作系统在真实的计算机上使用，而是使用程序仿真模拟一台计算机。在仿真机器上写的代码也可以引导真实的计算机。使用仿真机器可以简化debug工作。

在6.828中，我们使用qemu仿真。由于qemu固有监视器的debug限制，我们使用GNU远程进行debug将qemu当作gdb的远程调试目标。在本实验中我们使用它来度过早期的引导过程。

当输入完*`make qemu-nox`*之后，会进入qemu虚拟机，内核是jos。终端上会显示一些内容，在*`Booting from Hard Disk`*之后，是由jos内核输出的。

有两个可以给内核监听器的命令*`help`*和*`kerninfo`*。

> K> help
>
> help - display this list of commands
>
> kerninfo - display information about the kernel
>
> K> kerninfo
>
> Special kernel symbols:
>
> ​	 entry    f010000c  (virt)    0010000c  (phys)
>
> ​	 etext    f0101a75  (virt)    00101a75  (phys)
>
> ​     edata   f0112300  (virt)    00112300  (phys)
>
> ​	 end      f0112960  (virt)    00112960  (phys)
>
> Kernel executable memory footprint: 75KB

来讨论下*`kerninfo`*命令的输出。虽然输出的内容很简单，但是它给出了一个重要的信息：内核监视器是“直接”运行在仿真计算机的“RAW*(虚拟)*硬盘”上的。这意味着可以直接复制*`obj/kern/kernel.img`*的内容到真实硬盘的前几个扇区，然后把硬盘插到电脑上启动，会看到电脑屏幕出现和qemu窗口一样的内容。但是不建议这么做，原硬盘的引导会被覆盖，硬盘以前的内容会丢失。

<h4>PC物理地址空间</h4>

现在去深入了解更多电脑启动的细节。电脑的物理地址空间是硬线(???hard-wired)有以下的常规布局：

```
+------------------+  <- 0xFFFFFFFF (4GB) 
|      32-bit      | 
|  memory mapped   | 
|     devices      | 
|                  | 
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\ 
|                  | 
|      Unused      | 
|                  | 
+------------------+  <- depends on amount of RAM 
|                  | 
|                  | 
| Extended Memory  | 
|                  | 
|                  | 
+------------------+  <- 0x00100000 (1MB) 
|     BIOS ROM     | 
+------------------+  <- 0x000F0000 (960KB) 
|  16-bit devices, | 
|  expansion ROMs  | 
+------------------+  <- 0x000C0000 (768KB) 
|   VGA Display    | 
+------------------+  <- 0x000A0000 (640KB) 
|                  | 
|    Low Memory    | 
|                  | 
+------------------+  <- 0x00000000
```

> 注意！从下向上的内存顺序！

首批电脑基于16位Intel 8088处理器，只能处理1MB的物理内存。因此早期电脑的物理内存空间开始于0x00000000，结束于0x000FFFFF而不是0xFFFFFFFF。这640KB的区域被标记为“Low Memory”，是早期电脑唯一可以使用的随机存取存储器。最早的电脑实际上只能配置16KB，32KB或64KB的随机存取存储器。

从0x000A0000到0x000FFFFF的384KB区域，有特殊用途，例如视频显示缓冲区和非易失性存储器中保存的固件。最重要的保留区域是BIOS，它占据了从0x000F0000到0x000FFFFF的64KB。在早期的计算机中，BIOS是存储在ROM中的，但现代的计算机BIOS则存储在可更新的FLASH闪存中。BIOS负责执行基本的系统初始化，如激活视频卡，检查已安装的内存量。在初始化之后，BIOS会从软盘、硬盘、CD-ROM或网络中加载操作系统，将控制权转交给操作系统。

当Intel在80286和80386上打破了1MB限制后，为了确保向下兼容现存软件，PC 架构还是保留着 1 MB 以内物理地址空间的原始布局。因此，现代计算机在物理内存的0x000A0000到0x00100000之间有一个“空洞”，将RAM分为“低”或“常规内存”（前640KB）和“扩展内存”（其他所有）。此外，电脑的32位物理地址空间中顶层的某些空间（在所有物理RAM之上）现在通常留给BIOS供32位PCI设备使用。

最近x86处理器可以支持超过4GB的物理RAM，所以RAM可以扩展到远超0xFFFFFFFF。在这种情况下，BIOS必须在系统的RAM的32位可寻址区域的顶部留下第二个“空洞”，来为这些32位设备留出可映射的空间。由于设计的限制，JOS只能用电脑物理内存的前256MB，所以现在假设所有电脑都只有32位物理地址空间。但是处理复杂的物理地址空间和硬件组织的其他方面是os开发的重大挑战。

<h4>ROM BIOS</h4>

在实验的这部分将尝试使用qemu的debug功能来研究IA-32兼容计算机的启动方式。

打开两个终端窗口，转到lab目录下。在窗口一输入*`make qemu-nox-gdb`*。qemu启动了，但是qemu会在处理第一条指令之前停止并等待GDB的调试链接。在窗口2中，运行*`make gdb`*。应该看到下面这些东西。

```
athena% make gdb
GNU gdb (GDB) 6.8-debian
Copyright (C) 2008 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "i486-linux-gnu".
+ target remote localhost:26000
The target architecture is assumed to be i8086
[f000:fff0] 0xffff0:	ljmp   $0xf000,$0xe05b
0x0000fff0 in ?? ()
+ symbol-file obj/kern/kernel
(gdb) 
```

.gdbinit文件设置了GDB来调试在早期boot中的16位代码，并指示它附加到侦听的qemu。

接下来有一行：

```
[f000:fff0] 0xffff0:	ljmp   $0xf000,$0xe05b
```

是GDB对执行的第一条命令的反汇编。从这个输出中可以看出：

- IBM PC从物理地址0x000ffff0开始执行，该地址位于为ROM BIOS保留的64KB的最顶部。
- PC从*`CS = 0xf000`*和*`IP = 0xfff0`*开始执行
- 第一条执行的指令是*`jmp`*指令，将跳转到*`CS = 0xf000`*和*`IP = 0xe05b`*

这是8088处理器的设计。BIOS是硬线连接到物理地址范围0x000f0000-0x000fffff的，所以一个确保BIOS在电脑通电或系统重启之后能够首先获得电脑控制权的设计很重要，因为通电时没有一个可执行的软件在机器的RAM中。qemu仿真自带BIOS，放置在处理器的模拟物理地址空间的此位置。当处理器复位后，模拟的处理器进入实模式，将CS设为0xf000，IP设为0xfff0，执行从(CS:IP)段地址开始。如何把段地址变为物理地址：

> 实模式地址：物理地址 = 16*段地址(CS)+偏移(IP)

计算之后，结果是0xffff0。

0xffff0是在BIOS结束前的16字节。因此BIOS要做的第一件事情是jmp到BIOS中较早的位置也是可以理解的。

**练习二：**

使用GDB的*`si`*命令跟踪ROM BIOS。知道BIOS会先做什么。

> cr0-cr3:  https://www.cnblogs.com/iamfy/archive/2012/05/10/2495044.html
>
> 间接寻址：
>
> - `SecTION:[BASE + INDEX * SCALE + DISP]` (Intel格式)
> - `SECTION:disp(base, index, scale)` (AT&T格式)
>
> AT&T语法中立即形式的远跳转和远调用为`ljmp/lcall $section, $offset`，而Intel的是`jmp/call far section:offset`。同样，AT&T语法中远返回指令`lret $stack-adjust`对应Intel的`ret far stack-adjust`

```assembly
;cs:ip 实地址 指令
[f000:fff0] 0xffff0: ljmp $0xf000,$0xe05b
;jmp to 0xfe05b
[f000:e05b] 0xfe05b: cmpl $0x0,%cs:0x6ac8
;%cs:0x6ac8 是一个地址，类似于cs:ip 将0x0这个立即数和%cs:0x6ac8所代表的内存地址的值比较
[f000:e062] 0xfe062: jne 0xfd2e1
;if %cs:0x6ac8 != 0x0 jump to 0xfd2e1
[f000:e066] 0xfe066: xor %dx,%dx
;dx = 0 & didn't jump
[f000:e068] 0xfe068: mov %dx,%ss
;ss = 0
[f000:e06a] 0xfe06a: mov $0x7000,%esp
;esp = 0x7000
[f000:e070] 0xfe070: mov $0xf34c2,%edx
;edx = 0xf34c2
[f000:e076] 0xfe076: jmp 0xfd15c
[f000:d15c] 0xfd15c: mov %eax,%ecx
;ecx = eax
[f000:d15f] 0xfd15f: cli
;关闭中断指令，关闭可屏蔽的中断
[f000:d160] 0xfd160: cld
;设置方向标识位为0，表示内存地址方向变化从低地址值变为高地址
[f000:d161] 0xfd161: mov $0x8f,%eax
;eax = 0x8f
[f000:d167] 0xfd167: out %al,$0x70
;out用于操作IO端口
;out PortAddress,%al 把al的值输入到端口地址为PortAddress的端口
[f000:d169] 0xfd169: in $0x71,%al
;把端口地址的值读到al中
[f000:d16b] 0xfd16b: in $0x92,%al
[f000:d16d] 0xfd16d: or $0x2,%al
[f000:d16f] 0xfd16f: out %al,$0x92
[f000:d171] 0xfd171: lidtw %cs:0x6ab8
[f000:d177] 0xfd177: lgdtw %cs:0x6a74
;lidt m16/m32 将操作数中的值加载到中断描述符表格寄存器(IDTR)
;lgdt m16/m32 将操作数中的值加载到全局描述符表格寄存器(GDTR)
[f000:d17d] 0xfd17d: mov %cr0,%eax
;eax = cr0
[f000:d180] 0xfd180: or $0x1,%eax
;eax最低位 = 1
[f000:d184] 0xfd184: mov %eax,%cr0
;cr0 = eax
[f000:d187] 0xfd187: ljmpl $0x8,$0xfd18f
=> 0xfd18f: mov $0x10,%eax
;eax = 0x10
=> 0xfd194: mov %eax,%ds
;ds = eax
=> 0xfd196: mov %eax,%es
;es = eax
=> 0xfd198: mov %eax,%ss
;ss = eax
=> 0xfd19a: mov %eax,%fs
;fs = eax
=> 0xfd19c: mov %eax,%gs
;gs = eax
=> 0xfd19e: mov %ecx,%eax
;eax = ecx
;好像是恢复eax原来的值，猜测是中断方面的相关指令执行完毕
=> 0xfd1a0: jmp *%edx
;jump to edx存储的值做地址
=> 0xf34c2: push %ebx
=> 0xf34c3: sub $0x2c,%esp
;留出来了44个空间
=> 0xf34c6: movl $0xf5b5c,0x4(%esp)
;??? 0x4 和 esp有啥关系吗？ 也许是栈上位置的关系
;esp+0x4 = 0xf5b5c
=> 0xf34ce: movl $0xf447b,(%esp)
;什么用法？？？
;(%esp) = 0xf447b
=> 0xf34d5: call 0xf099e
;jump to 0xf099e
=> 0xf099e: lea 0x8(%esp),%ecx
;计算esp+0x8所存的数，存到ecx中
=> 0xf09a2: mov 0x4(%esp),%edx
;edx = 0xf5b5c
=> 0xf09a6: mov $0xf5b58,%eax
;eax = 0xf5b58 = edx-4
=> 0xf09ab: call 0xf0574
=> 0xf0574: push %ebp
=> 0xf0575: push %edi
=> 0xf0576: push %esi
=> 0xf0577: push %ebx
=> 0xf0578: sub $0xc,%esp
=> 0xf057b: mov %eax,0x4(%esp)
;now esp+0x4 = eax = 0xf5b58
=> 0xf057f: mov %edx,%ebp
;ebp = edx = 0xf5b5c
=> 0xf0581: mov %ecx,%esi
;esi = ecx
;ecx好像等于最最最开始的eax？
=> 0xf0583: movsbl 0x0(%esp),%edx
;edx = %esp
=> 0xf0587: test %dl,%dl
;test进行与运算，设置标志位，但是两个操作数数值不变
=> 0xf0589: je 0xf0758
=> 0xf058f: cmp $0x25,%dl
=> 0xf0592: jne 0xf0741
=> 0xf0741: mov 0x4(%esp),%eax
;eax恢复？
=> 0xf0745: call 0xefc70
=> 0xefc70: mov %eax,%ecx
;ecx = eax = 0xf5b58?
=> 0xefc72: movsbl %dl,%edx
;edx = dl
=> 0xefc75: call *(%ecx)
;call (ecx的值的值为地址)
=> 0xefc65: %edx,%eax
;eax = edx = dl?
=> 0xefc67: mov 0xf693c,%dx
;dx = 0xf693c
=> 0xefc6e: out %al,(%dx)
;al的值输出到$0xf693c端口
=> 0xefc6f: ret
;call还未返回的，现有3个
=> 0xefc77: ret
;call - 2
=> 0xf074a: mov %ebp,%ebx
;ebx = ebp
=> 0xf074c: jmp 0xf0750
=> 0xf0750: lea 0x1(%ebx),%ebp
=> 0xf0753: jmp 0xf0583
;jump回了前面
=> 0xf0583: movsbl 0x0(%ebp),%edx
=> oxf0587: test %dl,%dl
=> 0xf0589: je 0xf0758
=> 0xf058f: cmp $0x25,%dl
=> 0xf0592: jne 0xf0741
=> 0xf0741: mov 0x4(%esp),%eax
=> 0xf0745: call 0xefc70
=> 0xefc70: mov %eax,%ecx
=> 0xefc72: movsbl %dl,%edx
=> 0xefc75: call *(%ecx)
;之后进入了无限循环？？？
```

当BIOS启动的时候，它设置一个中断描述符表并初始化诸多设备。

在初始化PCI总线和所有BIOS知道的重要设备后，它会寻找一个可引导的设备，如：软盘、硬盘驱动器或CD-ROM。最终，当找到一个引导盘时，BIOS读取引导程序，并将控制权转移给程序。

<h3>
    Part2 引导加载
</h3>
PC的软盘和硬盘被分为512字节大小，每一个这样大的区域被称为扇区。扇区是磁盘的最小传输粒度：每一个读或写操作必须是一个或多个扇区，且和扇区的边界对齐。如果硬盘是可引导的，那么它的第一个扇区是引导扇区。当BIOS找到了一个可引导的软盘或硬盘，它会把512字节的引导扇区加载到内存地址0x7c00到0x7dff的内存中，然后使用*`jmp`*命令将CS:IP设置为0000:7c00，将控制权转交给引导加载器。像BIOS加载地址一样，这些地址是任意的，但它们对于PC是固定的和标准化的。

随着 PC 的技术进步，它们可以从 CD-ROM 中引导，因此，PC 架构师对引导过程进行轻微的调整。最后的结果使现代的 BIOS 从 CD-ROM 中引导的过程更复杂（并且功能更强大）。CD-ROM 使用 2048 字节大小的扇区，而不是 512 字节的扇区，并且，BIOS 在传递控制权之前，可以从磁盘上加载更大的（不止是一个扇区）引导镜像到内存中。更多内容，请查看 [“El Torito” 可引导 CD-ROM 格式规范](https://link.zhihu.com/?target=https%3A//sipb.mit.edu/iap/6.828/readings/boot-cdrom.pdf)。

对于6.828我们使用硬盘引导，这意味着我们的引导加载器必须只能容纳512字节。引导加载器由一个汇编文件`boot/boot.S`和一个C文件`boot/main.c`组成。理解清楚这两个文件可以彻底理解发生了什么。引导加载器主要做了两件事情：

> http://bochs.sourceforge.net/techspec/PORTS.LST 这个链接很重要，好像讲的是接口的内容
>
> https://developer.aliyun.com/article/767144 用于参考.text等

1.首先，引导加载器将处理器从实模式切换到32位保护模式，因为只有在 32 位保护模式中，软件才能够访问处理器中 1 MB 以上的物理地址空间。

2.然后，引导加载器通过x86的特殊I/O指令直接访问IDE磁盘设备寄存器，从硬盘中读取内核。了解专用 I/O 指令，查看 [6.828 参考页面](https://link.zhihu.com/?target=https%3A//sipb.mit.edu/iap/6.828/reference) 上的 “IDE 硬盘控制器” 章节。

在理解引导加载器源码后，看一下`obj/boot/boot.asm`文件。这个反汇编文件让我们可以更容易地看到引导加载器代码所处的物理内存位置，并且也可以更容易地跟踪在 GDB 中步进的引导加载器发生了什么事情。同样的，`obj/kern/kernel.asm` 文件中包含了 JOS 内核的一个反汇编，它也经常被用于内核调试。

你可以使用 `b` 命令在 GDB 中设置中断点地址。比如，`b *0x7c00` 命令在地址 `0x7C00` 处设置了一个断点。当处于一个断点中时，你可以使用 `c` 和 `si` 命令去继续运行：`c` 命令让 QEMU 继续运行，直到下一个断点为止（或者是你在 GDB 中按下了 Ctrl - C），而 `si N` 命令是每次步进 `N` 个指令。

要检查内存中的指令（除了要立即运行的下一个指令之外，因为它是由 GDB 自动输出的），你可以使用 `x/i` 命令。这个命令的语法是 `x/Ni ADDR`，其中 `N` 是连接的指令个数，`ADDR` 是开始反汇编的内存地址。

**练习3：**

> 这里实在读不懂要干啥，参考了https://www.cnblogs.com/fatsheep9146/p/5115086.html这里
>
> 就是字面上的意思QWQ
>
> [GDT&LDT](https://blog.csdn.net/wrx1721267632/article/details/52056910)

熟悉GDB命令。

>  https://pdos.csail.mit.edu/6.828/2018/labguide.html

在地址 0x7c00 处设置断点，它是加载后的引导扇区的位置。继续运行，直到那个断点。通过代码跟踪`boot/boot.S`，使用的源代码和反汇编文件 **`OBJ/boot/boot.asm`**跟踪你在哪里。也可以在GDB中使用`x/i`命令反汇编引导加载程序中的指令序列，并将原始引导加载程序源代码与`obj/boot/boot.asm` 和GDB中的反汇编进行比较。

在 `boot/main.c` 文件中跟踪进入 `bootmain()` ，然后进入 `readsect()`。识别 `readsect()` 中相关的每一个语句的准确汇编指令。跟踪 `readsect()` 中剩余的指令，然后返回到 `bootmain()` 中，识别 `for` 循环的开始和结束位置，这个循环从磁盘上读取内核的剩余扇区。找出循环结束后运行了什么代码，在这里设置一个断点，然后继续。接下来再走完引导加载器的剩余工作。

**哈哈哈哈哈哈哈我是傻子**

```
cd obj/boot/
```

**就这么难吗？？？**

现在回答问题：

1.处理器从什么时候开始执行32位代码？究竟是什么原因导致从16位模式切换到32位模式？

```assembly
movl %eax,%cr0
;48-51行
;将最后一位置位1保护模式开启，PE打开(???)
ljmp $PROT_MODE_CSEG,$protcseg
;进入32位
```

2.引导加载程序执行 的最后一条指令是什么，刚加载的内核的第一条指令是什么？

```c
((void (*)(void)) (ELFHDR->e_entry))();
```

```assembly
movw    $0x1234,0x472  
;kern entry.S
```

3.内核的第一条指令在哪里？

```assembly
0x0010000c
;objdump -f kernel
;or
;cd obj/kern
;gdb kern
;run
```

4.引导加载程序如何确定必须读取多少个扇区才能从磁盘获取整个内核？它在哪里找到此信息

> https://jiyou.github.io/blog/2018/04/15/mit.6.828/jos-lab1/

```c
ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
eph = ph + ELFHDR->e_phnum;
for (; ph < eph; ph++)
	// p_pa是需要被加载的地址。
    // p_memsz指的是需要的物理内存的大小
    // p_offset指的是在逻辑上相对于整个文件头的偏移量。
    // 虽然这里p_memsz表示的时候需要占用的内存的大小。
    // 实际上也是磁盘上需要读取的数据量的大小。
    readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
```

<h4>
    加载内核
</h4>
现在进一步查看引导加载器在boot/main.c中C语言部分的详细细节。但在这之前，要来回顾一下C语言基础。

**练习4**

读`The C Programming Language by Brian Kernighan and Dennis Ritchie `这本书的指针章节5.1—5.5。然后下载 运行[pointers.c](https://link.zhihu.com/?target=https%3A//sipb.mit.edu/iap/6.828/files/pointers.c) 的源代码，然后确保你理解了输出值的来源的所有内容。尤其是，确保你理解了第 1 行和第 6 行的指针地址的来源、第 2 行到第 4 行的值是如何得到的、以及为什么第 5 行指向的值表面上看像是错误的。

解析看[6.828笔记](6.828笔记.pdf)。

