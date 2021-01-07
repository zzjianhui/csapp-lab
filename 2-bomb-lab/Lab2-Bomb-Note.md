# Lab 2 Bomb



## Phase 1


首先，使用gdb对可执行文件bomb进行调试：
```shell
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ gdb bomb 
GNU gdb (Ubuntu 9.2-0ubuntu1~20.04) 9.2
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from bomb...
```
通过使用l，能够发现phase 1的关键代码在下面的74行，函数phase_1中。
```shell
(gdb) l
69          printf("Welcome to my fiendish little bomb. You have 6 phases with\n");
70          printf("which to blow yourself up. Have a nice day!\n");
71
72          /* Hmm...  Six phases must be more secure than one phase! */
73          input = read_line();             /* Get input                   */
74          phase_1(input);                  /* Run the phase               */
75          phase_defused();                 /* Drat!  They figured it out!
76                                            * Let me know how they did it. */
77          printf("Phase 1 defused. How about the next one?\n");
```
对phase_1函数反编译代码如下所示：
```shell
0x0000000000400ee0 <+0>:     sub    $0x8,%rsp                   ;在栈帧上分配8个byte的空间
0x0000000000400ee4 <+4>:     mov    $0x402400,%esi              ;将0x402400放入寄存器%esi，%esi通常为输入函数的第二个参数
0x0000000000400ee9 <+9>:     callq  0x401338 <strings_not_equal>;调用函数strings_not_equal，输入参数为%edi和%esi，函数返回值存放在%eax寄存器中
0x0000000000400eee <+14>:    test   %eax,%eax                   ;执行%eax&%eax操作，仅修改条件码寄存器的值，这条语句用于测试%eax为正数还是负数还是零
0x0000000000400ef0 <+16>:    je     0x400ef7 <phase_1+23>       ;jump指令，如果条件码寄存器ZF为1，跳转到地址0x400ef7处
0x0000000000400ef2 <+18>:    callq  0x40143a <explode_bomb>     ;调用函数explode_bomb，引爆炸弹
0x0000000000400ef7 <+23>:    add    $0x8,%rsp
0x0000000000400efb <+27>:    retq
```
根据对上面的汇编代码进行解析，仅需输入的字符串等于内存地址0x402400处字符串，才能阻止炸弹爆炸。所以，我们可以通过gdb查看内存地址0x402400处存放字符串内容：
```shell
(gdb) x/s 0x402400
0x402400:       "Border relations with Canada have never been better."
```
可以发现，答案就在上面。
### phase 1中遇到的问题
#### 1. 为什么上面的反汇编代码中，需要在开头将%rsp减0x8，最后又加0x8，中间也没有用到%rsp？


## Phase 2


