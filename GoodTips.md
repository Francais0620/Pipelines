### 1. 解压.gz文件到指定文件夹
* `.tar.gz`结尾的文件
```shell
tar -xzvf file.tar.gz -C /path/to/destination/
```
`-x` 解压文件。<br>
`-z` 使用 gzip 解压。<br>
`-v` 显示解压过程。<br>
`-f` 指定文件。<br>
`-C` 指定目标文件夹。<br>

* `.gz`结尾的文件
```shell
gunzip -c file.gz > /path/to/destination/file
```
`-c` 使 `gunzip` 解压后的内容输出到标准输出，不直接替换原文件。（这个非常好评）<br>

`>` 用于将输出重定向到指定的文件或文件夹。
