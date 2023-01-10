# IYUUPlus-Docker

```bash
docker run -d \
  -v /你想在本地保存IYUU配置的路径/:/IYUU/db                    `# 冒号左边请修改为你想在本地保存IYUU配置文件的路径` \
  -v /qBittorrent的BT_backup文件夹在宿主机上的路径/:/BT_backup  `# 冒号左边请修改为你自己的路径，如不使用qb，可删除本行` \
  -v /transmission的torrents文件夹在宿主机上的路径/:/torrents   `# 冒号左边请修改为你自己的路径，如不使用tr，可删除本行` \
  -p 8787:8787 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e UMASK=022 \
  -e IYUU_GIT=gitee `#可选github或gitee` \
  --name IYUUPlus \
  --restart=always \
  ddsderek/iyuuplus
# 如果你需要自定义更新时间可以添加 -e "CRON_UPDATE=0 0 * * *"
```

```yaml
version: '3.3'
services:
    iyuuplus:
        volumes:
            - '/你想在本地保存IYUU配置的路径/:/IYUU/db'
            - '/qBittorrent的BT_backup文件夹在宿主机上的路径/:/BT_backup'
            - '/transmission的torrents文件夹在宿主机上的路径/:/torrents'
        ports:
            - '8787:8787'
        environment:
            - "PUID=1000"
            - "PGID=1000"
            - "UMASK=022"
            - "IYUU_GIT=gitee" # 可选github或gitee
            # - "CRON_UPDATE=0 0 * * *" #如果你需要自定义更新时间可以添加 
        container_name: IYUUPlus
        restart: always
        image: ddsderek/iyuuplus
```