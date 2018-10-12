+++
title = "Docker Nginx网页服务搭建（附服务器购买续费指南）"
Description = ""
Tags = ["nginx", "docker", "server"]
Categories = ["tutorial"]
date = 2018-10-12
+++

## Docker Nginx 网页服务搭建

### 服务器租赁和续费

登录[GigsGigs](https://clientarea.gigsgigscloud.com/)注册帐号并购买服务器。
这里购买的是CLOUDLET K1+ MEGA。购买时选择使用了CentOS7.5操作系统，hostname为
ccmp.scut.edu.cn

```text
Gigs上的帐号密码：
  帐号为：×××
  密码为：×××
```

购买后使用提供的ip地址和root密码登录到远端服务器,可以看到提示符如下：

```sh
[root@ccmp ~]#
```

创建用户`www-data`用于存放所有的网页文件。

```sh
[root@ccmp ~]# useradd -m www-data
[root@ccmp ~]# passwd www-data
```

如上就将服务器架设完毕，可以安装docker并搭建nginx服务响应网页服务。

### Docker的安装和加入用户组

参考[官网docker-ce手册](https://docs.docker.com/install/linux/docker-ce/centos/)

安装以来的软件包。

```sh
[root@ccmp ~]# yum install -y yum-utils device-mapper-persistent-data lvm2 vim
[root@ccmp ~]#
```

将docker仓库加入yum管理中：

```sh
[root@ccmp ~]# yum-config-manager --add-repo \
 https://download.docker.com/linux/centos/docker-ce.repo
```

安装`docker-ce`:

```sh
[root@ccmp ~]# yum install docker-ce
```

启动`docker`后台服务，并设置为自动启动.

```sh
[root@ccmp ~]# systemctl start docker
[root@ccmp ~]# systemctl enable docker
```

验证安装成功：

```sh
[root@ccmp ~]# docker run hello-world
```

该命令下载并测试一个小型的样本容器，若无错误输出，则可以看见一些提示输出，则证明安装正确，且
服务以成功开启了。

#### 将`www-data`用户加入`docker`用户组

`www-data`用户信息

```text
www-data用户：
  帐号：×××
  密码：×××
```

如果用户希望以非`root`用户运行docker，则需要将特定用户加入`docker`用户组。如下将`www-data`
用户加入`docker`用户组：

```sh
[root@ccmp ~]# usermod -aG docker www-data
[root@ccmp ~]# su www-data
[www-data@ccmp ~]$
[www-data@ccmp ~]$ groups
www-data docker
[www-data@ccmp ~]$ docker run hello-world
```

此时可以在该用户下执行docker。

到此，docker的安装就完毕了。下面将使用docker下载和使用nginx镜像容器。

### nginx服务的开启和使用

参考[docker官网nginx文档](https://docs.docker.com/samples/library/nginx/)

首先以`www-data`用户登录，并在`~/`目录下创建文件夹`server-html`和文件`index.html`：

```sh
[www-data@ccmp ~]$ mkdir -p /home/www-data/server-html
[www-data@ccmp ~]$ echo "<h1> Hello nginx docker </h1>" >> /home/www-data/server-html/index.html
[www-data@ccmp ~]$
```

再用docker下载`nginx`镜像并启动容器，使用`-v`参数关联数据文件夹，和`-p`参数指定暴露端口为`80`号，
关联容器的`80`端口和本地的`8080`端口。从而host主页地址<ip-address>:8080，可以通过这个地址访问网站：

```sh
[www-data@ccmp ~]$ docker run --name server-nginx --restart always \
 -v /home/www-data/server-html:/usr/share/nginx/html:ro -p 8080:80 -d nginx
```

这样就能通过[](http://host-ip:8080)来访问主页。

若有域名，可以将域名定位到该地址下。
