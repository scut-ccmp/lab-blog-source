---
title: "hpc集群管理手册"
date: 2018-11-02T09:54:13+08:00
lastmod: 2018-11-02T10:54:13+08:00
draft: false
tags: ["cluster", "admin", "system"]
categories: ["manual"]
author: "qiusb"
---

### 用户管理

#### 加用户

进入root

```
useradd -m username 
passwd username
rocks sync users
```
rocks 是为了同步用户数据

```
userdel username #删除用户
more /etc/passwd #确认删除对了用户！！！
find / -name "*username*" #查找所有与用户相关信息
rm -rf dirname #删除数据
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



