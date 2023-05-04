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

##### 修改用户可用内存
先进入root，
```
edquota -u cenyj

```
修改其中的hard项，具体每项的含义可以自行查询。


#### ipmi配置（主要用于远程开关机）：

##### BMC配置命令
```
ipmitool lan print 1 #打印当前ipmi 地址配置信息。
ipmitool lan set 1 ipsrc static  # 设置 id 1 为静态IP地址。
ipmitool lan set 1 ipaddr ip  # 设置 IPMI 地址。
ipmitool lan set 1 netmask 255.255.255.0 # 设置 IPMI 子网掩码。
ipmitool lan set 1 defgw ipaddr ip # 设置 IPMI 网关。

Ipmitool user list 1  # 显示 IPMI 用户列表。
ipmitool user set name 2 admin #创建用户，一般服务器有默认的超级用户（root,admin,ADMIN）,可以直接修改超级用户的密码，不用重新创建。
ipmitool user set password 3 lfpara2022..@ #创建密码
ipmitool channel setaccess 1 3 callin=on ipmi=on link=on privilege=4 #开权限 
ipmitool user list 1 # 查看chanenel1的用户信息
```


获取当前的电源状态：
```
ipmitool -I lan -H ip -U admin -P lfpara2022..@ power status
```
开机：
```
ipmitool -I lanplus -H ip -U admin -P lfpara2022..@ power on #如果服务器已经是在开机的情况下，再执行这个命令，服务器是不会重启的
```
重启：
```
ipmitool -I lanplus -H ip -U admin -P lfpara2022..@ power reset #注意：机器在关机的情况下，这个reset命令用不了的。
```
冷重启：
```
ipmitool  -I lanplus -H  ip -U admin -P lfpara2022..@ reset cold 
```
关机：
```
ipmitool -I lanplus -H ip -U admin -P lfpara2022..@ power off
```

具体的每台节点的[ip]()。




#### 一些重要的文件路径
软件的压缩包/项目文件放这里：
```
/share/apps/softwares/
```
软件对应的module模块的文件位置（需要配置该文件才能在module模块中使用）：
```
/share/apps/modulefiles/
```


slurm配置文件路径：
```
/etc/slurm/slurm.conf
/usr/lib/systemd/system/slurmd.service
```
服务器登陆日志路径：
```
/var/log/secure
```
该网页的github项目：
```
https://github.com/scut-ccmp/lab-blog-source
```

#### 其他可能用到的命令：
查看当前网络配置/网关地址：
```
netstat -r
```
查看UDP/TCP的开放端口：
```
netstat -nupl
netstat -ntpl
```

查看某个用户的所有进程：
```
ps -u cenyj
```
查看一级目录下的每个文件的硬盘占用：
```
du -h --max-depth=1
```













