# ============================================================
# 第 1 阶段：安装达梦数据库
# ============================================================
FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# 安装必要依赖
RUN apt update && \
    apt install -y --no-install-recommends \
        libaio1 \
        locales \
        ca-certificates \
        net-tools \
        iputils-ping \
        procps \
        tar && \
    rm -rf /var/lib/apt/lists/*

# 创建用户与目录
RUN groupadd -g 10001 dinstall && \
    useradd -u 10001 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba && \
    echo "dmdba hard nofile 65536" >> /etc/security/limits.conf && \
    echo "dmdba soft nofile 65536" >> /etc/security/limits.conf && \
    echo "dmdba hard stack 32768" >> /etc/security/limits.conf && \
    echo "dmdba soft stack 16384" >> /etc/security/limits.conf

# 拷贝安装文件
COPY ./DMInstall.bin /tmp/
COPY ./dm_install.xml /mnt/dm_install.xml

# 安装达梦数据库
RUN mkdir -p /opt/dmdbms && \
    chown -R dmdba:dinstall /opt/dmdbms /mnt /tmp

USER dmdba
RUN /tmp/DMInstall.bin -q /mnt/dm_install.xml
USER root

# 清理安装文件
RUN rm -rf /mnt/* /tmp/*

# ============================================================
# 第 2 阶段：生成最终运行镜像
# ============================================================
FROM debian:12-slim

# 一次性设置所有环境变量
ENV DM_INSTALL_PATH=/opt/dmdbms \
    DM_DATA_PATH=/opt/dmdbms/data \
    LD_LIBRARY_PATH=/opt/dmdbms/bin \
    CASE_SENSITIVE=Y \
    CHARSET=0 \
    DB_NAME=DAMENG \
    INSTANCE_NAME=DMSERVER \
    PORT_NUM=5236 \
    SYSDBA_PWD=SYSDBA_abc123 \
    SYSAUDITOR_PWD=SYSDBA_abc123

# 创建运行用户
RUN groupadd -g 10001 dinstall && \
    useradd -u 10001 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba

# 拷贝安装完成的数据库
COPY --from=builder /opt/dmdbms /opt/dmdbms
COPY --from=builder /etc/security/limits.conf /etc/security/limits.conf

# 拷贝启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

USER dmdba
WORKDIR /home/dmdba

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
