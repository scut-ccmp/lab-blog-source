---
title: "Cluster_useradd & userdel"
date: 2018-08-10T09:54:13+08:00
lastmod: 2018-09-09T10:54:13+08:00
draft: false
tags: ["linux", "command", "useradd", "userdel"]
categories: ["linux"]
author: "qiusb"
---
# 加用户

进入root

```
useradd -m username #-m在home目录下创建用户文件夹
passwd username
wwsh file resync passwd shadow group #与计算节点同步用户数据 
```
对于11的修改后数据同步：
```
rocks sync users
```


```
userdel username #删除用户
more /etc/passwd #确认删除对了用户！！！
find / -name "*username*" #查找所有与用户相关信息
rm -rf dirname #删除数据
```



