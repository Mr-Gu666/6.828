<h3>
    基本指令
</h3>

| 指令 | 使用      | 解释             |
| ---- | --------- | ---------------- |
| mov  | mov eax,3 | 把3存入eax寄存器 |
| add  | add eax,4 | eax = eax+4      |
| sub  | sub eax,4 | eax = eax-4      |
| inc  | inc eax   | eax++            |
| dec  | dec eax   | eax--            |

<h3>
    指示符
</h3>
1.定义常量

2.定义用来储存数据的内存

3.将内存组合成段

4.有条件的包含源代码

5.包含其他文件

| 指令 | 使用             | 解释                                     |
| ---- | ---------------- | ---------------------------------------- |
| equ  | symbol equ value | symbol被命名为可以在汇编程序里使用的常量 |

| 单位     | 字母 | 解释       |
| -------- | ---- | ---------- |
| 字节     | B    | 8个bit位   |
| 字       | W    | 和架构有关 |
| 双字     | D    |            |
| 四字     | Q    |            |
| 十个字节 | T    |            |

**数据指示符**：用于定义内存空间，有两种方法，一种仅定义空间（res），另一种同时初始化（d）。

字符串要：L10 db "string",0 加0

若要把一个数移到具体的内存里面则要指明这个数是什么类型。byte word dword qword tword

| 命令         | 解释                                                      |
| ------------ | --------------------------------------------------------- |
| print_int    | 像屏幕上显示出储存在EAX中的整形值                         |
| print_char   | 在屏幕上显示以ASCII形式储存在AL中的字符(AX中的低八位)     |
| print_string | 在屏幕上显示储存在EAX里的地址所指向的字符串的内容         |
| print_nl     | 在屏幕上显示换行                                          |
| read_int     | 从键盘读入一个整形数据储存到EAX                           |
| read_char    | 从键盘读入一个单个字符把它以ASCII 码的方式储存到EAX寄存器 |

| 调试程序   | 解释                         |
| ---------- | ---------------------------- |
| dump_regs  | 显示寄存器中的值             |
| dump_mem   | 显示内存区域的值             |
| dump_stack | 显示栈堆的值                 |
| dump_math  | 显示数字协处理器寄存器的的值 |
**增加/减少数据位宽**

```
mov ax,0034h ;ax前八位ah = 0 后八位al = 34h = 52
mov cl,al ; cl = al
```

```
;expand al to ax
mov ah,0
movzx ax,al
;expand ax to eax
movzx eax,ax
;expand al to eax
movzx eax,al
;expand ax to ebx
movzx ebx,ax
```

> movsx 和 movzx 一样工作，只不过作用于有符号数

| 指令 | 描述                                 | 具体操作                   |
| ---- | ------------------------------------ | -------------------------- |
| CBW  | convert byte to word                 | signed al->signed ax       |
| CWD  | convert word to double word          | signed ax->signed dx:ax    |
| CWDE | convert word to double word extended | signed ax->signed eax      |
| CDQ  | convert double word to quad word     | signed eax->signed edx:eax |

**乘法**

mul：无符号

mul source

if source==byte:

​	source*al->ax

else if source==16位:

​	source*ax->dx:ax

else if source==32位:

​	source*eax->edx:eax

imul: 有符号

imul dest,source1

imul dest,source1,source2

| dest  | source1   | source2 | operate                |
| ----- | --------- | ------- | ---------------------- |
|       | reg/mem8  |         | ax = al*source1        |
|       | reg/mem16 |         | dx:ax = ax*source1     |
|       | reg/mem32 |         | edx:eax = eax*source1  |
| reg16 | reg/mem16 |         | dest *= source1        |
| reg32 | reg/mem32 |         | dest *= source1        |
| reg16 | immed8    |         | dest *= immed8         |
| reg32 | immed8    |         | dest *= immed8         |
| reg16 | immed16   |         | dest *= immed16        |
| reg32 | immed32   |         | dest *= immed32        |
| reg16 | reg/mem16 | immed8  | dest = source1*source2 |
| reg32 | reg/mem32 | immed8  | dest = source1*source2 |
| reg16 | reg/mem16 | immed16 | dest = source1*source2 |
| reg32 | reg/mem32 | immed32 | dest = source1*source2 |

div,idiv是除法，类似，但是余数存储在高位，商存储在低位，**记得要初始化dx,edx**，idiv没有像imul一样的特殊指令，都是div source(?)，**除法指令不可以是立即数**。

neg,求操作数的相反数

