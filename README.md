# dm8-dockerfile

> 达梦数据库build为docker镜像

## 构建流程

1. 下载达梦官方的linux软件包

2. 解压并提取软件包中的DMInstall.bin（在iso文件内部）

3. 将DMInstall.bin文件放置在与dockerfile文件同目录下

4. 执行命令

   ```bash
   docker build -t 镜像名称:版本号 .
   ```

5. 启动镜像，正常访问
 
