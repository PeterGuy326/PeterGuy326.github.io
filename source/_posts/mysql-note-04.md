---
title: 一周浅谈：InnoDB数据页结构
date: 2022-06-20T22:51:18+08:00
tags:
  - Mysql
  - InnoDB
categories:
  - 数据库
---

## 不同类型的页
页是 InnoDB 管理存储空间的基本单位，一个页的大小一般是 16KB。InnoDB 为了不同的目的而设计了多种不同类型的页，比如：

- 存放表空间头部信息的页
- 存放 Change Buffer 信息的页
- 存放 INODE 信息的页
- 存放 undo 日志信息的页

这次我们关心的是那些存放表中记录的那种类型的页，官方称这种存放记录的页为索引（INDEX）页。鉴于我们还没有介绍过索引是什么，而这些表中的记录就是我平时所说的数据，所以我暂时把将这种存放记录的页称为数据页

---
## 数据页结构
数据页代表这块 16KB 大小的存储空间可以划分为多个部分，不同部分有不同含义，如下啊图所示：![InnoDB数据页结构示意图.drawio.png](https://res.cloudinary.com/https-fallingkids-github-io/image/upload/v1655654488/blog/mysql/mysql-note-04/5-1_qmjrcb.png)>图 5-1 InnoDB 数据页结构示意图表 5-1 InnoDB 数据页结构

名称中文名占用空间简答描述File Header文件头部38 字节页的一些通用信息Page Header页面头部56 字节数据页专有的一些信息Infimum + Supremum页面中的最小记录和最大记录26 字节两个虚拟的记录User Records用户记录不确定用户存储的记录内容Free Space空闲空间不确定页中尚未使用的空间Page Directory页目录不确定页中某些记录的相对位置File Trailer文件尾部8 字节校验页是否完整
---
## 记录在页中的存储
我们自己存储的记录会按照指定的行格式存储到 User Records 部分。但是在一开始生成页的时候，没有 User Records 部分，每当插入一条记录时，都会从 Free Space 部分（也就是尚未使用的空间）申请一个记录大小的空间，并将这个空间划分到 User Records 部分。当 Free Space 部分的空间全部用完了，这也就意味着这个页使用完了，如果还有新的记录插入，就要去申请新的页了那么接下来我们看下如何更好的管理 User Records 中的这些记录，这时候，我们就从记录行格式的记录头信息说起。

### 记录头信息
以下举一个例，我们先创建一个表：

```shell
mysql> CREATE TABLE page_demo(
```
值得注意的是，我们把 c1 列指定为主键，所以 InnoDB 就没有必要创建 row_id 隐藏列了。而且我们为这个表指定了 ascii 字符集以及 COMPACT 的行格式，所以这个表中记录的行格式示意图如图所示：![COMPACT行格式示意图.drawio.png](https://res.cloudinary.com/https-fallingkids-github-io/image/upload/v1655655353/blog/mysql/mysql-note-04/5-3_iurcn6.png)>图 5-3 COMPACT 行格式示意图下面总结了一下每个字段属性的大体意思，如表 5-2 所示：表 5-2 记录头信息的属性及描述

名称大小（bit）描述预留位 11没有使用预留位 21没有使用deleted_flag1标记该记录是否被删除min_rec_flag1B + 树中每层非叶子节点中的最小的目录想记录都会添加该标记n_owned4一个页面中的记录会被分成若干个组，每个组中有一个记录是 “带头大哥”，其余的记录都是 “小弟”。“带头大哥” 记录的 n_owned 值代表该组中所有的记录条数，“小弟” 记录的 n_owned 值都为 0heap_no13表示当记录在页面堆中的相对位置record_type3表示当前记录的类型，0 表示普通记录，1 表示 B + 树非叶节点的目录项记录，2 表示 Infimum 记录，3 表示 Supremum 记录next_record16表示下一条记录的相对位置下面我们只在 page_demo 表的行格式演示图中（见图 5-4）画出有关的头信息属性以及 c1、c2、c3 列的信息![page_demo表的行格式简化图.drawio.png](https://res.cloudinary.com/https-fallingkids-github-io/image/upload/v1655655406/blog/mysql/mysql-note-04/5-4_xuvckx.png)>下面向 page_demo 表中插入几条记录：

```shell
mysql> INSERT INTO page_demo VALUES(1, 100, 'aaaa'), (2, 200, 'bbbb'), (3, 300, 'cccc'), 
```
为了方便我们分析这些记录在页的 User Records 部分是这么表示的，这里爸记录中的头信息和实际的列数据都用十进制表示出来了（实际上是二进制）。这些记录的示意图如图 5-5 所示：![图5-5.drawio.png](https://res.cloudinary.com/https-fallingkids-github-io/image/upload/v1655655442/blog/mysql/mysql-note-04/5-5_pbznvd.png)>图 5-5 记录在页的 User Records 部分的存储结构