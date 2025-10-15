#!/bin/bash
# 检查是否首次启动
if [ ! -f /opt/dmdbms/data/$DB_NAME/dm.ini ]; then
    echo "Initializing DM database..."
    /opt/dmdbms/bin/dminit \
        PATH=/opt/dmdbms/data \
        CASE_SENSITIVE=$CASE_SENSITIVE \
        CHARSET=$CHARSET \
        DB_NAME=$DB_NAME \
        INSTANCE_NAME=$INSTANCE_NAME \
        PORT_NUM=$PORT_NUM \
        SYSDBA_PWD=$SYSDBA_PWD \
        SYSAUDITOR_PWD=$SYSAUDITOR_PWD
fi

# 启动达梦服务
exec /opt/dmdbms/bin/dmserver /opt/dmdbms/data/$DB_NAME/dm.ini