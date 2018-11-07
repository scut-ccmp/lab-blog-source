---
title: "Issues_cluster11"
date: 2018-08-08T15:07:34+08:00
lastmod: 2018-08-08T15:54:13+08:00
draft: false
tags: ["linux", "command", "11", "cluster"]
categories: ["linux"]
author: "qiusb"
---

# SGE 

## 1. 任务提交

```
qsub jobname.sh
```

提交到指定节点

```
qsub -q nodename jobname.sh
```

## 2. 任务查询

查看用户任务

```
qstat
```

查看所有任务

```
qstat -u “*”
```

任务状态

qw    等待

Eqw   任务出差

r     运行中

dr    节点挂了，删除任务出现此状态（节点重启，或者强制删除任务）

## 3. 任务删除

```
qdel numbe_job

qdel -f numbe_job     #强制删除
```

## 4. 查看主机状态和负荷

```
qhost
```

## 5. 修改用户计算资源限制

```
su
qconf -mrqs
```

# 任务脚本参考

job.sh

```
#! /bin/sh              
#$ -S /bin/sh           
#$ -cwd                 
#$ -V                   
#$ -N jobname           
#$ -pe orte 20         
#$ -j y                 
     
mpirun -np ${NSLOTS} vasp5.4.4-std                
```
orte 后是核数，11里面是每个计算节点20核，所以使用20的整数倍

 more SGE:
 http://blog.chinaunix.net/uid-24404943-id-4119431.html
