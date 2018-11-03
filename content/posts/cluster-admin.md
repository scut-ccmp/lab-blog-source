+++
title = "cmp集群管理手册"
date = 2018-10-26
Description = ""
Tags = ["cluster", "admin", "system"]
Categories = ["manual"]
author = "unkcpz, qiusb"
+++

### openhpc节点用户管理
#### 加用户
获取root

```
[root] # useradd -m username
[root] # passwd username
[root] # wwsh file resync passwd shadow group
```
-m 参数是为了在home目录下创建用户文件夹；wwsh 与计算节点同步用户数据。

#### 删除用户
获取root

```
[root] # userdel username 
[root] # more /etc/passwd 
[root] # find / -name "*username*" 
[root] # rm -rf dirname 
```
查看passwd是为了再次确认要删除该用户，接下来是找到与该用户有关的文件，并彻底删除。


### openhpc节点开机
首先开启管理节点，使用管理节点的BMC口进入主板系统，也就是DELL的iDRAC，ip地址为
(https://202.38.220.14).
进入后在面板中选择开机。

等待机器启动后（约3分钟）。以管理员用户进入管理节点系统，加载计算节点相关的机器参数：
```sh
[root] # source /home/mgt/openhpc.sh
```
其中的`nodeinfo.sh`保存的是每一个计算节点的bmc和通信ip信息。

循环开启每个节点：
```sh
[root] # for ((i=0; i<${num_computes}; i++)) ; do
            do ipmitool -E -I lanplus -H ${c_bmc[$i]} -U ${bmc_username} chassis power reset
          done
```

确定计算节点全部开启。
```sh
[root] # for ((i=0; i<${num_computes}; i++)); do
            pdsh -w ${c_name[$i]} uptime
         done
```

确定所有可用节点均开机后，开启计算节点的`slurmd`服务：
```sh
[root] # for ((i=0; i<${num_computes}; i++)) ; do
            pdsh -w ${c_name[$i]} systemctl start slurmd
          done
```

再开启管理节点`slurmctld`服务：
```sh
[root] # systemctl restart slurmctld
```

（optional？）按节点开启节点检查(health check)
```sh
[root] # pdsh -w c1 "/usr/sbin/nhc-genconf -H '*' -c -" | dshbak -c
```

### openhpc集群节点关机
以root进入管理节点，加载计算节点相关的机器参数：
```sh
[root] # source /home/mgt/openhpc.sh
```
其中的`nodeinfo.sh`保存的是每一个计算节点的bmc和通信ip信息。

循环关闭每个节点：
```sh
[root] # for ((i=0; i<${num_computes}; i++)) ; do
            do ipmitool -E -I lanplus -H ${c_bmc[$i]} -U ${bmc_username} chassis power off
          done
```

关闭等待计算节点全部关闭后，`shutdown -h now`关闭管理节点。

### Warewulf+CentOS+slurm增加节点
以新到的jp机器为例，增加四个节点。


#### 硬件配置
首先要对硬件进行BMC口的ip配置，开机进入BIOS，配置BMC口ip如下所示。
配置好后，确保机器可以ping到该ip下，则表示BMC设置成功。

设置机器的启动方式为pxe启动。

设置默认关闭机器的超线程机制，可以牺牲一些效率，使得机器的损耗减少。


#### 环境加载
四个节点名称分别为`cn99105~cn99108`，名称和ip以及BMC的管理端口ip分别填入`/home/mgt/nodeinfo`中，以便快速加载。
```text
# jp machine
c_name[35]=cn99105; c_ip[35]=10.1.99.105; c_bmc[35]=50.1.99.105
c_name[36]=cn99106; c_ip[36]=10.1.99.106; c_bmc[36]=50.1.99.106
c_name[37]=cn99107; c_ip[37]=10.1.99.107; c_bmc[37]=50.1.99.107
c_name[38]=cn99108; c_ip[38]=10.1.99.108; c_bmc[38]=50.1.99.108
```

加载集群配置环境
```sh
[root] # source openhpc.sh
```

#### 查找和增加节点
使用warewulf的`wwnodescan`查找节点。

首先开启节点查找请求：

```sh
[root] # wwnodescan --netdev=${eth_provision} --ipaddr=${c_ip[35]} --netmask=${internal_netmask} \
--vnfs=centos7.5 --bootstrap=`uname -r` --listen=${sms_eth_internal} ${c_name[35]}
```

请求等待过程中，使用BMC管理开启对应机器：
```sh
[root] # ipmitool -E -I lanplus -H ${c_bmc[35]} -U ${bmc_username} chassis power on
```

pxe开机过程中会在网络中查找启动引导，找到后`wwnodescan`的窗口会显示找到该节点。

按照这样的方式手动增加每一个节点。

增加这些节点后，使用：
```sh
[root] # wwsh node --groupadd cn99105 jp
```
来将节点加入warewulf指定组做统一管理。

#### after_nodefind
成功加入节点后，使用`/home/mgt/after_nodefind.sh`运行后续配置，其中包括了一些内核配置。

#### slurm配置
slurm是集群的计算管理软件。在加入新机器后，需要在配置文件中加入新机器的信息。

在NODES部分增加节点信息（参考已有节点，若遇到硬件差别很大的机器，联系客服人员寻求帮助）。

`pdsh -w cn99105 systemctl start slurmd`开启节点的slurmd,(可以for来开启多个节点slurmd)，再用`systemctl restart slurmctld`重启管理节点的slurmctld客户端服务。

在集群环境中，slurm的主客关系为，计算节点为服务器端，管理节点作为客户端想计算节点请求当前任务
的状态信息。

使用`sinfo -Nel`查看节点信息，若节点为down，
则使用`scontrol update nodename=cn99105 state=resume`开启这个节点状态。
