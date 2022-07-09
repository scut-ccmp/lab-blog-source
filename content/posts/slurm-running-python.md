---
title: "使用slurm在集群上使用python"
Description: 利用conda创建python虚拟环境，并且使用虚拟环境在计算节点上提交任务
categories:
   - Manual
date:  2022-07-09
tags:
  - cluster
author: cenyj
---

## 1. Conda 环境初始化(使用普通用户lfpara作为演示)

输入conda init，会自动将conda的初始环境写入~/.bashrc文件，随后source ~/.bashrc进入conda环境（首次登录输入，后续无需输入）。（base表示处于conda环境）

![这是图片](../../static/images/python/1)


如需退出conda环境输入conda deactivate

![这是图片](../../static/images/python/2)


## 2、Conda 创建python环境（需处于conda环境）

conda create -n test python=3.7（创建名为test的环境，python版本为3.7）

![这是图片](../../static/images/python/3)

所创建的环境位于个人家目录的.conda/envs目录下

![这是图片](../../static/images/python/4)

激活test环境：conda activate test（环境从base变成test）

![这是图片](../../static/images/python/5)

test所独有的bin和lib位于/share/home/lfpara/.conda/envs/test里面（lfpara用户）

![这是图片](../../static/images/python/6)

处于conda环境时可以使用pip安装自身所需要的库

![这是图片](../../static/images/python/7)

退出test环境：conda deactivate

![这是图片](../../static/images/python/8)


## 3、使用conda环境提交队列脚本


slurm脚本模板为`python_job.sh`：
```sh
#!/bin/bash
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -o output
#SBATCH --nodelist=cn96102
#SBATCH -p sonmi

cd $SLURM_SUBMIT_DIR
export PATH=/share/apps/all/miniconda3/bin:$PATH  > /dev/null
source activate test（修改成需要的环境名）
python t.py

```

<span style="color:red">ps: 提交任务时退出conda环境再运行脚本（conda decativate + sbatch script）</span>

![这是图片](../../static/images/python/9)

![这是图片](../../static/images/python/10)


