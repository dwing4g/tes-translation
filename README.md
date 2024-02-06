# 《上古卷轴3-晨风》简体中文汉化工具链和文本

### 准备工作,转换esm/esp成txt格式:

把原版的3个`esm`和汉化导出的3个`esp`文件`tes3cn_*.esp`放到`openmw\scripts`目录下,

打开命令行, 进入`openmw\scripts`目录, 依次运行下面几行命令, 生成出对应的6个`txt`文件:
```
luajit tes3dec.lua Morrowind.esm        1252 > Morrowind.txt
luajit tes3dec.lua Tribunal.esm         1252 > Tribunal.txt
luajit tes3dec.lua Bloodmoon.esm        1252 > Bloodmoon.txt
luajit tes3dec.lua tes3cn_Morrowind.esp gbk  > tes3cn_Morrowind.txt
luajit tes3dec.lua tes3cn_Tribunal.esp  gbk  > tes3cn_Tribunal.txt
luajit tes3dec.lua tes3cn_Bloodmoon.esp gbk  > tes3cn_Bloodmoon.txt
```

### 检查并补充关键词

运行下面一行命令检查以上6个`txt`文件和`topics.txt`,检查通过会生成3个`tes3cn_*.fix.txt`:
```
luajit check_topic.lua topics.txt > errors.txt
```

有些错误信息会输出到命令行和`errors.txt`, 如果命令行显示出`ERROR:`开头的错误, 需要先修正.

各种错误信息的解释:
```
invalid topic [xxx] at line ... 原版txt里找不到xxx关键词(txt里有DIAL.NAME "xxx"且紧接着下面那行必须是DIAL.DATA [00]的)
invalid check topic [xxx] at line ... 汉化txt里找不到xxx关键词
duplicated topic [xxx] at line ... topics.txt里原文xxx出现了重复
duplicated checkTopic [xxx] at line ... topics.txt里译文xxx出现了重复
undefined topic [xxx] 原版txt里出现过关键词xxx,但topics.txt里没定义
undefined check topic [xxx], ref [yyy] 汉化txt里出现过关键词xxx,但topics.txt里没定义,可能对应的原版关键词是yyy
```

### 最后转换txt成esp格式

```
luajit tes3enc.lua tes3cn_Morrowind.fix.txt tes3cn_Morrowind.fix.esp
luajit tes3enc.lua tes3cn_Tribunal.fix.txt  tes3cn_Tribunal.fix.esp
luajit tes3enc.lua tes3cn_Bloodmoon.fix.txt tes3cn_Bloodmoon.fix.esp
```

其它说明:
1. `topics.txt`要求所有英文字母全部小写.
2. 如果有额外的`esm/esp`文件需要处理, 也需要转换成txt, 再修改`check_topic.lua`:
   在`src_filenames`补充原版的`txt`文件, `dst_filenames`补充汉化版导出的`txt`和修正后的`txt`文件名.
3. 如果mod增加关键词, 需要补充`topics.txt`.
4. `tes3dec.lua`和`tes3enc.lua`是万能的`esm/esp`处理工具, 转化为纯文本文件, 方便修改, 包括汉化.
   目前支持`上古卷轴3/4/5`,`辐射3/nv/4`, 但`上古卷轴5`和`辐射4`的文字不放到`esm/esp`里了.

### 转换脚本

- `*.esp              ` => `*.txt     ` : tes3cn_dec.bat
- `*.txt              ` => `*.txt     ` : tes3cn_trim.bat
- `原.txt + 译.txt    ` => `译.ext.txt` : tes3cn_ext.bat
- `原.txt + 译.ext.txt` => `译.txt    ` : tes3cn_mod.bat
- `译.txt + topics.txt` => `译.txt    ` : tes3cn_topic.bat
- `*.txt              ` => `*.esp     ` : tes3cn_enc.bat

### 字符串格式

- ***.txt中字符串**: 两端固定加半角双引号, 字符串中每个半角双引号都改为两个, 不可显示的字符编码用`$`转义(见下面的转义定义), `\r\n`换行不转义
- ***.ext.txt中的字符串**: 如果有`\r\n`换行, 则在字符串两端加三个半角双引号, 要求字符串中不能包含三个半角双引号, 不可显示的字符编码用`$`转义(见下面的转义定义), `\r\n`换行不转义

### 原版文字中的转义符号

- `$0A` : (LF换行符)
- `$0D` : (CR换行符)
- `$85` : … (三点省略号)
- `$92` : ’ (右单引号)
- `$93` : “ (左双引号)
- `$94` : ” (右双引号)
- `$AD` : (字母连字符,GBK不支持)
- `$E9` : é (e上加第二声调)
- `$EF` : ï (i上面有两个点,GBK不支持)
- `$FA` : ú (u上加第二声调)
- `$$`  : $

### 关于编码和换行符

所有`.txt`文件都是GBK编码, `\r\n`换行符, 原版`esm/esp`文件中的字符串使用`Windows-1252`编码.
