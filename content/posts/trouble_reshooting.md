---
title: "常见问题及解答"
categories:
   - Q&A
date:  2018-09-19
tags:
  - cluster
  - vasp
  - pyyabc
---

<!--more-->

## Q1: VASP计算时出现强制退出, 内存爆炸的问题
## A1: 可以通过修改`~/.barshrc`文件
### 用户`~/.bashrc`配置
为使得VASP进行计算时能够处理打文件读写，用户将自己的文件句柄加大到`unlimited`，
增加`ulimit -s unlimited`，
修改后的`~/.bashrc`为：
```bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:                                                                            
# export SYSTEMD_PAGER=

# User specific aliases and functions
ulimit -s unlimited
```

除了自己的脚本和独特的软件,
<span style="color:red">***切勿修改***`~/.bashrc`</span>!!!


## Q2: 用户申请某个节点
## A2:

<span style="color:red">两次\<ctrl+D\>: 切记在运行完交互式任务后手动退出计算节点，退出计算节点后还要退出子命令行，否则节点持续被占用。</span>

### Step 1
首先使用`salloc -p short_q -N 1 -n 4`申请jpmid分区下1个节点4个核, `-n 4`可以省略不写, 默认占用全部的核数.

用`squeue`查看申请到的是哪个节点，记住节点名称比如`cn97103`，使用`ssh cn97103`进入该计算节点。

### Step 2
加载`vasp`模块

`module load vasp/5.4.4-impi-mkl`

### Step 3
运行`vasp`
`mpirun -n 4 vasp_std`