根据上一步的经验，首先使用gdb对bomb可执行文件进行调试：
```shell
$ gdb bomb 
```
接下来，使用l命令找到phase 2的关键函数：
```shell
79          /* The second phase is harder.  No one will ever figure out
80           * how to defuse this... */
81          input = read_line();
82          phase_2(input);
(gdb) l
83          phase_defused();
84          printf("That's number 2.  Keep going!\n");
```
从上面可以发现，关键函数和phase 1相同，都是在phase_2函数中，并且输入参数也相同，这时，可以尝试反编译phase_2函数：
```shell
(gdb) disassemble phase_2 
Dump of assembler code for function phase_2:
   0x0000000000400efc <+0>:     push   %rbp
   0x0000000000400efd <+1>:     push   %rbx
   0x0000000000400efe <+2>:     sub    $0x28,%rsp                 ;在栈帧上分配40byte
   0x0000000000400f02 <+6>:     mov    %rsp,%rsi                  ;将栈顶地址放入%rsi中，%rsi代表第二个参数
   0x0000000000400f05 <+9>:     callq  0x40145c <read_six_numbers>;调用函数，参数1为%rdi，参数2为%rsi
   0x0000000000400f0a <+14>:    cmpl   $0x1,(%rsp)                ;(%rsp)-0x1，得到的值放入(%rsp)中，并根据得到的值设置条件码寄存器。(%rsp)的值为函数read_six_numbers第二个参数值，该值必须为0x1
   0x0000000000400f0e <+18>:    je     0x400f30 <phase_2+52>      ;如果ZF寄存器为1（cmpl得到结果为0），跳转到地址0x400f30处。（！！！该处必须为0，否则将引爆炸弹）
   0x0000000000400f10 <+20>:    callq  0x40143a <explode_bomb>    ;引爆炸弹
   0x0000000000400f15 <+25>:    jmp    0x400f30 <phase_2+52>
   0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax            ;%eax=M[%rbx-0x4]，将地址%rbx-0x4处的值放入%eax中
   0x0000000000400f1a <+30>:    add    %eax,%eax
   0x0000000000400f1c <+32>:    cmp    %eax,(%rbx)                ;M[%rbx]=M[%rbx]-%eax，根据得到的值设置条件码寄存器
   0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41>      ;若ZF寄存器为1，跳转到0x400f25。（！！必须为1，不然将爆炸）
   0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb>    ;引爆炸弹
   0x0000000000400f25 <+41>:    add    $0x4,%rbx
   0x0000000000400f29 <+45>:    cmp    %rbp,%rbx                  ;%rbx=%rbx-%rbp
   0x0000000000400f2c <+48>:    jne    0x400f17 <phase_2+27>      ;如果ZF寄存器为0（cmp结果不为0），跳转到0x400f17（这里%rbp应与%rbx相等）
   0x0000000000400f2e <+50>:    jmp    0x400f3c <phase_2+64>      ;跳转到0x400f3c处（这是出口）
   0x0000000000400f30 <+52>:    lea    0x4(%rsp),%rbx             ;%rbx = %rsp + 0x4
   0x0000000000400f35 <+57>:    lea    0x18(%rsp),%rbp            ;%rbp = %rsp + 0x18
   0x0000000000400f3a <+62>:    jmp    0x400f17 <phase_2+27>      ;跳转到地址0x400f17处
   0x0000000000400f3c <+64>:    add    $0x28,%rsp
   0x0000000000400f40 <+68>:    pop    %rbx
   0x0000000000400f41 <+69>:    pop    %rbp
   0x0000000000400f42 <+70>:    retq   
End of assembler dump.
```
上面的函数phase_2调用了函数read_six_number，该函数输入两个参数，一个是char *input，存放在寄存器%rdi中，表示输入的字符串，一个是指针变量，返回值可以存放在该变量中，该变量通过寄存器%rsi保存地址。使用gdb输出该函数的汇编代码：
```shell
(gdb) disassemble read_six_numbers 
Dump of assembler code for function read_six_numbers:
   0x000000000040145c <+0>:  sub    $0x18,%rsp                    ;栈帧上分配24byte内存空间
   0x0000000000401460 <+4>:  mov    %rsi,%rdx                     ;第3个参数
   0x0000000000401463 <+7>:  lea    0x4(%rsi),%rcx                ;第4个参数
   0x0000000000401467 <+11>: lea    0x14(%rsi),%rax               
   0x000000000040146b <+15>: mov    %rax,0x8(%rsp)                ;第8个参数
   0x0000000000401470 <+20>: lea    0x10(%rsi),%rax               ;
   0x0000000000401474 <+24>: mov    %rax,(%rsp)                   ;第7个参数
   0x0000000000401478 <+28>: lea    0xc(%rsi),%r9                 ;第6个参数%r8赋值
   0x000000000040147c <+32>: lea    0x8(%rsi),%r8                 ;第5个参数%r8赋值
   0x0000000000401480 <+36>: mov    $0x4025c3,%esi                ;第2个参数%esi赋值0x4025c3
   0x0000000000401485 <+41>: mov    $0x0,%eax
   0x000000000040148a <+46>: callq  0x400bf0 <__isoc99_sscanf@plt>;调用sscanf函数，返回值放入%eax中
   0x000000000040148f <+51>: cmp    $0x5,%eax                     ;%eax=%eax-0x5
   0x0000000000401492 <+54>: jg     0x401499 <read_six_numbers+61>;如果%eax值大于0，跳转到0x401499
   0x0000000000401494 <+56>: callq  0x40143a <explode_bomb>
   0x0000000000401499 <+61>: add    $0x18,%rsp
   0x000000000040149d <+65>: retq   
End of assembler dump.
```
根据阅读read_six_number的汇编代码可知，仅当sscanf成功匹配至少6个，才能避免爆炸。并且，read_six_number的第二个参数是数组变量，数组长度为6，数组每个元素的地址分别为：%rsi，%rsi+4，，%rsi+8，%rsi+12，%rsi+16，%rsi+20。


通过输出内存地址0x4025c3的字符串，如下所示，也就是6个整型变量，我们的答案是6个整型变量。
```shell
(gdb) x/s 0x4025c3
0x4025c3:       "%d %d %d %d %d %d"
```


在函数phase_2中，%rsp与%rsi存放的地址相同，所以%rsp与%rsi指向相同的内存位置。


通过阅读phase_2代码，可知phase_2中生成6个数字，分别为1，2，4，8，16，32。


启动bomb程序，输入如下内容，通过：
```shell
Starting program: /home/zjh/code/my_code/csapp-lab/2-bomb-lab/bomb/bomb 
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Border relations with Canada have never been better.
Phase 1 defused. How about the next one?
1 2 4 8 16 32
That's number 2.  Keep going!
```


## Phase 3
根据前面的经验，先对函数phase_3进行反编译：
```shell
(gdb) disassemble phase_3 
Dump of assembler code for function phase_3:
   0x0000000000400f43 <+0>:     sub    $0x18,%rsp                    ;分配25byte栈帧空间
   0x0000000000400f47 <+4>:     lea    0xc(%rsp),%rcx                ;第4个参数
   0x0000000000400f4c <+9>:     lea    0x8(%rsp),%rdx                ;第3个参数
   0x0000000000400f51 <+14>:    mov    $0x4025cf,%esi                ;第2个参数
   0x0000000000400f56 <+19>:    mov    $0x0,%eax
   0x0000000000400f5b <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>
   0x0000000000400f60 <+29>:    cmp    $0x1,%eax                     ;sscanf必须匹配2个以上的整型变量
   0x0000000000400f63 <+32>:    jg     0x400f6a <phase_3+39>
   0x0000000000400f65 <+34>:    callq  0x40143a <explode_bomb>
   0x0000000000400f6a <+39>:    cmpl   $0x7,0x8(%rsp)                ;执行0x8(%rsp)-0x7，总共有7个case
   0x0000000000400f6f <+44>:    ja     0x400fad <phase_3+106>
   0x0000000000400f71 <+46>:    mov    0x8(%rsp),%eax
   0x0000000000400f75 <+50>:    jmpq   *0x402470(,%rax,8)            ;switch语句，根据前面cmpl的判断进行选择
   0x0000000000400f7c <+57>:    mov    $0xcf,%eax
   0x0000000000400f81 <+62>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f83 <+64>:    mov    $0x2c3,%eax
   0x0000000000400f88 <+69>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f8a <+71>:    mov    $0x100,%eax
   0x0000000000400f8f <+76>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f91 <+78>:    mov    $0x185,%eax
   0x0000000000400f96 <+83>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f98 <+85>:    mov    $0xce,%eax
   0x0000000000400f9d <+90>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f9f <+92>:    mov    $0x2aa,%eax
   0x0000000000400fa4 <+97>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400fa6 <+99>:    mov    $0x147,%eax
   0x0000000000400fab <+104>:   jmp    0x400fbe <phase_3+123>
   0x0000000000400fad <+106>:   callq  0x40143a <explode_bomb>
   0x0000000000400fb2 <+111>:   mov    $0x0,%eax
   0x0000000000400fb7 <+116>:   jmp    0x400fbe <phase_3+123>
   0x0000000000400fb9 <+118>:   mov    $0x137,%eax
   0x0000000000400fbe <+123>:   cmp    0xc(%rsp),%eax
   0x0000000000400fc2 <+127>:   je     0x400fc9 <phase_3+134>
   0x0000000000400fc4 <+129>:   callq  0x40143a <explode_bomb>
   0x0000000000400fc9 <+134>:   add    $0x18,%rsp
   0x0000000000400fcd <+138>:   retq   
End of assembler dump.
```
通过阅读上面的代码，第一个可以发现的地方是，输入的字符串是两个整型数。


