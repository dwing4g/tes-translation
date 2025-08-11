### 以 Tamriel Rebuilt 为例从 esm/esp 生成汉化初始状态

1. 从TR官网`https://www.nexusmods.com/morrowind/mods/42145`下载主文件,
   并从其压缩包中取出`TR_Mainland.esm`放到当前目录(即TamrielRebuilt子目录).

2. 在当前目录运行下面命令, 把`TR_Mainland.esm`转换为`TR_Mainland.txt`:

   `..\luajit ..\tes3dec.lua TR_Mainland.esm 1252 raw > TR_Mainland.txt`

   如果`esm/esp`文件比较大, 需要耐心等待, 完成之后不再需要`TR_Mainland.esm`, 可以删除.

3. 再运行下面命令, 从`TR_Mainland.txt`精简掉跟汉化无关的内容, 生成`TR_Mainland.trim.txt`:

   `..\luajit ..\tes3trim.lua TR_Mainland.txt > TR_Mainland.trim.txt`

4. 再运行下面命令, 把`TR_Mainland.trim.txt`改名并覆盖`TR_Mainland.txt`:

   `move /y TR_Mainland.trim.txt TR_Mainland.txt`

5. 再运行下面命令, 从`TR_Mainland.txt`提取关键词, 生成`topics.txt`(当前目录如有此文件先删掉再运行):

   `..\luajit ..\check_topic.lua topics.txt TR_Mainland.txt TR_Mainland.txt TR_Mainland.fix.txt`

6. 再运行下面命令, 从`TR_Mainland.txt`生成初始的对照文本文件`tes3cn_TR_Mainland.ext.txt`:

   `..\luajit ..\tes3ext.lua TR_Mainland.txt TR_Mainland.txt topics.txt tes3cn_TR_Mainland.ext.txt`

### 开始翻译

1. 如下方式翻译修改`topics.txt`的每一行:

   `[a new dealer] => [一位新贸易商]`

2. 如下方式翻译修改`tes3cn_TR_Mainland.ext.txt`的`###`部分, `###`表示上一行文字尚未翻译.
   翻译时需注意多行文本和转义方法, 见[上层说明](../README.md)的`字符串格式`和`转义符号`两段.
```
> SCPT.SCTX TR_Aimrah_6_SecretWall m2
Yes
是
```

### 从对照文本生成 esp 格式汉化补丁

1. 在当前目录运行下面命令, 用`TR_Mainland.txt`和`tes3cn_TR_Mainland.ext.txt`生成`tes3cn_TR_Mainland.txt`:

   `..\luajit ..\tes3mod.lua TR_Mainland.txt tes3cn_TR_Mainland.ext.txt topics.txt tes3cn_TR_Mainland.txt`

   可能会输出一些警告(WARN)和错误(ERROR)信息, 如有错误信息, 说明无法生成出正常的`tes3cn_TR_Mainland.txt`.
   可按警告和错误提示修正并重做此步.

2. 再运行下面命令, 从`tes3cn_TR_Mainland.txt`生成`tes3cn_TR_Mainland.esp`:

   `..\luajit ..\tes3enc.lua tes3cn_TR_Mainland.txt tes3cn_TR_Mainland.esp`

### NexusMods 相关地址

- Tamriel Data CN: https://www.nexusmods.com/morrowind/mods/54231
- Tamriel Rebuilt CN: https://www.nexusmods.com/morrowind/mods/54240
