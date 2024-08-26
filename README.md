## 不同环境下的 Postgres 数据库安装



### 1 Windows 下 Postgres 安装

Windows/Mac 下支持使用可执行文件快速安装，安装后像普通软件一样启动 Postgres 即可。

下载地址：https://www.enterprisedb.com/downloads/postgres-postgresql-downloads。

安装后可通过 pgAdmin 工具来连接 PostgreSQL 数据库。

默认安装的 PostgreSQL 会开机自启，可以通过以下步骤关闭开机自启：

1. 按下 `win+r` 打开运行对话框，输入 `services.msc` 并回车。
2. 找到 `postgres-x64-16`，右击选择 `属性`，将启动方式修改为 `手动`。
3. 可以右击选择 `停止`，关闭 `postgres` 服务。

Windows 下的启动与停止命令：

```bash
pg_ctl start -D "D:\Software\PostgreSQL\16\data"
pg_ctl stop -D "D:\Software\PostgreSQL\16\data"
```

`-D` 参数告诉 `pg_ctl` 命令应该使用哪个目录中的数据文件和配置文件。

### 2 Ubuntu 下 Postgres 安装

对于 Debian 的系统（如 Ubuntu），可以使用如下命令：

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
代码块12
```

检测 PostgreSQL 是否启动：

```bash
sudo systemctl status postgresql
代码块1
```

通过以下两个命令启动或者停止 PostgreSQL 服务：

```bash
sudo systemctl start postgresql
sudo systemctl stop postgresql
代码块12
```

安装完成后，可以通过 postgresql 提供命令工具 `psql` 连接到 PostgreSQL 数据库，亦或者使用 pgAdmin 可视化界面进行连接：

```bash
psql -U postgres -h localhost -W
代码块1
```

也可以通过切换到 postgres 用户直接运行 `psql` 命令：

```bash
sudo -i -u postgres
psql
代码块12
```

在 `psql` 中修改 `postgres` 密码：

```bash
\password postgres
代码块1
```

如果无法通过 `psql -U postgres` 进行登录，则大概率是 `postgresql` 仅开启了本地登录，可以通过编辑 `pg_hba.conf` 修改配置：

```bash
sudo vim /etc/postgresql/<版本号>/main/pg_hba.conf
代码块1
# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5

代码块1234567
```

PostgreSQL 中常见的身份验证方法如下：

1. **peer**：仅适用于本地连接。客户端必须作为相同的操作系统用户连接。例如，如果你以 `postgres` 用户登录操作系统，那么连接到数据库时也必须以 `postgres` 用户身份。
2. **md5**：使用MD5哈希进行密码验证。客户端必须提供正确的密码，密码在传输过程中会被加密。
3. **password**：以明文方式传输密码进行验证。不推荐使用，因为密码在网络上以明文形式传输，安全性较低。
4. **trust**：不需要密码，直接允许连接。不推荐在生产环境中使用，因为安全性较低。



### 3 Docker 快捷安装 PostgreSQL

Docker 中安装 PostgreSQL 非常简单，官方配置了镜像支持一件安装。

首先，从 Docker Hub 上拉去 PostgreSQL 的官方镜像：

```bash
docker pull postgres
代码块1
```

然后运行 PostgreSQL 容器：

```bash
docker run --name postgres-dev -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres 
代码块1
```

停止与开启 PostgreSQL 容器：

```bash
docker start postgres-dev
docker stop postgres-dev
代码块12
```

Docker 删除镜像与删除容器命令：

```bash
docker rmi <镜像id或名称>
docker rm <容器id或名称>
代码块12
```



### 本次准备华为高斯HCIE考试主要内容

#### 1.笔试
#### 2.机试
#### 3.SQL多写就行

#### 4. 总结和分享不易，打赏随意

<img src="dashang.jpg" alt="dashang" style="zoom: 25%;" />

