第二个可以发现的是，其使用了switch语句，并将输入字符串的第一个数作为判断switch的判断条件。并且有8个case选项，这些选项在执行完后，会跳转到0x400fbe地址处。


所以，根据上面的代码，对于输入的第一个整型变量，我们有8个选择，分别为0，1，2，3，4，5，6，7。其对应的第二个整型变量分别对应到各个case。上面的代码写成C语言代码，可以为如下所示，所以答案有8个选项。
```c
void phase_3(char *input){
	int x1,x2,x;
    sscanf(input,"%d %d",&x1,&x2);
    
	switch(x1){
        case 0: x=207; break;
        case 1: x=311; break;
        case 2: x=707; break;
        case 3: x=256; break;
        case 4: x=389; break;
        case 5: x=206; break;
        case 6: x=682; break;
        case 7: x=327; break;
        default: explode_bomb();
    }
}
```
所以，解锁如下所示：
```shell
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result0 
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result1
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result2
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result3
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result4
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result5
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result6
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result7
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
^CSo you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)
```
其中，result0~7分别为如下所示：
```shell
0 207
1 311
2 707
3 256
4 389
5 206
6 682
7 327
```
## Phase4
根据上面的经验，我们首先使用gdb反编译函数phase_4，结果如下：
```shell
(gdb) disassemble phase_4 
Dump of assembler code for function phase_4:
   0x000000000040100c <+0>:    sub    $0x18,%rsp                    ;在栈帧上分配24个内存空间
   0x0000000000401010 <+4>:    lea    0xc(%rsp),%rcx                ;第4个参数
   0x0000000000401015 <+9>:    lea    0x8(%rsp),%rdx                ;第3个参数
   0x000000000040101a <+14>:   mov    $0x4025cf,%esi                ;第2个参数
   0x000000000040101f <+19>:   mov    $0x0,%eax
   0x0000000000401024 <+24>:   callq  0x400bf0 <__isoc99_sscanf@plt>
   0x0000000000401029 <+29>:   cmp    $0x2,%eax                     ;匹配两个（不多不少）
   0x000000000040102c <+32>:   jne    0x401035 <phase_4+41>         ;若%eax不等于0x2，跳转到0x401035，爆炸
   0x000000000040102e <+34>:   cmpl   $0xe,0x8(%rsp)
   0x0000000000401033 <+39>:   jbe    0x40103a <phase_4+46>         ;若0x8(%rsp)<=0xe，跳转到0x40103a，否则爆炸
   0x0000000000401035 <+41>:   callq  0x40143a <explode_bomb>
   0x000000000040103a <+46>:   mov    $0xe,%edx                     ;第3个参数
   0x000000000040103f <+51>:   mov    $0x0,%esi                     ;第2个参数
   0x0000000000401044 <+56>:   mov    0x8(%rsp),%edi                ;第1个参数
   0x0000000000401048 <+60>:   callq  0x400fce <func4>              ;调用函数func4
   0x000000000040104d <+65>:   test   %eax,%eax                     ;检测返回值%eax是整数，负数，还是零
   0x000000000040104f <+67>:   jne    0x401058 <phase_4+76>         ;若%eax非0，跳转到0x401058，爆炸
   0x0000000000401051 <+69>:   cmpl   $0x0,0xc(%rsp)
   0x0000000000401056 <+74>:   je     0x40105d <phase_4+81>         ;若0xc(%rsp)==0，结束，否则爆炸
   0x0000000000401058 <+76>:   callq  0x40143a <explode_bomb>
   0x000000000040105d <+81>:   add    $0x18,%rsp
   0x0000000000401061 <+85>:   retq
End of assembler dump.
```
输出内存地址0x4025cf位置存放的字符串，可以发现，phase 4依然是输入两个整型数据。
```shell
(gdb) x/s 0x4025cf
0x4025cf:       "%d %d"
```
通过阅读上面的代码，可以写出C语言形式：
```c
void phase_4(char *input){
	int x1, x2;
    int r = sscanf(input ,"%d %d", &x1, &x2);
    if (r != 2) explode_bomb();
    if (x1 <= 0xe && x1 >= 0) {
    	int r2 = func4(x1, 0, 0xe);
        if (r2 != 0) explode_bomb();
        if (x2 != 0) explode_bomb();
    } else {
    	explode_bomb();
    }
}
```
从上面的C语言代码中可以发现，第一个整型数据应该大于等于0，小于等于0xe，并别输入到函数func4后，返回值应为0。


