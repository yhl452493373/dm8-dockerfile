#!/bin/bash
# 检查是否首次启动
if [ ! -f "/opt/dmdbms/data/DAMENG/dm.ini" ]; then
    echo "Initializing DM database..."
    /opt/dmdbms/bin/dminit \
        PATH=/opt/dmdbms/data \
        CASE_SENSITIVE=N \
        SYSDBA_PWD=${SYSDBA_PWD:-Qwert123!@#} \
        SYSAUDITOR_PWD=${SYSDBA_PWD:-Qwert123!@#}
fi

# 启动达梦服务
exec /opt/dmdbms/bin/dmserver /opt/dmdbms/data/DAMENG/dm.ini