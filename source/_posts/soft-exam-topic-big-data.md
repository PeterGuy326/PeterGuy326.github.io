---
title: 软考专题 · 大数据架构（选择题 18 + 案例答题套路 + Lambda/Kappa 模拟题 + 论文提纲）
date: 2026-05-15T22:00:00+08:00
updated: 2026-05-15T22:00:00+08:00
cover: /img/covers/sysarch-bigdata.jpg
top_img: /img/covers/sysarch-bigdata.jpg
tags:
  - 软考
  - 系统架构设计师
  - 大数据
  - 数据中台
  - NoSQL
  - 案例分析
  - 论文
categories:
  - 软考
---

> 大数据是近年系统架构设计师新增的**中频考点**——综合知识每年 1-3 道选择题（Hadoop 生态 / Lambda 架构 / 数据仓库 vs 数据湖 / NoSQL 选型），案例分析中频出"大数据 / 高并发 Web 架构"25 分大题（Lambda vs Kappa 选型、实时数仓、用户行为分析平台），论文也出"论大数据处理架构及其应用 / 论 NoSQL 数据库的应用 / 论数据中台建设"。这篇把必背理论、高频选择题（带 ✅ 答案 + 解析，自主命题避版权）、案例答题套路、1 道完整模拟案例题、论文万能提纲打包在一起。内容来自开源仓库 [`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)。回到 [软考导览页](/soft-exam-system-architect-2026-guide/) 看完整专题清单。

## 一、必背：核心理论

教材参考：《系统架构设计师教程（第 2 版）》第 18 章「大数据架构设计理论与实践」。

### 大数据 5V 特征（必考）

| V | 含义 | 量级 / 表现 |
|---|---|---|
| **Volume**（体量大） | 数据规模巨大 | TB ~ EB 级 |
| **Velocity**（速度快） | 产生与处理速度快 | 流式、实时秒级、低延迟 |
| **Variety**（多样性） | 结构化 + 半结构化 + 非结构化混合 | JSON / 日志 / 图片 / 视频 |
| **Veracity**（真实性） | 数据质量参差、需治理 | 噪声 / 缺失 / 不一致 |
| **Value**（价值） | 总量大但价值密度低 | 需挖掘提炼 |

> 口诀："**量、速、变、真、值**"。早期只有 4V（无 Veracity），现教材统一按 **5V** 记。

### Hadoop 生态速查表（高频）

| 组件 | 角色 | 关键点 |
|---|---|---|
| **HDFS** | 分布式文件系统 | **NameNode**（存元数据）+ **DataNode**（存数据块），默认**副本 3**；HA 用 Active/Standby NN + JournalNode + ZKFC |
| **MapReduce** | 分布式批计算编程模型 | **Map → Shuffle（分区/排序/合并）→ Reduce**，离线 ETL（已弱化） |
| **YARN** | 资源调度 | **ResourceManager** + **NodeManager** + ApplicationMaster + Container |
| **Hive** | SQL on Hadoop（数据仓库） | HQL → MR / Spark / Tez，元数据存 MySQL |
| **HBase** | 列族式 NoSQL | 基于 HDFS + ZooKeeper，适合**海量稀疏数据 + 随机读写**，RowKey 是性能命脉 |
| **ZooKeeper** | 分布式协调 | 选主、配置、命名、分布式锁 |
| **Kafka** | 消息 / 流缓冲 | 采集与计算之间的解耦点、削峰、回放 |
| **Spark** | 内存计算引擎 | DAG + RDD，比 MapReduce 快（内存 + 宽窄依赖优化）；含 **Spark SQL / Streaming（微批）/ MLlib / GraphX** |
| **Flink** | 真流式计算引擎 | 事件时间 + 水印（Watermark），低延迟（ms ~ 亚秒），强状态（Checkpoint），**Exactly-Once**，流批一体 |
| **Sqoop** | 关系库 ↔ HDFS 批量同步 | 全量 / 增量导入导出 |
| **Flume** | 日志采集 | Source → Channel → Sink |

> "**HDFS + MapReduce + YARN**"是 Hadoop 三件套；"**Hive 离线 · HBase 随机 · Spark 内存 · Flink 真流**"是引擎记忆口诀。

### Lambda 架构 vs Kappa 架构（必考选型题）

| 维度 | **Lambda 架构** | **Kappa 架构** | 批流一体（Flink） |
|---|---|---|---|
| 层次 | **批处理层 + 速度层 + 服务层**（三层） | **仅流处理层**（一层） | 一套引擎统一流批 |
| 思想 | 同一份数据走两条链路，服务层合并 | 用流重放历史代替批处理 | Flink 视批为流的特例 |
| 代表 | Hadoop/Spark（批）+ Flink/Storm（流） | Kafka 长保留 + Flink 统一 | Flink Batch Mode / Iceberg + Flink |
| 优点 | 兼顾**准确**与**实时**，回填快（批层重跑） | **架构简化**，单套代码，运维一套集群 | 一套代码、一套语义 |
| 缺点 | **两套代码**（批 + 流逻辑漂移）、运维 2 套集群、结果合并复杂 | 回溯成本高（PB 数据从头重放慢）、对状态/存储要求高 | Flink 批量场景仍弱于 Spark |

> **Lambda 三层职责**：批处理层 = 全量精确计算、T+1，作为「**真相之源（Single Source of Truth）**」；速度层 = 增量实时计算，牺牲精度换低延迟，补全批层时间窗口；服务层 = 合并批 + 流结果对外查询。**画 Lambda 忘了服务层 = 严重失分**。

### 数据仓库 vs 数据湖 vs 数据中台 vs 湖仓一体

| 维度 | 数据仓库（DW） | 数据湖（Data Lake） | 湖仓一体（Lakehouse） | 数据中台 |
|---|---|---|---|---|
| 数据形态 | 结构化、已清洗 | 原始数据、多结构混合 | 原始 + 结构化共存 | 跨域数据资产 |
| Schema 时机 | **Schema-on-Write**（写入时定义） | **Schema-on-Read**（读取时解释） | 表格式提供 Schema 演进 | — |
| 用途 | BI 报表、固定分析 | AI / ML、数据探索 | BI + ML「一份存储两种用法」 | 数据复用 + 服务化（OneID/OneModel/OneService） |
| 代表 | Hive / Greenplum / Teradata | HDFS / S3 + 原始文件 | **Apache Iceberg / Hudi / Delta Lake** | 阿里数据中台、网易猛犸 |
| 核心能力 | 严格、可信 | 灵活、低成本 | ACID + Time Travel + Schema 演进 + 流批一体 | 资产盘点 + 标签体系 + 数据 API |

### OLTP vs OLAP

| 维度 | OLTP（联机事务处理） | OLAP（联机分析处理） |
|---|---|---|
| 面向 | 事务（增删改查） | 分析（多维聚合、钻取） |
| 设计范式 | 范式化（3NF），减少冗余 | **星型 / 雪花模型**（维度建模），适度冗余 |
| 存储 | **行存**（一行数据连续存放） | **列存**（同一列连续存放，压缩比高、聚合快） |
| 数据量 | 较小（当前业务数据） | 通常远大于 OLTP（含历史聚合，PB 级） |
| 典型系统 | MySQL / Oracle 业务库 | ClickHouse / Druid / Doris / Kylin / Hive |

### 维度建模 + ETL vs ELT

- **事实表（Fact）**：记录业务过程的度量值（销售额、订单数），外键指向各维度表，行数大。
- **维度表（Dimension）**：描述性属性（时间、地区、商品、用户），行数小，相对稳定。
- **星型模型**：一张事实表 + 多张维度表直连，维度表**不再规范化**（查询快、冗余多）。
- **雪花模型**：维度表进一步规范化拆成多层（省 → 市 → 区），减冗余但 JOIN 变多。
- **星座模型（事实星座）**：多张事实表共享维度表。
- **ETL**：抽取 → 转换 → 加载，转换在中间引擎做（传统数仓）。**ELT**：抽取 → 加载 → 转换，先入湖再用湖内算力做转换（湖仓时代，「算力下沉」）。

### NoSQL 四大类 + CAP / BASE

| 类型 | 代表 | 数据模型 | 适用场景 | CAP 取向 |
|---|---|---|---|---|
| **键值** | Redis / Memcached | key → value | 缓存、会话、排行榜（ZSet）、计数 | AP（Redis 集群） |
| **文档** | MongoDB / CouchDB | JSON / BSON 文档 | 半结构化内容、灵活 Schema、聚合管道 | CP（MongoDB 默认） |
| **列族** | HBase / Cassandra | 行键 + 列族 | 海量稀疏数据（日志、IoT、用户画像宽表）、随机读写 | **HBase = CP**，**Cassandra = AP** |
| **图** | Neo4j / JanusGraph | 点 + 边 + 属性 | 社交关系、金融反欺诈、推荐、知识图谱 | 视实现而定 |

- **CAP 定理**：一致性（Consistency）/ 可用性（Availability）/ 分区容错性（Partition Tolerance）三者不可兼得；分布式系统**必选 P**，于是在 **CP**（ZooKeeper / Etcd / HBase）与 **AP**（Cassandra / Dynamo）之间取舍。
- **BASE**：**B**asically Available（基本可用）+ **S**oft state（软状态）+ **E**ventually consistent（最终一致），是 NoSQL 对 ACID 强一致的妥协，对应"柔性事务"。

### 数据治理（数据湖 / 数据中台核心）

| 维度 | 含义 | 代表工具 |
|---|---|---|
| **数据质量** | 完整性 / 准确性 / 一致性 / 及时性校验 | Great Expectations、自研规则引擎 |
| **元数据管理** | 技术元数据 + 业务元数据 + 操作元数据 | Apache Atlas、DataHub |
| **数据血缘** | 字段级 / 表级上下游溯源，影响分析 | Atlas、SQL 解析 |
| **数据安全 / 脱敏** | 分级分类、字段级 ACL、动态脱敏、加密 | Apache Ranger |
| **主数据管理（MDM）** | 客户 / 商品 / 组织等核心数据的唯一权威来源 | 自研 MDM 平台 |

> 答题口诀："数据治理 = **元数据 + 质量 + 血缘 + 安全脱敏 + 主数据**"五位一体，配合 **OneID / OneModel / OneService** 输出数据资产。

## 二、高频选择题（18 题，✅ 为正确选项）

### 1. HDFS 中默认的数据块副本数是：
A. 1　B. 2　✅ **C. 3**　D. 5
> 默认 3 副本（同机架 2 份 + 跨机架 1 份），保证高可用与就近读取。

### 2. HDFS 中负责存储**文件元数据**（目录树、块位置映射）的组件是：
✅ **A. NameNode**　B. DataNode　C. SecondaryNameNode　D. JournalNode
> NameNode 管元数据，DataNode 存实际数据块；SecondaryNameNode 只做 fsimage 合并，不是热备。

### 3. MapReduce 的执行流程正确顺序是：
A. Reduce → Shuffle → Map　✅ **B. Map → Shuffle → Reduce**　C. Map → Reduce → Shuffle　D. Shuffle → Map → Reduce
> Map 阶段产出键值对，Shuffle 做分区 / 排序 / 合并并拉取，Reduce 汇总。

### 4. YARN 中负责**全局资源调度**的组件是：
✅ **A. ResourceManager**　B. NodeManager　C. ApplicationMaster　D. Container
> RM 全局调度，NM 管单节点资源，AM 管单个应用，Container 是资源封装单位。

### 5. 关于 Hive 与 HBase 的对比，描述**错误**的是：
A. Hive 适合离线批量分析，HBase 适合海量随机读写　B. Hive 提供类 SQL 查询（HQL），HBase 提供 API 级访问　C. 两者底层都可基于 HDFS　✅ **D. HBase 适合复杂多表 JOIN 的 OLAP 分析**
> HBase 是列族 NoSQL，不擅长多表 JOIN；复杂 OLAP 用 ClickHouse / Doris / Hive。

### 6. 关于 Spark 比 MapReduce 快的原因，描述**错误**的是：
A. Spark 基于内存计算，减少磁盘 I/O　B. Spark 用 DAG 调度，可做宽窄依赖优化　C. Spark 支持迭代式计算（如机器学习）效率高　✅ **D. Spark 不需要 Shuffle，因此更快**
> Spark 同样有 Shuffle（宽依赖会触发），只是整体更高效，并非"没有 Shuffle"。

### 7. 下列计算引擎中，**真正的流式处理**（事件时间 + 水印 + 强状态 + Exactly-Once）的是：
A. MapReduce　B. Spark Core　C. Spark Streaming（微批）　✅ **D. Flink**
> Spark Streaming 是微批（Micro-Batch），Flink 是原生流，延迟更低、状态更强。

### 8. 大数据 5V 特征**不包括**：
A. Volume（体量）　B. Velocity（速度）　C. Veracity（真实性）　✅ **D. Visibility（可见性）**
> 5V = Volume / Velocity / Variety / Veracity / Value。

### 9. Lambda 架构由哪三层构成？
✅ **A. 批处理层 + 速度层 + 服务层**　B. 采集层 + 计算层 + 展示层　C. 接入层 + 应用层 + 数据层　D. ODS + DWD + ADS
> Batch Layer（精确）+ Speed Layer（实时）+ Serving Layer（合并查询），缺一不可。

### 10. 关于 Lambda 架构与 Kappa 架构的对比，描述**正确**的是：
A. Kappa 保留批处理层，去掉速度层　✅ **B. Kappa 只保留流处理层，用流重放历史代替批处理**　C. Lambda 比 Kappa 运维更简单　D. Kappa 一定优于 Lambda
> Kappa 简化架构但回溯（重放历史）成本高；长周期复杂业务仍常用 Lambda。

### 11. 数据仓库的数据特征**不包括**：
A. 面向主题　B. 集成性　C. 反映历史变化　✅ **D. 实时高频更新**
> 数仓四特征：面向主题、集成、相对稳定（非实时）、反映历史变化（随时间变化）。

### 12. 数据湖与数据仓库的核心区别在于：
✅ **A. 数据湖是 Schema-on-Read，数据仓库是 Schema-on-Write**　B. 数据湖只能存结构化数据　C. 数据仓库不需要 ETL　D. 数据湖一定比数据仓库快
> 湖在读取时才解释结构（灵活），仓在写入时强约束结构（严格、可信）。

### 13. 关于 OLTP 与 OLAP 的对比，描述**错误**的是：
A. OLTP 面向事务，OLAP 面向分析　B. OLTP 多用范式化设计，OLAP 多用星型/雪花模型　C. OLAP 常用列式存储　✅ **D. OLTP 的数据量通常远大于 OLAP**
> OLAP 含大量历史与聚合数据，数据量通常远大于 OLTP。

### 14. 维度建模中，**星型模型**与**雪花模型**的主要区别是：
A. 星型有事实表，雪花没有　✅ **B. 雪花模型的维度表进一步规范化拆分，星型模型维度表不规范化**　C. 星型只能有一张维度表　D. 雪花模型查询一定更快
> 雪花减冗余但 JOIN 增多查询变慢；星型查询快但维度表冗余。

### 15. 下列 NoSQL 中，**最适合**存储用户画像宽表（海量、稀疏、随机读写）的是：
A. Redis　B. MongoDB　✅ **C. HBase**　D. Neo4j
> 列族数据库天然适合稀疏宽表与随机读写；Redis 适合热点缓存，Neo4j 适合关系。

### 16. 下列 NoSQL 中，**最适合**社交关系网络 / 金融反欺诈的是：
A. Redis　B. MongoDB　C. HBase　✅ **D. Neo4j**
> 图数据库擅长多跳关系遍历（三度好友、资金链路追踪）。

### 17. 湖仓时代将传统 ETL 改为 ELT，其核心变化是：
✅ **A. 先加载原始数据入湖，再用湖内算力做转换（算力下沉）**　B. 取消数据转换环节　C. 转换必须在关系库里做　D. 加载必须在转换之后
> ELT = Extract → Load → Transform，先入湖保留原始数据，转换下沉到湖内引擎（Spark/Flink）。

### 18. 关于 CAP 定理在 NoSQL 中的体现，描述**错误**的是：
A. 分布式系统必须满足分区容错性 P　B. HBase 偏向 CP（强一致）　C. Cassandra 偏向 AP（高可用）　✅ **D. 一个系统可以同时完全满足 C、A、P 三者**
> CAP 三者不可兼得，分区发生时只能在 C 与 A 之间二选一。

> 原文 + 解析：[`exam-bank/03-database.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/exam-bank/03-database.md)（含 NoSQL 与大数据相关题）、[`knowledge-index/19-big-data.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/knowledge-index/19-big-data.md)

## 三、案例答题套路（大数据 / 高并发 Web 架构，25 分）

> 这类题给一段"海量数据 + 实时分析 + 离线报表"或"高并发 Web"的场景（电商用户行为分析、实时大屏、风控、运营商话单、数据中台），按下面 6 步铺答案，每点一句结论 + 一句理由 / 参数。

### ① 数据采集层
- 业务日志 / 客户端埋点 → **Flume / Filebeat / Logstash**；数据库变更 → **Canal / Debezium（CDC）**；关系库批量同步 → **Sqoop**。
- 统一进 **Kafka**（分区数 + 副本因子 3 + 保留 7 天）做**削峰 + 解耦 + 回放**——"Kafka 是采集与处理之间的解耦中枢"。
- 数据契约：**Avro / Protobuf + Schema Registry** 强约束，防上游随意改字段。

### ② 存储分层（冷热分层）
- 热数据（最近 30 天，亚秒查）→ **ClickHouse / Druid**；温数据（半年，明细随机读）→ **HBase**；冷数据（多年归档）→ **HDFS / S3 + ORC/Parquet + Snappy**（压缩比 5~10 倍）；热点 KV → **Redis**。
- "冷热分层 = 用存储成本换查询性能"，归档数据降级到对象存储省 50%+ 成本。

### ③ 计算引擎选型
| 场景 | 选型 | 理由 |
|---|---|---|
| 离线批处理（T+1 数仓 ETL） | **Spark**（迭代/内存敏感）/ MapReduce（简单 ETL） | DAG + 内存计算，全量精确 |
| 实时流计算（秒级看板、风控） | **Flink** | 真流 + 事件时间 + Exactly-Once |
| 即席查询 / BI（分析师 SQL） | **Presto/Trino**、**ClickHouse** | 列存、亚秒级聚合 |
| 数据仓库（固定报表分层） | **Hive**（+ Spark/Tez 引擎） | SQL on Hadoop、生态成熟 |

### ④ 架构模式选型（Lambda vs Kappa——必给选型依据）
- 需要**历史回溯 + 实时**、对**精确度要求高**、数据规模大（回填 Kappa 重放慢）→ **Lambda**；
- 业务**主要看实时**、数据规模较小（< 10TB/日）、不需要重跑长周期历史、想**简化运维** → **Kappa**；
- 团队 **Flink 成熟**、想消除双代码 → 演进到 **批流一体（Flink Batch Mode）/ 湖仓一体（Iceberg + Flink）**。

### ⑤ 数据服务层
- OLAP 引擎（ClickHouse/Druid）对外提供多维查询；Redis 提供毫秒级特征 / 热点查询；HBase 提供画像宽表点查；统一用 **gRPC/Dubbo + 数据 API 网关** 对外，限流 + 鉴权。

### ⑥ 数据治理与质量
- **元数据 + 血缘（Atlas）+ 数据质量（Great Expectations）+ 安全脱敏（Ranger）+ 主数据 MDM** 五位一体；
- 调度用 **Airflow / DolphinScheduler**，跑数千离线任务 + SLA 监控（批延迟 SLA、流延迟 SLA、质量异常率 < 0.1%）。

### 万能高分句
- "采用 **Lambda 架构**：批层 Spark 保证全量精确（**真相之源**），速度层 Flink 实时计算补全时间窗口，服务层 ClickHouse 合并批 + 流结果对外亚秒级查询。"
- "OLAP 查询引擎选 **ClickHouse**，单查询亚秒级，支持 100 亿行明细。"
- "Flink 通过 **Checkpoint + 两阶段提交（2PC）+ 幂等 Sink** 三件套保证 **Exactly-Once** 语义。"
- "通过 **CDN + 多级缓存（本地 Caffeine + Redis）+ 异步削峰（MQ）** 支撑双 11 峰值 QPS 50 万，多级缓存削峰比 10000:1。"
- "针对**数据倾斜**采用**加盐打散 + 二次聚合 + Map 端 Combiner**，配合 Spark AQE 把任务从 4h 降至 30min。"

### 常见陷阱
| ❌ | ✅ |
|---|---|
| 只讲 Hadoop / 只讲离线 | 必须**实时（Flink）+ 离线（Spark）**结合 |
| 画 Lambda 漏掉服务层 | 批 + 速度 + **服务**三层缺一不可 |
| NoSQL 一把梭 | 按**数据结构 + 访问模式**选型，每个 NoSQL 给场景理由 |
| Kappa 答"完全取代 Lambda" | 大数据规模下回填代价高，Lambda 仍是常见阶段性方案 |
| 不谈数据治理 | **元数据 / 血缘 / 质量 / 脱敏**是数据湖/中台核心 |
| 不做容量估算 | QPS / TPS / 存储要量化到分区 / 节点数（含 1.2~1.5 冗余系数） |
| Web 只讲缓存 | **接入 + 应用 + 缓存 + DB** 全链路，CDN 是首要削峰利器 |

> 完整套路 + Web 高并发四层架构 + 容量估算方法，见 [`case-types/09-big-data-architecture.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/09-big-data-architecture.md)。