第二个整型数应该为0。


反汇编输出func4函数，通过阅读下面的代码，可以发现func4函数是一个递归函数：
```shell
(gdb) disassemble func4 
Dump of assembler code for function func4:       ;参数1：%rdi=x1，参数2：%rsi=0，参数3：%rdx=0xe
   0x0000000000400fce <+0>:     sub    $0x8,%rsp
   0x0000000000400fd2 <+4>:     mov    %edx,%eax
   0x0000000000400fd4 <+6>:     sub    %esi,%eax
   0x0000000000400fd6 <+8>:     mov    %eax,%ecx
   0x0000000000400fd8 <+10>:    shr    $0x1f,%ecx
   0x0000000000400fdb <+13>:    add    %ecx,%eax
   0x0000000000400fdd <+15>:    sar    %eax
   0x0000000000400fdf <+17>:    lea    (%rax,%rsi,1),%ecx
   0x0000000000400fe2 <+20>:    cmp    %edi,%ecx
   0x0000000000400fe4 <+22>:    jle    0x400ff2 <func4+36>
   0x0000000000400fe6 <+24>:    lea    -0x1(%rcx),%edx
   0x0000000000400fe9 <+27>:    callq  0x400fce <func4>
   0x0000000000400fee <+32>:    add    %eax,%eax
   0x0000000000400ff0 <+34>:    jmp    0x401007 <func4+57>
   0x0000000000400ff2 <+36>:    mov    $0x0,%eax
   0x0000000000400ff7 <+41>:    cmp    %edi,%ecx
   0x0000000000400ff9 <+43>:    jge    0x401007 <func4+57>
   0x0000000000400ffb <+45>:    lea    0x1(%rcx),%esi
   0x0000000000400ffe <+48>:    callq  0x400fce <func4>
   0x0000000000401003 <+53>:    lea    0x1(%rax,%rax,1),%eax
   0x0000000000401007 <+57>:    add    $0x8,%rsp
   0x000000000040100b <+61>:    retq   
End of assembler dump.
```
通过阅读上面的汇编代码，可以将其转换成如下C语言代码。通过仔细阅读下面的代码，似乎是一个折半搜索算法的改版。通过阅读下面代码可知，仅当搜索算法中，x1一直走`x1 < temp`的路径以及`x1 == temp`的路径，func4才能返回0。
```c
int func4(int x1, int a, int b) {
    int temp = a + (b - a + (b - a) >> 0x1f) >> 1;
    if(temp == x1) {
        return 0;
    } else if(temp < x1) {
            return 2 * func4(x1, temp + 1, b) + 1;
    } else if(temp > x1) {
        return 2 * func4(x1, a, temp -1);
    }
}
```
所以可知，phase 4的解为如下所示：
```c
0 0
1 0
3 0
7 0
```
## Phase5
根据前面的经验，反编译函数phase_5。
```shell
(gdb) disassemble phase_5
Dump of assembler code for function phase_5:                  ;第1个参数%rdi
   0x0000000000401062 <+0>:     push   %rbx
   0x0000000000401063 <+1>:     sub    $0x20,%rsp              ;栈帧上分配32byte空间
   0x0000000000401067 <+5>:     mov    %rdi,%rbx               ;
   0x000000000040106a <+8>:     mov    %fs:0x28,%rax           ;
   0x0000000000401073 <+17>:    mov    %rax,0x18(%rsp)         ;(%rsp+25)=%rax
   0x0000000000401078 <+22>:    xor    %eax,%eax               ;得到的结果%eax为全为0
   0x000000000040107a <+24>:    callq  0x40131b <string_length>
   0x000000000040107f <+29>:    cmp    $0x6,%eax               ;若字符串长度为6，则跳转到0x4010d2，否则爆炸
   0x0000000000401082 <+32>:    je     0x4010d2 <phase_5+112>
   0x0000000000401084 <+34>:    callq  0x40143a <explode_bomb>
   0x0000000000401089 <+39>:    jmp    0x4010d2 <phase_5+112>
   0x000000000040108b <+41>:    movzbl (%rbx,%rax,1),%ecx      ;%ecx=(%rbx+%rax)
   0x000000000040108f <+45>:    mov    %cl,(%rsp)              ;(%rsp)=%cl，这里%cl寄存器仅有8位
   0x0000000000401092 <+48>:    mov    (%rsp),%rdx
   0x0000000000401096 <+52>:    and    $0xf,%edx
   0x0000000000401099 <+55>:    movzbl 0x4024b0(%rdx),%edx
   0x00000000004010a0 <+62>:    mov    %dl,0x10(%rsp,%rax,1)  ;(%rsp+%rax+0x10)=%dl
   0x00000000004010a4 <+66>:    add    $0x1,%rax
   0x00000000004010a8 <+70>:    cmp    $0x6,%rax
   0x00000000004010ac <+74>:    jne    0x40108b <phase_5+41>   ;若%rax!=6，跳转到0x40108b，循环6次
   0x00000000004010ae <+76>:    movb   $0x0,0x16(%rsp)
   0x00000000004010b3 <+81>:    mov    $0x40245e,%esi          ;第2个参数
   0x00000000004010b8 <+86>:    lea    0x10(%rsp),%rdi         ;第1个参数
   0x00000000004010bd <+91>:    callq  0x401338 <strings_not_equal>
   0x00000000004010c2 <+96>:    test   %eax,%eax               ;也就是两个字符串相等，则继续
   0x00000000004010c4 <+98>:    je     0x4010d9 <phase_5+119>  ;若%eax为0，跳转到0x4010d9，否则爆炸
   0x00000000004010c6 <+100>:   callq  0x40143a <explode_bomb>
   0x00000000004010cb <+105>:   nopl   0x0(%rax,%rax,1)
   0x00000000004010d0 <+110>:   jmp    0x4010d9 <phase_5+119>
   0x00000000004010d2 <+112>:   mov    $0x0,%eax
   0x00000000004010d7 <+117>:   jmp    0x40108b <phase_5+41>
   0x00000000004010d9 <+119>:   mov    0x18(%rsp),%rax         ;%rax=(%rsp+0x18)
   0x00000000004010de <+124>:   xor    %fs:0x28,%rax
   0x00000000004010e7 <+133>:   je     0x4010ee <phase_5+140>  ;
   0x00000000004010e9 <+135>:   callq  0x400b30 <__stack_chk_fail@plt>
   0x00000000004010ee <+140>:   add    $0x20,%rsp
   0x00000000004010f2 <+144>:   pop    %rbx
   0x00000000004010f3 <+145>:   retq   
End of assembler dump.
```
通过阅读上面的代码，可以发现以下内容：