**扩充精度的加减运算**

adc: operand1 = operand1 + carry_flag + operand2

sbb: operand1 = operand1 -  carry_flag -  operand2

考虑在EDX:EAX 和 EBX:ECX中64位整型总数。下面的操作将总数存储到EDX:EAX中。

add eax,ecx  ;低32位相加

adc edx,ebx ;高32位带以前总数的进位相加

sub eax,ecx ;低32位相减

sbb edx,ebx ;高32位带借位相减

<h3>控制结构</h3>
> cmp vleft,vright => vleft - vright

**无符号数**(减法？？？)

|               | ZF（Zero Flag） | CF（Carry Flag） |
| ------------- | --------------- | ---------------- |
| vleft==vright | 1               | 0                |
| vleft>vright  | 0               | 0                |
| vleft<vright  | 0               | 1                |

**有符号数**

|      | ZF（Zero Flag） | OF（Overflow Flag） | SF（Sign Flag） |
| ---- | --------------- | ------------------- | --------------- |
| ==   | 1               |                     |                 |
| >    | 0               | =SF                 | =OF             |
| <    | 0               | 不等于SF            | 不等于OF        |

**JMP**：无条件分支

| 命令 | 解释                                                         |
| ---- | ------------------------------------------------------------ |
| JZ   | 如果ZF被置位，就分支                                         |
| JNZ  | 如果ZF没被置位，就分支                                       |
| JO   |                                                              |
| JNO  |                                                              |
| JS   |                                                              |
| JNS  |                                                              |
| JC   |                                                              |
| JNC  |                                                              |
| JP   | PF（parity flag）奇偶标志位-结果中的低八位1的位数值为奇数个/偶数个 |
| JNP  | 偶数个时被置位                                               |

|               | 有符号（Little Great） | 无符号（B A）???? |
| ------------- | ---------------------- | ----------------- |
| vleft==vright | JE                     | JE                |
| vleft!=vright | JNE                    | JNE               |
| vleft<vright  | JL,JNGE                | JB,JNAE           |
| vleft<=vright | JLE,JNG                | JBE,JNA           |
| vleft>vright  | JG,JNLE                | JA,JNBE           |
| vleft>=vright | JGE,JNL                | JAE,JNB           |

**循环指令**

LOOP: ecx自减，若ecx!=0 则分支

LOOPE，LOOPZ：ecx自减，若ecx!=0 且 ZF=1，则分支

LOOPNE，LOOPNZ：ecx自减，若ecx!=0 且 ZF=0，则分支

<h3>位操作</h3>
|      | 有符号 | 无符号 |
| ---- | ------ | ------ |
| 左移 | sal    | shl    |
| 右移 | sar    | shr    |

还有循环位移，挪出去的位会从另一端进入 rol ror

还有在数据和进位标志间移动的指令，rcl rcr

| 命令 | 解释                                         |
| ---- | -------------------------------------------- |
| and  | 与                                           |
| or   | 或                                           |
| not  | 非                                           |
| xor  | 异或                                         |
| test | 进行一次and然后设置Flags寄存器，like cmp命令 |

**避免使用条件分支**：setxx (xx就是jmp里那些，如果条件为真，储存结果就是1)

**交换字节**：

bswap edx ;交换edx中的字节

xchg ah,al ;交换ax中的字节

<!--进入第四章啦~~~-->

[input] 是数

input 是地址

<h3>
    栈堆
</h3>

push和pop的传统用法。

> 举例：
>
> push  dword 1
>
> pop eax

pusha 和 popa 则可以推入eax,ebx,edx,ecx,esi,edi,ebp寄存器的值。

**call**:执行一个跳到子程序的无条件跳转，同时将下一条指令的地址push进栈堆

**ret**:从栈堆pop一个地址并跳转

**计算局部变量的地址**

计算栈堆上的一个局部变量（或参数）的地址时，如果x在ebp-8的位置，那么不可以：

mov eax,ebp-8

而应该：

**lea** eax,[ebp-8]

> lea 载入有效地址 不进行读数，只是计算一个地址，所以也不需要指定内存大小，例如：dword，因为它不会读内存

**返回值：**

C语言函数一般会有返回值，这个返回值在汇编中要通过寄存器传递。所有的整数类型（char，int，enum等）通过eax返回。64位通过EDX:EAX返回。浮点数储存在数学协处理器中的ST0寄存器中。

<h3>第五章 数组</h3>

**times:**  这个指令可以用来反复重复一条语句。

