+++
title = "cmp集群管理手册"
date = 2018-10-26
Description = ""
Tags = ["cluster", "admin", "system"]
Categories = ["manual"]
author = "unkcpz, qiusb"
+++

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