## 四、完整模拟案例题（25 分）

> ⚠️ 自主命题改编，建议严格 25 分钟限时作答。仓库这一题型共 **3 道**完整模拟题（用户行为 Lambda 架构 · 数据湖仓一体 Lakehouse · Web 高并发三层架构 + CDN + LB，均含题干、参考答案、评分要点），见 [`case-types/09-big-data-architecture.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/09-big-data-architecture.md)。下面摘录最经典的一道。

### 模拟题 · 短视频平台「用户行为分析平台」Lambda 架构选型

**【题干简述】** 某头部短视频平台日活 3 亿，要基于用户行为日志（曝光 / 点击 / 播放 / 点赞 / 评论 / 关注 / 完播）构建统一的"用户行为分析平台"，同时满足：① 离线 T+1 报表（精算 KPI、留存、漏斗）；② 实时秒级看板（大促直播间、广告投放效果）；③ 小时级 AB 实验分析；④ 毫秒级实时用户画像写入推荐系统。数据规模：日均日志 1500 亿条 / 80 TB，峰值 400 万条/秒；冷热分层——热（30 天）ClickHouse、温（半年）HBase、冷（3 年）HDFS + ORC + Snappy。架构师 G 拟采用 **Lambda 架构**：客户端 SDK → Filebeat → **Kafka**（200 分区、副本 3、保留 7 天）；**批处理层** Kafka → HDFS（ORC + Snappy）→ **Spark**（每日 02:00）→ Hive ODS/DWD/DWS/ADS 四层数仓 → ClickHouse；**速度层** Kafka → **Flink**（Checkpoint 30s、Exactly-Once）→ ClickHouse / Redis / HBase；**服务层** 批 + 流结果合并；调度 DolphinScheduler + Airflow；治理 Atlas（元数据 + 血缘）+ Great Expectations（质量）+ Ranger（权限）。业务方质疑：① 为何不直接用 Kappa 替代 Lambda 双层？② Flink Exactly-Once 怎么保证？③ Lambda 两份代码逻辑漂移怎么办？④ 实时大屏看到的数据该信批层还是速度层？

**问 1**（10 分）：画出本系统完整的 Lambda 架构数据流图（采集 → 批层 / 速度层 → 服务层 → 应用层），并解释 Lambda 三层模型（批处理层 / 速度层 / 服务层）的职责分工。
**问 2**（6 分）：Lambda vs Kappa 选型——本系统为何选 Lambda 而不是 Kappa？请从**精确度、复杂度、回填能力、运维成本** 4 个维度分析。
**问 3**（5 分）：Flink Exactly-Once 语义如何实现？请描述 **Checkpoint + 两阶段提交（2PC）+ 幂等 Sink** 的协同机制。
**问 4**（4 分）：Lambda 架构两份代码导致逻辑漂移是常见痛点，请给出至少 2 种业界解决方案。

**【参考答案要点】**

**问 1** 数据流：客户端 SDK 埋点 / 服务端日志 → Filebeat → **Kafka**（中枢）；DB 变更 → Canal → Kafka。**批处理层**：Kafka → HDFS 落地（ORC + Snappy）→ Spark（每日 02:00 全量）→ Hive 四层数仓（ODS/DWD/DWS/ADS）→ ClickHouse 报表层。**速度层**：Kafka → Flink（Checkpoint 30s、Exactly-Once）→ 实时聚合去重 → ClickHouse / Redis（特征）/ HBase（画像宽表）。**服务层**：批 + 流结果在 ClickHouse 按时间窗口拼接合并对外查询。**应用层**：T+1 BI 报表 / 实时大屏 / 推荐系统 / AB 实验平台。
三层职责：**批处理层** = 全量数据精确计算、T+1 离线，作为「**真相之源（Single Source of Truth）**」（Spark + Hive，处理 80TB/日全量）；**速度层** = 增量数据实时计算，**牺牲精度换低延迟**，弥补批层时间窗口（Flink，秒级延迟，最近 N 分钟数据）；**服务层** = 合并批 + 流结果对外提供查询（ClickHouse 同时容纳两层结果，按时间窗口拼接）。

**问 2** 四维度对比：

| 维度 | Lambda | Kappa |
|---|---|---|
| 精确度 | ✅ 批层全量精确，流层近似 | ⚠ 仅流式，依赖 Exactly-Once |
| 复杂度 | ❌ 双套代码、运维 2 套集群 | ✅ 单套代码、仅 Flink |
| 回填能力 | ✅ 批层重跑历史，1500 亿条 4 小时跑完 | ❌ 仅靠 Kafka 回放，3PB 从头消费需 7+ 天 |
| 运维成本 | ❌ Spark + Flink 双团队 | ✅ 仅 Flink 团队 |

选 Lambda 的理由：① **数据规模决定**——累计 3PB，Kappa 重放 Kafka 需 7+ 天，业务不可接受，Spark 4 小时跑完更经济；② **精确度要求**——KPI 报表用于决策和 AB 实验显著性检验，必须全量精确；③ **历史回溯**——分析师常 SQL 查 1 年内任意时间段数据立方体，Kappa 仅靠 Kafka 保留无法支持；④ **成熟度**——Spark + Hive 数仓 10 年成熟，团队有沉淀；⑤ Kappa 适合数据规模较小（< 10TB/日）+ 不需重跑历史的纯流式业务（IoT、监控）。

**问 3** Flink 通过三件套保证 Exactly-Once：① **Checkpoint Barrier 注入**——JobManager 周期性（30s）发出 Barrier 从 Source 注入数据流，Barrier 流经所有算子触发 State 快照到分布式存储（HDFS/S3）；② **两阶段提交（Sink 端）**——Phase 1 PreCommit：Sink 收到 Barrier 后把缓冲数据写入"预提交"状态（如 Kafka Producer 开启事务），上报 JobManager；Phase 2 Commit：所有算子 PreCommit 成功后 JobManager 触发全局 Commit，Sink 提交事务（Kafka commitTransaction）数据真正可见，任一节点 PreCommit 失败则全局 Rollback 回到上一个 Checkpoint；③ **幂等 Sink 兜底**——Kafka 用 transactional.id + idempotent、MySQL 用 INSERT ... ON DUPLICATE KEY UPDATE、HBase 基于 RowKey 天然幂等。故障恢复时 Flink 从最后成功 Checkpoint 恢复 State + Source 偏移量，重算 + 2PC，对外精确一次。

**问 4** 解决两份代码逻辑漂移的方案（≥2 种）：① **Apache Beam（统一编程模型）**——一份 Beam Pipeline 代码，通过 Runner 适配 Spark/Flink/Dataflow，代价是学习成本高、生态不如原生；② **批流一体（Kappa+）**——仅保留 Flink 一套，批处理用 Flink Batch Mode（基于 DataStream API），统一 SQL，代价是 Flink 批量场景仍弱于 Spark；③ **湖仓一体（Lakehouse）**——一套数据用 Iceberg/Hudi 统一存储，Spark 批 + Flink 流共享数据、SQL 统一，代价是需引入新存储格式；④ **代码同源 + 双 CI**——共享 UDF 库，批/流主控制流分离但核心计算逻辑一份，CI 同步校验（治标）。推荐演进路线：第 1 年共享 UDF + 双 CI 兜底；第 2 年推进湖仓一体（Iceberg）统一 Spark + Flink SQL；第 3 年评估 Kappa+。

> 完整版（含 Mermaid 数据流图、详细评分要点、常见扣分点、高分技巧）见 [`case-types/09-big-data-architecture.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/09-big-data-architecture.md) 模拟题 1。另两道（数据湖仓一体 Lakehouse · Web 高并发三层架构 + CDN + LB 容量估算）也在同一文件。

