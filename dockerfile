# 使用 Debian 12 官方镜像作为基础
FROM debian:12

# 设置环境变量
ENV DM_INSTALL_PATH=/opt/dmdbms \
    DM_DATA_PATH=/opt/dmdbms/data \
    LD_LIBRARY_PATH=/opt/dmdbms/bin

# 创建用户和设置限制（合并为单层）
RUN groupadd -g 10001 dinstall && \
    useradd -u 10001 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba && \
    echo "dmdba hard nofile 65536" >> /etc/security/limits.conf && \
    echo "dmdba soft nofile 65536" >> /etc/security/limits.conf && \
    echo "dmdba hard stack 32768" >> /etc/security/limits.conf && \
    echo "dmdba soft stack 16384" >> /etc/security/limits.conf


RUN mkdir -p /opt/dmdbms
RUN chown -R dmdba:dinstall /opt/dmdbms

# COPY ./DMInstall.bin /mnt/DMInstall.bin
COPY ./DMInstall.bin /tmp/
COPY ./dm_install.conf /mnt/dm_install.conf

# 安装达梦（使用dmdba用户）
RUN chown -R dmdba:dinstall /mnt
RUN /tmp/DMInstall.bin -q /mnt/dm_install.conf && \
    rm -rf /tmp
RUN rm -rf /mnt


RUN mkdir -p /opt/dmdbms/data
RUN chmod 777 -R /opt/dmdbms/data


RUN cd /opt/dmdbms/bin && \
    ./dminit \
    PATH=${DM_DATA_PATH} \
    CASE_SENSITIVE=N \
    UNICODE_FLAG=1 \
    SYSDBA_PWD=Qwert123!@# \
    SYSAUDITOR_PWD=Qwert123!@# \
    LOG_SIZE=256 \
    AUTO_OVERWRITE=2


# 安装服务（需适配容器环境）
RUN /opt/dmdbms/script/root/dm_service_installer.sh -t dmserver \
    -dm_ini ${DM_DATA_PATH}/DAMENG/dm.ini \
    -p DMSERVER


# 启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]