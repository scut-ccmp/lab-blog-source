+++
title = "cmp集群管理手册"
date = 2018-10-26
Description = ""
Tags = ["cluster", "admin", "system"]
Categories = ["manual"]
author = "unkcpz, qiusb"
+++

#### 新建用户
获取root

```
[root] # useradd -m username
[root] # passwd username
[root] # usermod -a -G labuser test123 （将test123用户加入labuser组）
[root] # sacctmgr add user test123 account=local （将新建test123用户加入slurm数据库）
```

#### 删除用户
获取root

```
[root] # userdel username
[root] # more /etc/passwd
[root] # find / -name "*username*"
[root] # rm -rf dirname
```
查看passwd是为了再次确认要删除该用户，接下来是找到与该用户有关的文件，并彻底删除。


#### slurm 用户任务限制
限制用户使用总CPU数
``` 
sacctmgr modify user test set GrpTRES=cpu=48 
```
限制test用户使用cpu总核数不超过48，将值改为-1则无限制

```
sacctmgr modify user test set GrpTRES=Node=cn96100
```
限制test用户只能使用cn96100节点，将值改为-1则无限制

限制用户最大可提交任务的数量
```
sacctmgr modify user test set maxsubmitjobs=10
```
限制test用户只能最多提交10个任务，超过则需要等待已提交任务完成后再提交，修改为-1解除限制

限制用户最大可运行任务的数量
```
sacctmgr modify user test set maxjobs=10
```
限制test用户最多只能有10个任务同时运行，修改为-1解除限制

查看用户的限制
```
sacctmgr show assoc
```

批量执行限制
```
cd /share/home
for i in `ls` ; do sacctmgr modify user $i set maxjobs=12 < ../t; done
for i in `ls` ; do sacctmgr modify user $i set GrpTRES=cpu=300 < ../t; done
```
其中../t的内容为y



#### slurm配置
slurm是集群的计算管理软件。在加入新机器后，需要在配置文件中加入新机器的信息。

在NODES部分增加节点信息（参考已有节点，若遇到硬件差别很大的机器，联系客服人员寻求帮助）。

`pdsh -w cn99105 systemctl start slurmd`开启节点的slurmd,(可以for来开启多个节点slurmd)，再用`systemctl restart slurmctld`重启管理节点的slurmctld客户端服务。

在集群环境中，slurm的主客关系为，计算节点为服务器端，管理节点作为客户端想计算节点请求当前任务
的状态信息。

使用`sinfo -Nel`查看节点信息，若节点为down，
则使用`scontrol update nodename=cn99105 state=resume`开启这个节点状态。

##### 节点状态显示drain
用sinfo查看信息的时候看到部分节点状态总是 drain
```
[root] # scontrol update NodeName=<node> State=DOWN Reason=hung_completing
[root] # scontrol update NodeName=<node> State=resume
```



### （Optional）用户组管理
实验室用户对所有节点都有使用权限，所以增加一个`labuser`用户组，对实验室用户都加入这个组。
还分别建立了`admin`组用于管理员和其节点分区，还有`testuser`用户短期实用用户，只开放small分区以供提交，两周后收回帐号密码。
