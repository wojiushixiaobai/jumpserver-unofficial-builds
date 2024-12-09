<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">多云环境下更好用的堡垒机</h3>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
  <a href="https://github.com/jumpserver/Dockerfile/commits"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile.svg" /></a>
  <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="Stars"></a>
</p>

--------------------------

## 环境要求
- PostgreSQL Server >= 15.0
- Redis Server >= 6.0

## 快速部署
```sh
# 测试环境可以使用，生产环境推荐外置数据
git clone --depth=1 https://github.com/wojiushixiaobai/jumpserver-unofficial-builds.git
cd unofficial-builds
cp config_example.conf .env
docker compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-postgres.yml -f docker-compose.yml up -d
```

## 标准部署

> 请先自行创建 数据库 和 Redis, 版本要求参考上面环境要求说明

```sh
git clone --depth=1 https://github.com/wojiushixiaobai/jumpserver-unofficial-builds.git
cd unofficial-builds
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
VERSION=v4.4.1-ce

# 构建参数, 支持 amd64, arm64, ppc64le, s390x
TARGETARCH=amd64

# Compose, Swarm 模式下修改 NETWORK_DRIVER=overlay
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24
NETWORK_DRIVER=overlay

# 持久化存储
VOLUME_DIR=/data/jumpserver

# 时区
TZ=Asia/Shanghai

# PostgreSQL
DB_ENGINE=postgresql
DB_HOST=postgresql
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=nu4x599Wq7u0Bn8EABh3J91G
DB_NAME=jumpserver

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=8URXPL2x3HZMi7xoGTdk3Upj

# Core
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO
LOG_LEVEL=ERROR
DOMAINS=

# 组件通信
CORE_HOST=http://core:8080

# Lion
GUACD_LOG_LEVEL=error
GUA_HOST=guacd
GUA_PORT=4822

# Web
HTTP_PORT=80
SSH_PORT=2222

##
# SECRET_KEY 保护签名数据的密匙, 首次安装请一定要修改并牢记, 后续升级和迁移不可更改, 否则将导致加密的数据不可解密。
# BOOTSTRAP_TOKEN 为组件认证使用的密钥, 仅组件注册时使用。组件指 koko, lion, magnus, kael, chen ...
```
```sh
docker compose -f docker-compose-network.yml -f docker-compose.yml up -d
```

## 集群部署

- Docker Swarm 集群环境
- 自行创建 MySQL 和 Redis, 参考上面环境要求说明
- 自行创建持久化共享存储目录 ( 例如 NFS, GlusterFS, Ceph 等 )

```sh
# 在所有 Docker Swarm Worker 节点挂载 NFS 或者其他共享存储, 例如 /data/jumpserver
# 注意: 需要手动创建所有需要挂载的持久化目录, Docker Swarm 模式不会自动创建所需的目录
mkdir -p /data/jumpserver/core/data
mkdir -p /data/jumpserver/chen/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/koko/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/web/data/logs
mkdir -p /data/jumpserver/web/download
```
```sh
git clone --depth=1 https://github.com/wojiushixiaobai/jumpserver-unofficial-builds.git
cd unofficial-builds
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
VERSION=v4.4.1-ce

# 构建参数, 支持 amd64, arm64, ppc64le, s390x
TARGETARCH=amd64

# Compose, Swarm 模式下修改 NETWORK_DRIVER=overlay
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24
NETWORK_DRIVER=overlay

# 持久化存储
VOLUME_DIR=/data/jumpserver

# 时区
TZ=Asia/Shanghai

# PostgreSQL
DB_ENGINE=postgresql
DB_HOST=postgresql
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=nu4x599Wq7u0Bn8EABh3J91G
DB_NAME=jumpserver

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=8URXPL2x3HZMi7xoGTdk3Upj

# Core
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO
LOG_LEVEL=ERROR
DOMAINS=

# 组件通信
CORE_HOST=http://core:8080

# Lion
GUACD_LOG_LEVEL=error
GUA_HOST=guacd
GUA_PORT=4822

# Web
HTTP_PORT=80
SSH_PORT=2222

##
# SECRET_KEY 保护签名数据的密匙, 首次安装请一定要修改并牢记, 后续升级和迁移不可更改, 否则将导致加密的数据不可解密。
# BOOTSTRAP_TOKEN 为组件认证使用的密钥, 仅组件注册时使用。组件指 koko, lion, magnus, kael, chen ...
```
```sh
# 生成 docker stack 部署所需文件
docker compose -f docker-compose-network.yml -f docker-compose.yml config | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```
```sh
# 启动 JumpServer 应用
docker stack deploy -c docker-stack.yml jumpserver
docker service ls
```
```sh
# 扩容缩容
docker service update --replicas=2 jumpserver_koko  # 扩容 koko 到 2 个副本
docker service update --replicas=4 jumpserver_lion  # 扩容 lion 到 2 个副本
# ...
```

## 初始账号

- 账号: `admin`
- 密码: `ChangeMe`