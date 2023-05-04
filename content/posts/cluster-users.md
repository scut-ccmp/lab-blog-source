---
title: cmp集群：用户手册
author: unkcpz / hecc /cenyj
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


- 你需要熟悉一些基本的 `linux` 操作, 基本教程的pdf版本也可有在qq群里面下载.



### cmp集群分区信息
可以使用`sinfo`查询当前分区，当前有五个分区，有四类机器。

```
[hecc@cmp ~]$ sinfo
 PARTITION  AVAIL  TIMELIMIT   CPUS       MEMORY    NODES  STATE NODELIST
   super_q  up    5-00:00:00     12        32000        7  alloc cn[98101-98102,98104-98105,98107-98109]
   super_q  up    5-00:00:00     12        32000        2   idle cn[98103,98106]
    test_q  up       1:00:00     12        32000        2   idle cn[98110-98111]
   inter_q  up    10-00:00:0     24        64000        2  alloc cn[99101-99102]
     mid_q  up    5-00:00:00     24        64000        8  alloc cn[99103,99105-99109,99111-99112]
     mid_q  up    5-00:00:00     24        64000        2   idle cn[99104,99110]
    long_q  up    10-00:00:0     24        64000        4  alloc cn[99113-99116]
   short_q  up       6:00:00     24        64000        3  alloc cn[99117-99118,99120]
   short_q  up       6:00:00     24        64000        1   idle cn99119
   wuzhou*  up    2-00:00:00     20       128000        7  alloc cn[97102-97103,97105-97106,97108-97110]
   wuzhou*  up    2-00:00:00     20       128000        2   idle cn[97104,97107]
   sonmi_1  up    5-00:00:00     40       256000        3  allocated  cn[96101-96103]
   sonmi_2  up    40-00:00:00    40       256000        2  allocated  cn[96104-96105]
   sonmi_2  up    40-00:00:00    40       256000        1  idle       cn96106
   sonmi_96* up   10-00:00:00    96       1000000       1  allocated  cn96100

```

- super_q: 每节点12个物理核，32G内存。在用节点9个。cn[98101-98109]
- test_q: 每节点12个物理核，32G内存。在用节点2个。cn[98110-98111]
- inter_q: 每节点24个物理核，64G内存。在用节点2个。cn[99101-99102]
- mid_q: 每节点24物理核，64G内存。在用节点10个。cn[99103-99112]
- long_q: 每个节点24物理核，64G内存。在用节点4个。cn[99113-99116]
- short_q: 每节点24物理核，64G内存。在用节点4个。cn[99117-99120]
- wuzhou:  每个节点20物理核，128G内存。在用节点9个。cn[97102-97110]
- sonmi_1: 每个节点40个物理核，256G内存。在用节点3个。cn[96101-103]
- sonmi_2: 每个节点40个物理核，256G内存。在用节点3个。cn[96101-103]
- sonmi_96: 96个物理核，1T内存。cn96100



每个分组有不同的任务时长限制，inter_q 主要是 `matlab` 脚本计算，可以申请1:24个核计算，避免申请一个节点却只有一个核计算的浪费；short_q时间较短，
主要是vasp的测试任务和一些计算量小的任务。


## vasp相关
- 加载vasp模块：
`module load vasp/5.4.4-impi-mkl`
- 查看赝势所在路径:
`echo $PPS_PATH`
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

注意, 这里为了任务执行出现故障时方便找到是哪个节点出现了问题, 我们建议在任务脚本文
件加入  `` echo 'This program is running at'  `hostname` ``, 这样就可以看到提交到哪个节点了.
如果你希望在使用 `pyvasp` 的时候, 自动生成的脚本里面也加入这句话, 只需
要在 `config.json` 文件里面的 `prepend` 里面加入这句话就可以了.

```json
{"potcar_path": {"paw_PBE": "/home/hecc/paw_PBE", "paw_LDA": "/opt/ohpc/pub/apps/vasp/pps/paw_LDA", "paw_PW91": "/opt/ohpc/pub/apps/vasp/pps/paw_PW91", "USPP_LDA": "/opt/ohpc/pub/apps/vasp/pps/USPP_LDA", "USPP_PW91": "/opt/ohpc/pub/apps/vasp/pps/USPP_PW91"}, "job": {"prepend": "module load vasp/5.4.4-impi-mkl;\necho 'This program is running at'  `hostname`", "exec": "mpirun -n ${SLURM_NPROCS} vasp_std","append":"exit"}}

```
**请根据任务的需求认真确定和选择`-p`和`-n`两个参数!!!**

**请根据任务的需求认真确定和选择准确评估任务上限时间!!!**

在完成以上的job.sh文件后，可以通过以下命令将该任务提交到计算节点：
```sh
$ sbatch job.sh
```

**若要提交任务到指定节点，或交互式运行任务，请参考管理员手册，或直接咨询管理员。**




## 集群上的其他模块
你可以使用`module avail`查看集群上已安装的软件信息
```bash
------------------------------------------ /usr/share/Modules/modulefiles ------------------------------------------
dot         module-git  module-info modules     null        use.own

--------------------------------------------- /share/apps/modulefiles ----------------------------------------------
atat/3.36                          julia/1.8.5                        spglib.1.0
bader                              lammps/20190807-intel              spglib.2.0
calypso                            lammps/20210612-intel              vasp/5.4.1-impi-mkl
gaussian/16                        latmat                             vasp/5.4.4-impi-mkl
intel-2023/intel-2023              matlab/R2015b                      vasp/6.1.2-impi-mkl
intel-2023/intel_compiler_2023.0.0 matlab/R2016b                      vasp/6.3.0-impi-mkl
intel-2023/intel_mkl_2023.0.0      matlab/R2019a                      vasp/6.3.0-new
intel-2023/intel_mpi_2021.8.0      matlab/R2019b                      vasp/6.4.0-impi-mkl
intel-compiler/2017_update7        multiwfn                           vasp2trace/v1
intel-compiler/2018_update4        QE/6.1.0-intel                     vesta
intel-compiler/2019_update5        QE/6.4.0-intel                     vtstscripts/935
intel-mkl/2017                     QE/6.5                             vtstscripts/964
intel-mkl/2018                     shengBTE

```
类似vasp的使用，也可以通过`module load xxx` 加载这些软件，关于软件具体的使用应查阅官网。



**若要提交任务到指定节点，或交互式运行任务，请参考管理员手册，或直接咨询管理员。**

### (OPTIONAL) 超算任务提交
超算同样使用`SLURM`作为任务管理系统。

## `module`软件模块挂载
所有的软件为了保证编译和使用环境互不冲突，使用`module`作为模块管理软件。

### 常用其他命令

```bash
查看任务队列
$ squeue

取消正在计算的任务
$ scancel 85035

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