> segment .data
>
> a times 200 db 0
>
>    times 200 db 1

上面的例子中，定义了一个字节数组，包含200个0和200个1。

**注意！**just like int a[400] a[0-199] = 0 a[200-399] = 1

**多维数组：**

**数组/串处理指令：**使用变址寄存器ESI和EDI执行操作，执行之后，这两个寄存器自动地进行加1或减1的操作

**CLD**-清方向标志位，自动增加

**STD**-置方向标志位，自动减少

|             |               |       |              |
| ----------- | ------------- | ----- | ------------ |
| lodsb-byte  | al = [ds:esi] | stosb | [es:edi]=al  |
|             | esi+1/esi-1   |       | edi+1/edi-1  |
| lodsw-word  | ax=[ds:esi]   | stosw | [es:edi]=ax  |
|             | esi+2/esi-2   |       | edi+2/edi-2  |
| lodsd-dword | eax=[ds:esi]  | stosd | [es:edi]=eax |
|             | esi+4/esi-4   |       | edi+4/edi-4  |

> esi用于读，edi用于写，上述表格是串的存取指令

|       |                                 |
| ----- | ------------------------------- |
| movsb | byte [es:edi] = byte [ds:esi]   |
|       | esi+1/esi-1                     |
|       | edi+1/edi-1                     |
| movsw | word [es:edi] = byte [ds:esi]   |
|       | esi+2/esi-2                     |
|       | edi+2/edi-2                     |
| movsd | dword [es:edi] = dword [ds:esi] |
|       | esi+4/esi-4                     |
|       | edi+4/edi-4                     |

**rep:** 告诉cpu重复执行下条串处理指令，这个次数由ecx决定。

**串比较指令：**类似于cmp指令会设置FLAGS寄存器；而scasx根据一指定的值扫描内存空间

|       |                                 |
| ----- | ------------------------------- |
| cmpsb | compare byte [ds:esi]&[es:edi]  |
|       | esi+1/esi-1                     |
|       | edi+1/edi-1                     |
| cmpsw | compare word [ds:esi]&[es:edi]  |
|       | esi+2/esi-2                     |
|       | edi+2/edi-2                     |
| cmpsd | compare dword [ds:esi]&[es:edi] |
|       | esi+4/esi-4                     |
|       | edi+4/edi-4                     |
| scasb | compare al&[es:edi]             |
|       | edi+1/edi-1                     |
| scasw | compare ax&[es:edi]             |
|       | edi+2/edi-2                     |
| scasd | compare eax&[es:edi]            |
|       | edi+4/edi-4                     |

**REPX指令：**使用ZF标志位来确定重复的比较是因为一次比较结束还是ecx=0结束。

> 指：如果找到了一个相等的，ZF=1，然后进行判断是因为ecx=0结束吗？这其中找到相等了的吗？这样子

repe,repx：zf=1 且 ecx不等于0时，重复执行指令

repne，repnz：zf=0 且 ecx不等于0时 ，重复执行指令

<h3>
    第六章 浮点数
</h3>

**导入和储存**

1.将数据导入到协处理器寄存器栈顶

| 指令        | 解释                                                         |
| :---------- | :----------------------------------------------------------- |
| fld source  | 从内存导入一个浮点数到栈顶，source可以是单、双或扩展精度数或是一个协处理器寄存器 |
| fild source | 从内存中读出一个整形数，将它转换成浮点数，再将结果储存到栈顶，source可以是字、双字或四字 |
| fld1        | 将1储存到栈顶                                                |
| fldz        | 将0储存到栈顶                                                |

2.将栈堆中的数据储存到内存

| 指令       | 解释                                                         |
| ---------- | ------------------------------------------------------------ |
| fst dest   | 将栈顶的值(ST0)储存到内存中。单、双精度或协处理器寄存器      |
| fstp dest  | 与上面的相比，区别是在储存完后，值会被弹出栈                 |
| fist dest  | 将栈顶的值转换为整型再储存。字或双字。 浮点数转换为整型数字取决于协处理器的控制字中的某些比特位。这是一个特殊的（非浮点）字寄存器，用来控制协处理器如何工作。缺省情况下，控制字会被初始化，以便于当需要转换成整型时，它会四舍五入成最接近的整型数。但是FSTCW（储存控制字）和FLDCW（导入控制字）指令可以用来改变这种行为。 |
| fistp dest | 与上面相比，栈顶的值会弹出，可以是四字                       |
| fxch STn   | 将栈堆中的ST0和STn(1-7)互换                                  |
| ffree STn  | 浮点释放。通过标记寄存器标记为未被使用或空来释放栈堆中的一个寄存器 |

