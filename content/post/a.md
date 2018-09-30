---
title: cmp集群：用户手册
author: unkcpz
date: 2018-08-13
categories:
  - Manual
tags:
  - cluster
  - system
---

## 集群名称和描述
现有两组集群，分别是：
  1. 原先的五舟机器，采用SGE任务管理，安装Rocks6.1.1操作系统。
  2. 新建的集群，采用SLURM任务管理，安装CentOS 7.5操作系统，使用openhpc仓库的`WareWulf`集群管理软件。

<!--more-->

五舟的集群依照惯例称为<span style="color:red">'28'</span>，
实际的IP为`202.38.220.11:22`。
新建的集群称为<span style="color:red">'cmp集群'</span>，IP为`202.38.220.15:22`。

### 用户的分类
28保持原有全部设置，数据也不进行迁移，主要提供给即将毕业的同学使用，保证他们的正常使用，无需重新
适应新的集群。且该集群速度较快，支持IB网络，适用于大体系的计算和跨节点并行。

cmp集群提供给新生和有折腾意愿的同学和老师使用。将来会将所有新加入节点都接入该集群统一管理，
统一使用相同的任务管理和集群管理软件，方便用户的学习和管理员的交接。该节点单核性能较差，但核数
较多。缺点在于由于缺少IB网络的支持，跨节点并行的性能上不能达到倍数的增长。

### cmp集群分区信息
可以使用`sinfo`查询当前分组，当前有三个分组，分别对应三类机器。

- dellmid: DELL r620机器，每节点12个物理核，64G内存。在用节点12个。cn[98101-98112]
- jpmid: 景派提供的四子星机器，每节点24物理核，64G内存。在用节点4个。cn[99101-99104]
- small: DELL r610机器，每节点12物理核，32G内存。在用节点9个。cn[97101-97109]

`sinfo -Nel`可以查看更多的信息, 更多可参见[这里](http://geco.mines.edu/prototype/manpages/sinfo.html).


## 任务管理系统`SLURM`使用

可参考:

1. [Yale HPC](https://research.computing.yale.edu/support/hpc/user-guide/slurm)
2. [USC SLURM](https://hpcc.usc.edu/support/documentation/slurm/)

从`SGE`转移过来的用户可以参考:

1. [UPPMAX SGE vs SLURM](https://www.uppmax.uu.se/support/user-guides/sge-vs-slurm-comparison/)

### `SLURM`脚本提交模板
```bash
#!/bin/bash -l
# NOTE the -l flag!
#
#SBATCH -J NAME
# Default in slurm
# Request 5 hours run time
#SBATCH -t 5:0:0
#
#SBATCH -p small -N 1 -n 12
# NOTE Each small node has 12 cores
#

module load vasp/5.4.4-impi-mkl

# add your job logical here!!!
mpirun -n 12 vasp_std
```
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
