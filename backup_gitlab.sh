#!/bin/bash
#***********************************************
#Backup of GitLab running in a Docker container.
#***********************************************
CONTAINER_NAME="gitlab"
BACKUP_DIR="/opt/gitlab/backup/$(date +%Y-%m-%d)"

mkdir -p "$BACKUP_DIR"

# 1. Запуск бэкапа данных (Start backup)
docker exec -t "$CONTAINER_NAME" gitlab-backup create

# 2. Копирование свежего tar-архива (Copying a fresh tar archive)
docker cp "$CONTAINER_NAME":/var/opt/gitlab/backups/ "$BACKUP_DIR/data/"

# 3. Копирование секретов (Copying secrets)
docker cp "$CONTAINER_NAME":/etc/gitlab/gitlab.rb "$BACKUP_DIR/"
docker cp "$CONTAINER_NAME":/etc/gitlab/gitlab-secrets.json "$BACKUP_DIR/"

# (Опционально) Удаление старых бэкапов внутри контейнера, чтобы не забивать диск 
# ((Optional) Removing old backups inside the container to avoid filling up the disk.)
docker exec -t "$CONTAINER_NAME" find /var/opt/gitlab/backups/ -type f -mtime +0 -name '*.tar' -delete
