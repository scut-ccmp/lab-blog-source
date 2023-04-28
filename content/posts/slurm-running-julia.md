---
title: "使用slurm在集群上使用julia"
Description: 在集群上使用slurm任务管理系统，分别交互式的和提交任务式的使用matlab
categories:
   - Manual
date:  2019-04-01
tags:
  - cluster
  - julia
author: Huang weijie
---

## 以任务的方式提交julia任务(recommoned)


slurm脚本模板为`job.sh`：
```sh
#!/bin/bash 
#SBATCH -J long-time
#SBATCH -p sonmi_2 -N 1 -n 40 

module load julia/1.8.5
echo 'This program is running at'  `hostname`
julia -t 40 ./Operator-j-BLP-v2-applycutoff=1E-6-2023-3-15-V=3-longTime.jl
~      

```


参数`julia -t`后面的数字可以julia使用的线程数目（并不是越多越快，具体原因可以参考ITensor文档里面的multithreading一节），数字后紧跟所要运行的`.jl`文件的文件名<span style="color:red">！！！注意和matlab不一样，julia要写后缀，否则会出错！！！</span>。

将脚本与要执行的`.jl`文件放在相同文件夹下，运行`sbatch ./job.sh`即可。


## 在管理节点使用交互式的模式进行julia运算(only recommend for test)



### Step 1
首先使用`module load julia/1.8.5`
此时，会进入加载julia可执行模块的到路径。


### Step 2
`julia -t -6`
打开repl 模式的julia，可以在这里查看库函数的版本，也可以运行简单的测试程序。


## julia 程序输出的slurm不会及时更新问题
建议在运行时间比较长的脚本里面使用`println`来输出一些量来反馈程序运行进度。
因为在大型运算的脚本中，println的结果会被buffering，也就是被缓存，然后程序结束的时候一次性放出来，所以需要使用flush(stdout)，强制julia和repl交流，实时打印出缓存中的内容，然后清空缓存。
