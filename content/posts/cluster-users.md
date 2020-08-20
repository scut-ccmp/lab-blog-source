---
title: cmp集群：用户手册
author: unkcpz
date: 2020-08-20
categories:
  - Manual
tags:
  - cluster
  - system
---

## 集群名称和描述

现有的集群采用SLURM任务管理，安装CentOS 7.5操作系统，使用openhpc仓库的`WareWulf`集群管理软件。

<!--more-->


现有的集群称为<span style="color:red">'cmp集群'</span>，IP为`202.38.220.15:22`。


## 用户常用的操作

- 登录服务器, `windows` 用户使用 Xmanager 或者 MobaXterm, 他们都包含了登录服务器和上传下载文件的功能, qq群里面都可以下载, 使用文档自行百度吧.

![](https://raw.githubusercontent.com/ChangChunHe/Sundries/master/baidu-1.png)
![](https://raw.githubusercontent.com/ChangChunHe/Sundries/master/baidu-2.jpg)

- 你需要熟悉一些基本的 `linux` 操作, 基本教程的pdf版本也可有在qq群里面下载.



### cmp集群分区信息
可以使用`sinfo`查询当前分区，当前有五个分区，有三类机器。

```
sinfo
  super_q  up    5-00:00:00     12    32000        7  alloc cn[98101-98102,98104-98105,98107-98109]
  super_q  up    5-00:00:00     12    32000        2   idle cn[98103,98106]
   test_q  up       1:00:00     12    32000        2   idle cn[98110-98111]
  inter_q  up    10-00:00:0     24    64000        2  alloc cn[99101-99102]
    mid_q  up    5-00:00:00     24    64000       10  alloc cn[99103-99112]
   long_q  up    10-00:00:0     24    64000        4  alloc cn[99113-99116]
  short_q  up       6:00:00     24    64000        4  alloc cn[99117-99120]
  wuzhou*  up    2-00:00:00     20   128000        9  alloc cn[97102-97110]

```

- super_q: 每节点12个物理核，32G内存。在用节点9个。cn[98101-98109]
- test_q: 每节点12个物理核，32G内存。在用节点2个。cn[98110-98111]
- inter_q: 每节点24个物理核，64G内存。在用节点2个。cn[99101-99102]
- mid_q: 每节点24物理核，64G内存。在用节点10个。cn[99103-99112]
- long_q: 每个节点24物理核，64G内存。在用节点4个。cn[99113-99116]
- short_q: 每节点24物理核，64G内存。在用节点4个。cn[99117-99120]
- wuzhou:  每个节点20物理核，128G内存。在用节点9个。cn[97102-97110]

每个分组有不同的任务时长限制，inter_q 主要是 `matlab` 脚本计算，可以申请1:24个核计算，避免申请一个节点却只有一个核计算的浪费；short_q时间较短，
主要是vasp的测试任务和一些计算量小的任务。


## vasp相关

- 赝势所在路径:``/opt/ohpc/pub/apps/vasp/pps``
- `vasp` 版本: 现有的是 5.4.4 和 5.4.1, 建议用5.4.4
- 如果你需要特殊的版本可以联系管理员编译, 如果你可以自己编译那就更好了. 集群上装了 `intel` 的编译器, `mkl` 数学库, 大家有兴趣看有自己研究一下.
建议使用 `module load intel-compiler/2018_update4` 的2018的编译器 和 `module load intel/mkl/2019_update5` 的数学库.




## 任务管理系统`SLURM`使用

可参考:

1. [Yale HPC](https://research.computing.yale.edu/support/hpc/user-guide/slurm)
2. [USC SLURM](https://hpcc.usc.edu/support/documentation/slurm/)

从`SGE`转移过来的用户可以参考:

1. [UPPMAX SGE vs SLURM](https://www.uppmax.uu.se/support/user-guides/sge-vs-slurm-comparison/)

### `SLURM`脚本提交模板
```bash
#!/bin/bash

#
#SBATCH -J NAME
# Default in slurm
# Request 5 hours run time
#SBATCH -t 5:0:0
#
#SBATCH -p short_q -N 1 -n 24
# NOTE Each short_q node has 24 cores
#

# add your job logical here!!!
module load vasp/5.4.4-impi-mkl
# we  suggest you add this command to exactly know which node you are using
echo 'This program is running at'  `hostname`
mpirun -n ${SLURM_NPROCS} vasp_std
```

## wuzhou 节点
由于 `wuzhou` 节点接入集群比较特殊, 所以提交到 `wuzhou` 节点上的任务脚本会有一点差别

```bash
#!/bin/bash
#SBATCH -J task2
#SBATCH -p wuzhou -N 1 -n 20

# need source environment variables
source /opt/ohpc/pub/mpi/intel/parallel_studio_xe_2018_update4/bin/compilervars.sh intel64
export PATH="$PATH:/opt/ohpc/pub/apps/vasp/5.4.4-impi-mkl"

mpirun -n ${SLURM_NPROCS} vasp_std
```

类似地, 如果你想运行 `matlab` , 使用 `module show ` 可以看到该 `module` 的一些具体信息, 例如:

```bash
module show matlab/R2019a

------------------------------------------------------------------------------------------------------
   /opt/ohpc/pub/modulefiles/matlab/R2019a:
------------------------------------------------------------------------------------------------------
conflict("gcc")
prepend_path("PATH","/opt/ohpc/pub/apps/matlab/R2019a/bin")
help([[This is a MATLAB R2019a]])
```

所以你只需要把 `/opt/ohpc/pub/apps/matlab/R2019a/bin` 加入路径就看有使用 `matlab` 了. 


在工作目录中写入该文件，保存名称如`job.sh`,在命令行中运行以下命令即可提交任务到节点。
其中的所有`#SBATCH`后面的参数均可以在命令行中分开指定。
<span style="color:red">*请根据任务的需求认真确定和选择`-p`和`-n`两个参数!!!*</span>
<span style="color:red">*请根据任务的需求认真确定和选择准确评估任务上限时间!!!*</span>

```sh
$ sbatch job.sh
```

<span style="color:red">*若要提交任务到指定节点，或交互式运行任务，请参考管理员手册，或直接咨询管理员。*</span>

### (OPTIONAL) 超算任务提交
超算同样使用`SLURM`作为任务管理系统。

## `module`软件模块挂载
所有的软件为了保证编译和使用环境互不冲突，使用`module`作为模块管理软件。

### 常用命令

```bash
查找可用模块
$ module avile

显示已加载模块
$ module list

装载卸载模块
$ module load vasp/5.4.4-impi-mkl
$ module unload vasp/5.4.4-impi-mkl
```

装载环境后，则 ``$PATH`` 包含vasp执行路径，同时，赝势文件的路径为 ``$PPS_PATH`` 。


### 删除文件
为了防止误删文件的发生, 我们把 `rm` 命令设置成将你要删除的文件或文件夹移到 `/home/scratch/$USER` 这个里面, `$USER` 代表你的用户名.
例如:

```bash
rm -rf my_test_dir
```

你可以在 `/home/scratch/$USER` 这下面找到 `test_dir--07-02-20-10:26:20` 类似这样的文件夹, 后面的时间是你删除的时间. 因为删除的文件会占用一部分硬盘空间, 我们会定时清理 `/home/scratch` 文件夹.


如果你想真的 `rm` 文件或文件夹, 使用命令 `/usr/bin/rm -rf my_test_dir` 就可以了.

### 恢复文件
使用命令 ``recovery_file`` 可以将移到回收站的文件或文件夹复原, 例如:

```bash
rm -rf main.py
recovery_file /home/scratch/hecc/main.py-2020-08-12-13\:21\:29
```
删除了 `main.py` 文件以后, 使用 ``recovery_file`` 就可以将 `main.py` 文件移到原本的文件夹. 如果你想将已经删除的文件移
到当前文件夹, 加上 `-current` 就可以了.

附注:这两个命令都可以接受正则表达式的参数, 例如 ``rm -rf *; recovery_file /home/scratch/hecc/*`` 就可以删除所有文件或者还原所有文件.
如果恢复文件的时候发现同名的文件或者文件夹会在名字后面加上 `-1`, 例如 `test` 会变成 `test-1`.
