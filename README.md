# 基于debian12的达梦数据库docker镜像构建

> 达梦数据库build为docker镜像，版本：dm8_20251016_x86_rh7_64

## 构建流程

+ https://eco.dameng.com/download/ 下载开发版 (如果看不到下载，就先登录)
    + CPU架构选择 `X86`
    + 系统选择 `rhel_7`

+ 解压下载的zip压缩包，得到类似`dm8_20251016_x86_rh7_64.iso`名字的一个镜像文件

+ 挂载或者解压iso文件，将里面的 `DMInstall.bin` 复制到和 `Dockerfile` 同一目录中

+ 执行`build.sh`来构建镜像
    + `build.sh` 中 `yhl452493373/dm8:dm8_20251016_x86_rh7_64`表示镜像作者`yhl452493373`，镜像名称`dm8`，镜像版本`dm8_20251016_x86_rh7_64`
    + 可以简写成`dm8`或者`dm8:/dm8_20251016_x86_rh7_64`，不建议使用`dm8`，这样做无法区分镜像时对应的哪个版本的达梦数据库

+ 构建后即可启动

## docker-compose.yml

```yml
services:
  dm8:
    container_name: dm8
    image: yhl452493373/dm8:dm8_20251016_x86_rh7_64
    privileged: true
    volumes:
      - ./data:/opt/dmdbms/data
    environment:
      - CASE_SENSITIVE=N
      - CHARSET=1
      - SYSDBA_PWD=SYSDBA_abc123
      - SYSAUDITOR_PWD=SYSDBA_abc123
    ports:
      - "5236:5236"
    restart: unless-stopped

```

## 环境变量

| 名称             | 默认值           | 说明                                    |
|----------------|---------------|---------------------------------------|
| CASE_SENSITIVE | Y             | 大小敏感，可选值：Y/N，1/0                      |
| CHARSET        | 0             | 字符集，可选值：0[GB18030]，1[UTF-8]，2[EUC-KR] |
| DB_NAME        | DAMENG        | 数据库名                                  |
| INSTANCE_NAME  | DMSERVER      | 实例名                                   |
| PORT_NUM       | 5236          | 端口号                                   |
| SYSDBA_PWD     | SYSDBA_abc123 | SYSDBA密码，8到48位，必须同时包含大小写和数字           |
| SYSAUDITOR_PWD | SYSDBA_abc123 | SYSAUDITOR密码，8到48位，必须同时包含大小写和数字       |

## 达梦数据库V8所有参数

这些参数可以在[Dockerfile](Dockerfile)中作为环境变量，然后在[entrypoint.sh](entrypoint.sh)中`/opt/dmdbms/bin/dminit`部分使用，使用方式可参考 `环境变量` 部分的任意一个变量。

这个参数来源是 https://github.com/liuhongtian/DM8-Docker/blob/main/README.md ,其实际为 [dm_install.xml](dm_install.xml) 的安装参数。

[dm_install.xml](dm_install.xml) 请参考 https://eco.dameng.com/community/post/20240122175502VMHTLSQ5TEWIJTJZFW 的 `auto_install.xml` 部分。