**加法和减法**

1.加法

| 指令                         | 解释                                                      |
| ---------------------------- | --------------------------------------------------------- |
| fadd src                     | st0 += src 任何协处理器寄存器或内存中的单或双精度         |
| fadd dest,st0                | dest += st0 dest可以是任何协处理器寄存器                  |
| faddp dest,st0 or faddp dest | 与上面的指令相比，加完后会被立刻弹出栈                    |
| fiadd src                    | st0 += (float)src st0和一个整型相加。src必是内存中的w或dw |

2.减法

| 指令                           | 解释                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| fsub src                       | st0 -= src 任何协处理器寄存器或内存中的单、双                |
| fsubr src                      | st0 = src -st0 同上                                          |
| fsub dest,st0                  | dest -= st0 dest可以是任何协处理器                           |
| fsubr dest,st0                 | dest = st0-dest 同上                                         |
| fsubp dest or fsubp dest,st0   | 与上上个相比，st0弹出栈                                      |
| fsubrp dest or fsubrp dest,st0 | 与上上个相比，st0弹出栈                                      |
| fisub src                      | st0 -= (float)src st0减去一个整数。src必是内存中的一个w或dw  |
| fisubr src                     | st0 = (float)src - st0 用一个整数减去st0。src必是内存中的一个w或dw |

**乘法和除法**

1.乘法

| 指令                         | 解释              |
| ---------------------------- | ----------------- |
| fmul                         | st0 *= src        |
| fmul dest,st0                | dest *= st0       |
| fmulp dest or fmulp dest,st0 | 弹出              |
| fimul src                    | st0 *= (float)src |

2.除法

| 指令                           | 解释                 |
| ------------------------------ | -------------------- |
| fdiv src                       | st0 /= src           |
| fdivr src                      | st0 = src/st0        |
| fdiv dest,st0                  | dest /= st0          |
| fdivr dest,st0                 | dest = st0/dest      |
| fdivp dest or fdivp dest,st0   | dest /= st0 弹出     |
| fdivrp dest or fdivrp dest,st0 | dest = st0/dest 弹出 |
| fidiv src                      | st0 /= (float)src    |
| fidivr src                     | st0 = (float)src/st0 |

**比较**

| 指令       | 解释                                                     |
| ---------- | -------------------------------------------------------- |
| fcom src   | 比较st0和src 协处理器寄存器或内存中的单或双              |
| fcomp src  | 比较st0和src 然后弹出栈堆 协处理器寄存器或内存中的单或双 |
| fcompp     | 比较st0和st1，然后执行两次出栈操作                       |
| ficom src  | 比较st0和(float)src。内存中 整型 w/dw                    |
| ficomp src | 比较st0和(float)src，再弹出栈。内存中 整型 w/dw          |
| ftst       | 比较st0和0                                               |

这些指令会改变协处理器状态寄存器中的C0,C1,C2,C3比特位的值，但是cpu并不能直接访问它们。条件分支语句使用的是FLAGS寄存器，而不是协处理器中的状态寄存器。以下的几条指令可以将状态字的比特位传递到FLAGS寄存器上相同的比特位中。

| 指令       | 解释                                           |
| ---------- | ---------------------------------------------- |
| fstsw dest | 将协处理器状态字存储到内存的一个字或ax寄存器中 |
| sahf       | 将ah寄存器中的值储存到FLAGS寄存器中            |
| lahf       | 将FLAGS寄存器中的比特位导入到ah寄存器中        |

Pentium处理器支持两条新比较指令，用来直接改变CPU中FLAGS寄存器的值。

| 指令       | 解释                                        |
| ---------- | ------------------------------------------- |
| fcomi src  | 比较st0和src。src必须是一个协处理器寄存器。 |
| fcomip src | 与上面的指令相比，区别是比较完弹出。        |

**杂项指令**

| 指令   | 解释                                                         |
| ------ | ------------------------------------------------------------ |
| fchs   | st0 = -st0 改变st0符号位                                     |
| fabs   | st0 = st0的绝对值 求st0的绝对值                              |
| fsqrt  | st0 = st0的开方 求st0的平方根                                |
| fscale | st0 = st0 * 2 ^ st1 快速执行st0乘以2的几次方的操作。st1不会从协处理器堆栈中移除。 |

fstcw 检查未决的无掩码浮点异常之后，将 FPU 控制字存储到 **m2byte**。