## 五、论文万能提纲（约 2500 字）

**典型题目**：论大数据处理架构及其应用 / 论 Lambda（Kappa）架构及其应用 / 论 NoSQL 数据库的应用 / 论数据湖与数据仓库 / 论数据中台建设。

```
1. 背景（350 字）— 海量数据 / 实时分析需求；数据规模量化（日增 100 亿条 / 10TB / PB 级存储）；
   业务诉求：实时大屏（秒级）+ 离线报表（T+1）+ AI 推荐；团队规模、关键质量属性（吞吐/延迟/准确性/成本）
2. 理论（350 字）— 大数据 5V（量速变真值）+ Hadoop 生态（HDFS/MapReduce/YARN/Hive/HBase）
   + Lambda（批+速度+服务三层）vs Kappa（仅流）+ NoSQL 四类（键值/列族/文档/图）+ CAP/BASE + 数据湖 vs 数仓 vs 湖仓一体
3. 实践论述（1600 字）⭐⭐⭐⭐⭐ —— 六要点：
   (1) 数据采集：Flume 采日志 + Canal 采 binlog → Kafka（10 节点 200 分区 副本 3）；Avro Schema Registry 强约束；日吞吐 100 亿条、峰值 50 万 EPS
   (2) 存储分层：热（Redis 用户画像/热点 TTL 1h）+ 温（HBase 明细 RowKey 哈希避热点）+ 冷（HDFS Parquet 压缩比 7 倍）+ OLAP（ClickHouse 聚合宽表亚秒级）；存储成本降 60%
   (3) 批流计算引擎选型：批层 Spark 凌晨跑全量 T+1 精确；速度层 Flink 消费 Kafka 5s 窗口；服务层合并批+流结果统一查询；Flink Checkpoint + RocksDB 持久化
   (4) Lambda → Kappa 演进：抽象 Flink SQL + Spark SQL 共用语义层；阶段性 Lambda → 湖仓一体（Iceberg）→ Kappa+；解决双链路逻辑漂移
   (5) 数据中台 / 数据湖建设：ODS/DWD/DWS/ADS 四层数仓；OneID/OneModel/OneService 数据资产化；数据 API 服务化对外
   (6) 数据治理：元数据 + 血缘（Atlas）+ 数据质量（Great Expectations）+ 安全脱敏（Ranger）+ 主数据 MDM；调度 DolphinScheduler；每日对账保口径一致
4. 权衡与教训（250 字）— Lambda 双链路维护成本高 → 抽象 SQL 层 / 演进到 Kappa 或批流一体（Iceberg + Flink）；
   Kafka 数据倾斜 → Key 预处理 + 自定义 Partitioner；实时与离线口径不一致 → 血缘 + 每日对账；
   NoSQL 不是银弹 → 按场景选型；不谈治理就是耍流氓
5. 成效（150 字）— 实时延迟 800ms、离线 T+1 凌晨 6 点完成、查询 QPS 12 万、零数据丢失、压缩比 7 倍、存储成本降 60%
```