| 关键字               | 说明（默认值）                                                                     |
| -------------------- | ---------------------------------------------------------------------------------- |
| INI_FILE             | 初始化文件dm.ini存放的路径                                                         |
| PATH                 | 初始数据库存放的路径                                                               |
| CTL_PATH             | 控制文件路径                                                                       |
| LOG_PATH             | 日志文件路径                                                                       |
| EXTENT_SIZE          | 数据文件使用的簇大小(16)，可选值：16, 32, 64，单位：页                             |
| PAGE_SIZE            | 数据页大小(8)，可选值：4, 8, 16, 32，单位：K                                       |
| LOG_SIZE             | 日志文件大小(4096)，单位为：M，范围为：256M ~ 8G                                   |
| CASE_SENSITIVE       | 大小敏感(Y)，可选值：Y/N，1/0                                                      |
| CHARSET/UNICODE_FLAG | 字符集(0)，可选值：0[GB18030]，1[UTF-8]，2[EUC-KR]                                 |
| SEC_PRIV_MODE        | 权限管理模式(0)，可选值：0[TRADITION]，1[BMJ]，2[EVAL]，3[BAIST]，4[ZBMM]          |
| SYSDBA_PWD           | 设置SYSDBA密码                                                                     |
| SYSAUDITOR_PWD       | 设置SYSAUDITOR密码                                                                 |
| DB_NAME              | 数据库名(DAMENG)                                                                   |
| INSTANCE_NAME        | 实例名(DMSERVER)                                                                   |
| PORT_NUM             | 监听端口号(5236)                                                                   |
| BUFFER               | 系统缓存大小(8000)，单位M                                                          |
| TIME_ZONE            | 设置时区(+08:00)                                                                   |
| PAGE_CHECK           | 页检查模式(3)，可选值：0/1/2/3                                                     |
| PAGE_HASH_NAME       | 设置页检查HASH算法                                                                 |
| EXTERNAL_CIPHER_NAME | 设置默认加密算法                                                                   |
| EXTERNAL_HASH_NAME   | 设置默认HASH算法                                                                   |
| EXTERNAL_CRYPTO_NAME | 设置根密钥加密引擎                                                                 |
| RLOG_ENCRYPT_NAME    | 设置日志文件加密算法，若未设置，则不加密                                           |
| RLOG_POSTFIX_NAME    | 设置日志文件后缀名，长度不超过10。默认为log，例如DAMENG01.log                      |
| USBKEY_PIN           | 设置USBKEY PIN                                                                     |
| PAGE_ENC_SLICE_SIZE  | 设置页加密分片大小，可选值：0、512、4096，单位：Byte                               |
| ENCRYPT_NAME         | 设置全库加密算法                                                                   |
| BLANK_PAD_MODE       | 设置空格填充模式(0)，可选值：0/1                                                   |
| SYSTEM_MIRROR_PATH   | SYSTEM数据文件镜像路径                                                             |
| MAIN_MIRROR_PATH     | MAIN数据文件镜像                                                                   |
| ROLL_MIRROR_PATH     | 回滚文件镜像路径                                                                   |
| MAL_FLAG             | 初始化时设置dm.ini中的MAL_INI(0)                                                   |
| ARCH_FLAG            | 初始化时设置dm.ini中的ARCH_INI(0)                                                  |
| MPP_FLAG             | Mpp系统内的库初始化时设置dm.ini中的mpp_ini(0)                                      |
| CONTROL              | 初始化配置文件（配置文件格式见系统管理员手册）                                     |
| AUTO_OVERWRITE       | 是否覆盖所有同名文件(0) 0:不覆盖 1:部分覆盖 2:完全覆盖                             |
| USE_NEW_HASH         | 是否使用改进的字符类型HASH算法(1)                                                  |
| ELOG_PATH            | 指定初始化过程中生成的日志文件所在路径                                             |
| AP_PORT_NUM          | 分布式环境下协同工作的监听端口                                                     |
| HUGE_WITH_DELTA      | 是否仅支持创建事务型HUGE表(1) 1:是 0:否                                            |
| RLOG_GEN_FOR_HUGE    | 是否生成HUGE表REDO日志(1) 1:是 0:否                                                |
| PSEG_MGR_FLAG        | 是否仅使用管理段记录事务信息(0) 1:是 0:否                                          |
| CHAR_FIX_STORAGE     | CHAR是否按定长存储(N)，可选值：Y/N，1/0                                            |
| SQL_LOG_FORBID       | 是否禁止打开SQL日志(N)，可选值：Y/N，1/0                                           |
| DPC_MODE             | 指定DPC集群中的实例角色(0) 0:无 1:MP 2:BP 3:SP，取值1/2/3时也可以用MP/BP/SP代替    |
| USE_DB_NAME          | 路径是否拼接DB_NAME(1) 1:是 0:否                                                   |
| MAIN_DBF_PATH        | MAIN数据文件存放路径                                                               |
| SYSTEM_DBF_PATH      | SYSTEM数据文件存放路径                                                             |
| ROLL_DBF_PATH        | ROLL数据文件存放路径                                                               |
| TEMP_DBF_PATH        | TEMP数据文件存放路径                                                               |
| ENC_TYPE             | 数据库内部加解密使用的加密接口类型(1), 可选值: 1: 优先使用EVP类型 0: 不启用EVP类型 |
| RANDOM_CRYPTO        | 随机数算法所在加密引擎名                                                           |
| DPC_TENANCY          | 指定DPC集群是否启用多租户模式(0) 0:不启用 1:启用，取值0/1时也可以用FALSE/TRUE代替  |
| HELP                 | 打印帮助信息                                                                       |

