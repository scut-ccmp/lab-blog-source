+++
title = "cmp集群管理手册"
date = 2018-10-26
Description = ""
Tags = ["cluster", "admin", "system"]
Categories = ["manual"]
author = "unkcpz, qiusb"
+++

### openhpc节点开机
首先开启管理节点，使用管理节点的BMC口进入主板系统，也就是DELL的iDRAC，ip地址为
(https://202.38.220.14).
进入后在面板中选择开机。

等待机器启动后（约3分钟）。以管理员用户进入管理节点系统，加载计算节点相关的机器参数：
```sh
[root] # source /home/mgt/openhpc.sh
```
其中的`nodeinfo.sh`保存的是每一个计算节点的bmc和通信ip信息。

循环关闭每个节点：
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