1. 输入的字符串长度应为6
1. 输入的字符串每个字符通过某种变换，变为地址0x40245e处的值，该值为**"flyers"**。对应的代码位置为14~21行。
```shell
(gdb) x/s 0x40245e
0x40245e:       "flyers"
```
上面的关键代码如下，
```shell
   0x000000000040108b <+41>:    movzbl (%rbx,%rax,1),%ecx      ;%ecx=(%rbx+%rax)
   0x000000000040108f <+45>:    mov    %cl,(%rsp)              ;(%rsp)=%cl，这里%cl寄存器仅有8位
   0x0000000000401092 <+48>:    mov    (%rsp),%rdx
   0x0000000000401096 <+52>:    and    $0xf,%edx
   0x0000000000401099 <+55>:    movzbl 0x4024b0(%rdx),%edx
   0x00000000004010a0 <+62>:    mov    %dl,0x10(%rsp,%rax,1)  ;(%rsp+%rax+0x10)=%dl
   0x00000000004010a4 <+66>:    add    $0x1,%rax
   0x00000000004010a8 <+70>:    cmp    $0x6,%rax
```

1. 第一行：从地址为%rbx+%rax处取出一个字符值（8位），存放到%ecx中。（%rbx指向的内存存放6个字符，而%rax就如索引一样，在每次循环取出一个字符）
1. 第二行：将%ecx的低8位值放入栈顶
1. 第三行：从栈顶取出8位值放入%rdx中
1. 第四行：将该字符值与0x0f进行逻辑与操作，得到的值高4位为0，低4位值不变。
1. 从地址0x4024b0+%rdx处获取8位值（单个字符），放入到%edx中
1. 将得到的字符放入(%rsp+%rax+0x10)中。



上面的代码中，第5行中显示，从地址0x4024b0加上偏移量的位置获取字符，我们可以输出该地址的字符串，如下所示：
```shell
(gdb) x/s 0x4024b0
0x4024b0 <array.3449>:  "maduiersnfotvbylSo you think you can stop the bomb with ctrl-c, do you?"
```


在上面6次循环结束后，%rsp+16~%rsp+21处存放6个字符。

根据地址0x40245e处的值，该值为**"flyers"**可知，地址0x4024b0的偏移量%rdx的值分别为：0x1001，0x1111，0x1110，0x0101，0x0110，0x0110。对应0x9，0xf，0xe，0x5，0x6，0x7。通过查询ASCII表格，可以找出字符的后4位与上面相同的，可以作为结果。