**摘要模板**："我于 2023 年参与了 {电商用户行为分析 / 工业 IoT 监控 / 金融实时风控} 平台建设，担任 {大数据架构师}。系统接入 {日增 100 亿条事件 / 10TB 数据 / 1000 万 DAU}，要求实时延迟 < 1 秒、离线 T+1 准确。本文论述 Lambda 架构在该项目的落地：采集层 Flume + Kafka、存储层 HDFS + HBase + Redis 冷热分层、计算层 Spark 批 + Flink 流、查询层 ClickHouse OLAP、治理层 Atlas 血缘 + Great Expectations 质量。最终实时大屏延迟 800ms、离线报表 T+1 凌晨 6 点完成、查询 QPS 12 万、整体压缩比 7 倍、存储成本降 60%。同时分析了 Lambda 双链路维护成本高的问题，给出向湖仓一体 / Kappa+ 演进的路线。"

**加分关键词**：大数据 5V、Lambda、Kappa、批流一体、HDFS/MapReduce/YARN、Hive、HBase、Spark、Flink、Checkpoint、Exactly-Once、2PC、Kafka、ClickHouse/Druid、数据湖、数据仓库、湖仓一体（Iceberg/Hudi/Delta Lake）、Schema-on-Read、ETL/ELT、星型/雪花模型、CAP、BASE、NoSQL 四类、数据中台、OneID/OneModel/OneService、元数据/血缘/数据质量/数据脱敏/MDM；业界对标：阿里 MaxCompute / 数据中台、字节 ByteHouse、网易猛犸、Netflix Iceberg、Databricks Delta Lake / Lakehouse、Nathan Marz《Big Data》。

