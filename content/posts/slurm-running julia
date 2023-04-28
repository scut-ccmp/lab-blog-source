---
title: "使用slurm在集群上使用matlab"
Description: 在集群上使用slurm任务管理系统，分别交互式的和提交任务式的使用matlab
categories:
   - Manual
date:  2019-04-01
tags:
  - cluster
  - matlab
author: unkcpz
---

## 以任务的方式提交matlab任务(recommoned)

- <span style="color:red">切记在要运行的 `.m` 文件的结尾加入 `quit`， 否则在任务结束后无法释放节点。</span>

<!--more-->

- <span style="color:red">切记提交的任务在要使用***并行***（parfor），否则会出现不满核占据单节点的情况，造成资源的浪费。并行详情咨询长春。</span>

slurm脚本模板为`matlab_job.sh`：
```sh
#!/bin/bash -l
# NOTE the -l flag!
#SBATCH -o test.std_%j.out
#SBATCH -J test
#SBATCH -e test.error.out
# Default in slurm
# Request 5 hours run time
#SBATCH -t 5:0:0
# Requiest 1 node and 4 cores in partition normal
#SBATCH -p inter_q -N 1 -n 4
# NOTE Each node has 12 cores

module load matlab/R2016b

matlab -nodisplay -nosplash -nojvm -r script

```
其中前三个参数`-nodisplay`, `-nosplash`, `-nojvm`保证了在命令行中而不是用图形界面执行matlab。
程序中使用并行时，`-singleCompThread`参数为程序中有并行代码时使用，确保了每个核不会多线程运行。由于matlab的
多维度编程的性能提升很大，在大的矩阵操作时可将此参数关闭（如上脚本所示），来实现多线程。

参数`-r`后面紧跟所要运行的`.m`文件的文件名<span style="color:red">！！！注意不要写后缀，否则会出错！！！</span>。

将脚本与要执行的`.m`文件放在相同文件夹下，运行`sbatch ./matlab_job.sh`即可。

注意这里`#SBATCH -o` 和`#SBATCH -e` 后面跟的是标准输出和错误输出, `%j`代表的是你提交任务的id号, 以防止找不到提交任务的文件夹. 

## 交互式的申请节点并进行matlab运算(not recommoned)

<span style="color:red">两次\<ctrl+D\>: 切记在运行完交互式任务后手动退出计算节点，退出计算节点后还要退出子命令行，否则节点持续被占用。</span>

### Step 1
首先使用`salloc -p jpmid -N 1 -n 4`申请jpmid分区下1个节点4个核。
此时，会打开一个新的shell窗口。

用`squeue`查看申请到的是哪个节点，记住节点名称比如`cn97103`，使用`ssh cn97103`进入该计算节点。

### Step 2
`module load matlab/R2016b`
加载mablab可执行模块的到路径。

### Step 3
运行`matlab -nodisplay -nosplash -nojvm`打开命令行模式的matlab。
