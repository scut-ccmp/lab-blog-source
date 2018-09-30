---
title: "test"
categories:
   - Q&A
date:  2018-09-30
tags:
  - cluster
  - vasp
  - pyyabc
---

<!--more-->

## Q1: VASP计算时出现强制退出, 内存爆炸的问题
## A1: 可以通过修改`~/.barshrc`文件
### 用户`~/.bashrc`配置
为使得VASP进行计算时能够处理打文件读写，用户将自己的文件句柄加大到`unlimited`，
增加`ulimit -s unlimited`，
修改后的`~/.bashrc`为：
```bash
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:                                                                            
# export SYSTEMD_PAGER=

# User specific aliases and functions
ulimit -s unlimited
```

我们建议不要修改`~/.barshrc`文件, 除了自己的脚本和独特的软件,
<span style="color:red">***切勿修改***`~/.bashrc`</span>