**避坑**：① 只提 Hadoop → 必须实时（Flink）+ 离线（Spark）结合；② NoSQL 混用不说理由 → 每个 NoSQL 必须给场景匹配理由（Redis 热点缓存、HBase 海量明细、ClickHouse OLAP、Neo4j 关系）；③ 不谈数据治理 → 元数据 / 血缘 / 质量是数据湖核心；④ 无数据量 → 必须量化（日 X 亿条 / X TB / 实时 < 1s / 离线 T+1 / 查询 QPS X 万 / 压缩比 7x）；⑤ Lambda vs Kappa 写成"二选一" → 实际 Lambda 是阶段性、Kappa 是演进方向；⑥ Redis 当数据库用 → 缓存与持久化分清，主存数据放 MySQL/HBase。

> 完整理论 + 模拟论文（2 道，含提纲式参考答案、评分维度对照表、加分关键词清单）：[`paper-topics/06-big-data-nosql.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/paper-topics/06-big-data-nosql.md)；大数据案例笔记：[`notes/18-case-big-data/README.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/notes/18-case-big-data/README.md)

---

> 软考专题系列第 10 篇。同系列：[架构评估 ATAM](/soft-exam-topic-atam-evaluation/) · [架构风格对比](/soft-exam-topic-architecture-styles/) · [微服务与云原生](/soft-exam-topic-microservice-cloud-native/) · [数据库设计](/soft-exam-topic-database-design/) · [消息中间件与缓存](/soft-exam-topic-messaging-caching/) · [法律法规与标准化](/soft-exam-topic-ip-and-standards/) · [计算题专项](/soft-exam-topic-exam-calculations/) · [软件架构安全](/soft-exam-topic-security/) · [设计模式 GoF 23](/soft-exam-topic-design-patterns/)。完整清单见 [软考导览页](/soft-exam-system-architect-2026-guide/)。发现题目错误欢迎到 [仓库](https://github.com/PeterGuy326/senior-software-architect-review) 开 issue。