这里列出其中一个结果：
```shell
使用字符串：yonuvw

zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result0 
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
So you got that one.  Try this one.
Good work!  On to the next...
```
## Phase6
先反编译phase_6函数：
```shell
(gdb) disassemble phase_6 
Dump of assembler code for function phase_6:
   0x00000000004010f4 <+0>:     push   %r14
   0x00000000004010f6 <+2>:     push   %r13
   0x00000000004010f8 <+4>:     push   %r12
   0x00000000004010fa <+6>:     push   %rbp
   0x00000000004010fb <+7>:     push   %rbx
   0x00000000004010fc <+8>:     sub    $0x50,%rsp                ;在栈帧上分配80byte空间
   0x0000000000401100 <+12>:    mov    %rsp,%r13
   0x0000000000401103 <+15>:    mov    %rsp,%rsi                  ;第2个参数
   0x0000000000401106 <+18>:    callq  0x40145c <read_six_numbers>;至少匹配6个整型数值
   0x000000000040110b <+23>:    mov    %rsp,%r14
   0x000000000040110e <+26>:    mov    $0x0,%r12d
   0x0000000000401114 <+32>:    mov    %r13,%rbp
   0x0000000000401117 <+35>:    mov    0x0(%r13),%eax
   0x000000000040111b <+39>:    sub    $0x1,%eax
   0x000000000040111e <+42>:    cmp    $0x5,%eax
   0x0000000000401121 <+45>:    jbe    0x401128 <phase_6+52>;%eax<=0x5，跳转到0x401128，否则爆炸
   0x0000000000401123 <+47>:    callq  0x40143a <explode_bomb>
   0x0000000000401128 <+52>:    add    $0x1,%r12d
   0x000000000040112c <+56>:    cmp    $0x6,%r12d
   0x0000000000401130 <+60>:    je     0x401153 <phase_6+95>
   0x0000000000401132 <+62>:    mov    %r12d,%ebx
   0x0000000000401135 <+65>:    movslq %ebx,%rax
   0x0000000000401138 <+68>:    mov    (%rsp,%rax,4),%eax
   0x000000000040113b <+71>:    cmp    %eax,0x0(%rbp)
   0x000000000040113e <+74>:    jne    0x401145 <phase_6+81>   ;如果%eax（%eax为第2，3，4，5，6参数）与第1参数不相等，跳转到0x401145（这里暗示，第1参数与其他参数值不同）
   0x0000000000401140 <+76>:    callq  0x40143a <explode_bomb>
   0x0000000000401145 <+81>:    add    $0x1,%ebx
   0x0000000000401148 <+84>:    cmp    $0x5,%ebx
   0x000000000040114b <+87>:    jle    0x401135 <phase_6+65> ;循环，循环5次（1，2，3，4，5）
   0x000000000040114d <+89>:    add    $0x4,%r13
   0x0000000000401151 <+93>:    jmp    0x401114 <phase_6+32>;循环，%rbp+=4。这里是双重循环，主要目的是验证前面参数与其所有后面参数不相等。（例如x1不等于x2,x3,...,x6，x2不等于x3,...,x6，也就保证每个参数不相等）
   0x0000000000401153 <+95>:    lea    0x18(%rsp),%rsi
   0x0000000000401158 <+100>:   mov    %r14,%rax             ;保存指向第1参数的地址
   0x000000000040115b <+103>:   mov    $0x7,%ecx
   0x0000000000401160 <+108>:   mov    %ecx,%edx
   0x0000000000401162 <+110>:   sub    (%rax),%edx           ;%edx=%edx-x1（%edx=7-x1）
   0x0000000000401164 <+112>:   mov    %edx,(%rax)           ;x1=7-x1
   0x0000000000401166 <+114>:   add    $0x4,%rax
   0x000000000040116a <+118>:   cmp    %rsi,%rax
   0x000000000040116d <+121>:   jne    0x401160 <phase_6+108>;依然是循环，循环6次，对每个参数计算（x=7-x）
   0x000000000040116f <+123>:   mov    $0x0,%esi
   0x0000000000401174 <+128>:   jmp    0x401197 <phase_6+163>
   0x0000000000401176 <+130>:   mov    0x8(%rdx),%rdx
   0x000000000040117a <+134>:   add    $0x1,%eax
   0x000000000040117d <+137>:   cmp    %ecx,%eax
   0x000000000040117f <+139>:   jne    0x401176 <phase_6+130>
   0x0000000000401181 <+141>:   jmp    0x401188 <phase_6+148>
   0x0000000000401183 <+143>:   mov    $0x6032d0,%edx
   0x0000000000401188 <+148>:   mov    %rdx,0x20(%rsp,%rsi,2);将%rdx值存放在
   0x000000000040118d <+153>:   add    $0x4,%rsi
   0x0000000000401191 <+157>:   cmp    $0x18,%rsi
   0x0000000000401195 <+161>:   je     0x4011ab <phase_6+183>
   0x0000000000401197 <+163>:   mov    (%rsp,%rsi,1),%ecx
   0x000000000040119a <+166>:   cmp    $0x1,%ecx
   0x000000000040119d <+169>:   jle    0x401183 <phase_6+143>;如果x1<=0x1，依然是循环6次
   0x000000000040119f <+171>:   mov    $0x1,%eax
   0x00000000004011a4 <+176>:   mov    $0x6032d0,%edx
   0x00000000004011a9 <+181>:   jmp    0x401176 <phase_6+130>
   0x00000000004011ab <+183>:   mov    0x20(%rsp),%rbx
   0x00000000004011b0 <+188>:   lea    0x28(%rsp),%rax
   0x00000000004011b5 <+193>:   lea    0x50(%rsp),%rsi
   0x00000000004011ba <+198>:   mov    %rbx,%rcx
   0x00000000004011bd <+201>:   mov    (%rax),%rdx
   0x00000000004011c0 <+204>:   mov    %rdx,0x8(%rcx)
   0x00000000004011c4 <+208>:   add    $0x8,%rax
   0x00000000004011c8 <+212>:   cmp    %rsi,%rax
   0x00000000004011cb <+215>:   je     0x4011d2 <phase_6+222>
   0x00000000004011cd <+217>:   mov    %rdx,%rcx
   0x00000000004011d0 <+220>:   jmp    0x4011bd <phase_6+201>
   0x00000000004011d2 <+222>:   movq   $0x0,0x8(%rdx)
   0x00000000004011da <+230>:   mov    $0x5,%ebp
   0x00000000004011df <+235>:   mov    0x8(%rbx),%rax
   0x00000000004011e3 <+239>:   mov    (%rax),%eax
   0x00000000004011e5 <+241>:   cmp    %eax,(%rbx)
   0x00000000004011e7 <+243>:   jge    0x4011ee <phase_6+250>
   0x00000000004011e9 <+245>:   callq  0x40143a <explode_bomb>
   0x00000000004011ee <+250>:   mov    0x8(%rbx),%rbx
   0x00000000004011f2 <+254>:   sub    $0x1,%ebp
   0x00000000004011f5 <+257>:   jne    0x4011df <phase_6+235>
   0x00000000004011f7 <+259>:   add    $0x50,%rsp
   0x00000000004011fb <+263>:   pop    %rbx
   0x00000000004011fc <+264>:   pop    %rbp
   0x00000000004011fd <+265>:   pop    %r12
   0x00000000004011ff <+267>:   pop    %r13
   0x0000000000401201 <+269>:   pop    %r14
   0x0000000000401203 <+271>:   retq   
End of assembler dump.
```
根据上面的汇编代码，可以做出如下所示流程图：
![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1609986815023-68c7cd92-85e2-4a10-929f-b65e7d0742b5.png#align=left&display=inline&height=5192&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5192&originWidth=1840&size=403331&status=done&style=none&width=1840)
### 第一阶段
下图中红圈内部的内容可知：

1. 输入数据是6个整型数据。
1. 前6个数据都是小于等于6，大于等于0的。也就是1<=x<=6。
1. 并且6个数据都互不相等，所以6个数分别为1，2，3，4，5，6。

![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1609987205447-bb93a402-a7da-4090-8f4a-4795a1caa300.png#align=left&display=inline&height=5216&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5216&originWidth=2001&size=330602&status=done&style=none&width=2001)
### 第二阶段
根据下图中红色圈内代码显示，可知该代码循环执行6次，也就是对于存储在%rsp，%rsp+4，%rsp+8，%rsp+12，%rsp+16，%rsp+20的6个整型数据，都执行(%rsp)=7-(%rsp)。这时存放在%rsp中的6个值，范围还是1~6。
![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1609987816771-ed09ab94-8d29-4d8a-a723-b7e87fe79062.png#align=left&display=inline&height=5192&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5192&originWidth=1840&size=314426&status=done&style=none&width=1840)
### 第三阶段
依旧是循环，根据%rsi的值判断是否终止，循环6次


- 对于每个存储在%rsp的值，如果该%rsp等于1，则在设置位置(%rsp+8*i+32)处为0x6032d0。
- 如果%rsp大于1，则将(%rsp+8*i+32)处设置为，(0x6032d0+8*(x-1))值。



其中(%rsp+2i*(0x4)+0x20)在根据顺序可以列出，分别为(%rsp+32)，(%rsp+40)，(%rsp+48)，(%rsp+56)，(%rsp+64)，(%rsp+72)。

根据上面的分析可知，如果%rsp为1（真实情况x应为6），则位置(%rsp+8*i+32)处为0x6032d0。
如果%rsp为大于1，则(%rsp+8*i+32)处为(0x6032d0+8*(x-1))。

| 输入的6个数据 | 该6个数据所在的位置 | 每个数据对应的node |
| --- | --- | --- |
| 第1个数据 | (%rsp) | (%rsp+32) |
| 第2个数据 | (%rsp+4) | (%rsp+40) |
| 第3个数据 | (%rsp+8) | (%rsp+48) |
| 第4个数据 | (%rsp+12) | (%rsp+56) |
| 第5个数据 | (%rsp+16) | (%rsp+64) |
| 第6个数据 | (%rsp+20) | (%rsp+72) |



通过输出地址0x6032d0位置的内容，可以发现在地址0x6032d0处存放的是结构体数组，该结构体后面是指针，指向下一个node。
```shell
(gdb) x/12xg 0x6032d0
0x6032d0 <node1>:       0x000000010000014c      0x00000000006032e0
0x6032e0 <node2>:       0x00000002000000a8      0x00000000006032f0
0x6032f0 <node3>:       0x000000030000039c      0x0000000000603300
0x603300 <node4>:       0x00000004000002b3      0x0000000000603310
0x603310 <node5>:       0x00000005000001dd      0x0000000000603320
0x603320 <node6>:       0x00000006000001bb      0x0000000000000000
```
这时，我们可以写出上面的c语言代码：
```c
typedef struct node
{
    某个或多个数据;
	node *next;
}node;
```
通过上面的分析可以知道，如果(%rsp)到(%rsp+20)中的值，为1则对应0x6032d0，为node1的地址。为2则对应(0x6032d0+0x8)，为node2地址，因为0x6032d0+0x8为指向node2的指针。以此类推。所以，%rsp+32到%rsp+72存放的是各个node的地址。
![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1609989159549-b3ab591c-908b-4dd2-b12f-1f65b0f50bcf.png#align=left&display=inline&height=5192&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5192&originWidth=1862&size=315555&status=done&style=none&width=1862)
### 第四阶段
该阶段依然进行循环，通过阅读下面红圈内的汇编代码执行过程可知，其目的如下。


将存放在%rsp+32内的node的next元素指向%rsp+40位置的node。将存放在%rsp+40内的node的next元素指向%rsp+48位置的node。以此类推。
![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1610003512303-0b671844-a700-46d2-b632-4bca3aa3c207.png#align=left&display=inline&height=5244&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5244&originWidth=1840&size=316045&status=done&style=none&width=1840)
### 第五阶段
通过阅读下面的红圈内代码，可以发现，该步主要限定的内容为：(%rsp+32)位置的node第一个元素值是大于等于(%rsp+40)位置的node的第一个元素。(%rsp+40)位置的node第一个元素值是大于等于(%rsp+48)位置的node的第一个元素。以此类推。

我们可以输出每个node的详细信息，包括其地址，存放元素的信息。
```shell
(gdb) x/12xg 0x6032d0
0x6032d0 <node1>:       0x000000010000014c      0x00000000006032e0
0x6032e0 <node2>:       0x00000002000000a8      0x00000000006032f0
0x6032f0 <node3>:       0x000000030000039c      0x0000000000603300
0x603300 <node4>:       0x00000004000002b3      0x0000000000603310
0x603310 <node5>:       0x00000005000001dd      0x0000000000603320
0x603320 <node6>:       0x00000006000001bb      0x0000000000000000
```
由于根据判断条件`cmp %eax,(%rbx)`可知，比较的两个元素是32位的，我们可以逐个输出node的元素：
```shell
(gdb) x/1dw 0x6032d0
0x6032d0 <node1>:       332
(gdb) x/1dw 0x6032e0
0x6032e0 <node2>:       168
(gdb) x/1dw 0x6032f0
0x6032f0 <node3>:       924
(gdb) x/1dw 0x603300
0x603300 <node4>:       691
(gdb) x/1dw 0x603310
0x603310 <node5>:       477
(gdb) x/1dw 0x603320
0x603320 <node6>:       443
```
根据上面的信息，能够对6个node的元素大小进行排序，位node3>node4>node5>node6>node1>node2。则可知在栈帧中是如下形式：
![图片.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1610010934191-1bfb96d5-c5ac-4daa-903c-64d9400bae7a.png#align=left&display=inline&height=323&margin=%5Bobject%20Object%5D&name=%E5%9B%BE%E7%89%87.png&originHeight=323&originWidth=284&size=7113&status=done&style=none&width=284)
x1对应node3，x2对应node4，x3对应node5，x4对应node6，x5对应node1，x6对应node2。


所以，x1为3，x2为4，x3为5，x4为6，x5为1，x6为2。然后使用7-x进行计算可知需要输入的字符串为：
```shell
4 3 2 1 6 5
```




![Bomb phase 6.png](https://cdn.nlark.com/yuque/0/2021/png/1643584/1610008694912-4095d911-9059-4182-8854-492c4c3cb5c6.png#align=left&display=inline&height=5244&margin=%5Bobject%20Object%5D&name=Bomb%20phase%206.png&originHeight=5244&originWidth=1840&size=318570&status=done&style=none&width=1840)
### 最后阶段：输入答案


我们将result0设置为如下：
```shell
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ cat result0 
Border relations with Canada have never been better.
1 2 4 8 16 32
0 207
7 0
yonuvw
4 3 2 1 6 5
```
然后执行bomb程序：

```shell
zjh@node0:~/code/my_code/csapp-lab/2-bomb-lab/bomb$ ./bomb result0 
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
So you got that one.  Try this one.
Good work!  On to the next...
Congratulations! You've defused the bomb!
```
成功拆除炸弹！！！

## 附录


### 逻辑与操作&
and指令

| 1 | 1 | 1 |
| --- | --- | --- |
| 1 | 0 | 0 |
| 0 | 1 | 0 |
| 0 | 0 | 0 |



### 异或操作^
xor指令


| 1 | 0 | 1 |
| --- | --- | --- |
| 1 | 1 | 0 |
| 0 | 0 | 0 |
| 0 | 1 | 1 |



### sscanf函数
针对read_six_numbers中调用的函数__isoc99_sscanf，该函数是C语言库函数，定义与stdio.h中，其函数形式如下：
```c
int sscanf( const char *buffer, const char *format, ... );
int sscanf( const char *restrict buffer, const char *restrict format, ... );
```
从各种资源读取数据，按照format转译，并将结果存储到指定位置。
如果成功，则返回成功匹配和赋值的个数。否则，返回EOF。
使用该函数的例子：
```c
#define __STDC_WANT_LIB_EXT1__ 1
#include <stdio.h>
#include <stddef.h>
#include <locale.h>
 
int main(void)
{
    int i, j;
    float x, y;
    char str1[10], str2[4];
    wchar_t warr[2];
    setlocale(LC_ALL, "en_US.utf8");
 
    char input[] = "25 54.32E-1 Thompson 56789 0123 56ß水";
    /* 按下列分析：
       %d ：整数
       %f ：浮点值
       %9s ：最多有 9 个非空白符的字符串
       %2d ： 2 位的整数（数位 5 和 6 ）
       %f ：浮点值（数位 7 、 8 、 9）
       %*d ：不存储于任何位置的整数
       ' ' ：所有连续空白符
       %3[0-9] ：至多有 3 个十进制数字的字符串（数位 5 和 6 ）
       %2lc ：二个宽字符，使用多字节到宽转换  */
    int ret = sscanf(input, "%d%f%9s%2d%f%*d %3[0-9]%2lc",
                     &i, &x, str1, &j, &y, str2, warr);
 
    printf("Converted %d fields:\ni = %d\nx = %f\nstr1 = %s\n"
           "j = %d\ny = %f\nstr2 = %s\n"
           "warr[0] = U+%x warr[1] = U+%x\n",
           ret, i, x, str1, j, y, str2, warr[0], warr[1]);
 
#ifdef __STDC_LIB_EXT1__
    int n = sscanf_s(input, "%d%f%s", &i, &x, str1, (rsize_t)sizeof str1);
    // 写 25 到 i ， 5.432 到 x ， 9 个字节 "thompson\0" 到 str1 ，和 3 到 n 。
#endif
}
```
上述代码运行结果：
```shell
Converted 7 fields:
i = 25
x = 5.432000
str1 = Thompson
j = 56
y = 789.000000
str2 = 56
warr[0] = U+df warr[1] = U+6c34
```
### 一个关于相减的问题
下面代码中，最后寄存器%ebx的值为多少？
```shell
mov 0x7,%eax
mov 0x6,%ebx
sub %eax,%ebx
```
通过编写例子进行测试，测试例子如下C语言代码：
```c
#include <stdio.h>
  
int main(){
    int a = 0x7, b= 0x6;
    __asm__ __volatile__("sub $0x7,%0\n\t"
                    :"=b"(b)
                    :"0"(b));
    printf("%x\n",b);
    return 0;
}
```
编译执行结果如下：
```shell
zjh@node0:~/code/only_test/test$ gcc main2.c 
zjh@node0:~/code/only_test/test$ ./a.out 
ffffffff
```


