---
title: 软考专题 · 消息中间件与缓存（选择题 22 + 案例答题套路 + 双 11 秒杀模拟题 + 答题模板）
date: 2026-05-11T22:00:00+08:00
updated: 2026-05-11T22:00:00+08:00
cover: /img/covers/sysarch-cache.jpg
top_img: /img/covers/sysarch-cache.jpg
tags:
  - 软考
  - 系统架构设计师
  - 缓存
  - 消息队列
  - Redis
  - 案例分析
categories:
  - 软考
---

> 「消息中间件 + 缓存」是系统架构设计师**案例分析的高频题型**——近 5 年多次出 25 分大题（缓存三大问题、Cache Aside 一致性、MQ 选型对比、顺序/幂等），综合知识里每年也有 2-4 道选择题（Redis 持久化与数据结构、消息可靠性语义、分布式锁失效场景）。这篇把高频选择题（带 ✅ 答案 + 解析）、案例答题套路、1 道完整模拟题（双 11 秒杀）、答题万能模板打包在一起。内容来自开源仓库 [`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)。回到 [软考导览页](/soft-exam-system-architect-2026-guide/) 看完整专题清单。

## 一、必背：核心理论

### 缓存三大经典问题（**穿透 / 击穿 / 雪崩，必须区分**）

| 问题 | 触发条件 | 关键区别 | 主要解法 |
|---|---|---|---|
| **缓存穿透** | 查询**根本不存在**的数据，每次都打到 DB | "数据不存在" | 布隆过滤器、缓存空值（短 TTL）、参数校验 |
| **缓存击穿** | **单个热点 Key** 在过期瞬间被大量并发请求击中 | "一个热点 Key 失效" | 互斥锁（只放 1 个回源）、热点 Key 永不过期、逻辑过期 + 异步刷新 |
| **缓存雪崩** | **大量 Key 同时过期** 或缓存集群整体宕机 | "大批 Key 一起失效" | TTL 加随机值打散、多级缓存、熔断限流、集群高可用 |

口诀：**穿透 = 数据不存在；击穿 = 一个热 Key 过期；雪崩 = 一大片 Key 一起过期**。

### 缓存一致性策略（经典四种）

| 模式 | 流程 | 特点 |
|---|---|---|
| **Cache Aside**（旁路，最常用） | 读：先查缓存，未命中查 DB 并回填；写：**先写 DB，再删缓存** | 简单；存在短暂不一致窗口 |
| **Read/Write Through** | 应用只读写缓存层，由缓存层同步操作 DB | 一致性好；缓存层实现复杂 |
| **Write Behind（Write Back）** | 写缓存立即返回，异步批量刷 DB | 写性能最好；宕机可能丢数据 |
| **Refresh Ahead** | 缓存过期前主动刷新 | 命中率高；需预测热点 |

**Cache Aside 两个必问细节**：

- 为什么"先写 DB，再删缓存"而不是"先删缓存，再写 DB"？——先删缓存的话，并发读请求会在"删缓存→写 DB"窗口内**把旧值重新加载回缓存**，造成长期脏数据；先写 DB 再删缓存只有极小的 ms 级窗口可能读到旧值。
- 为什么是"删"缓存而不是"更新"缓存？——删是**幂等**的；更新需要复杂计算，并发下可能写入不一致的中间值。
- **延迟双删**（高并发兜底）：删缓存 → 写 DB → 延迟 N ms 再删一次缓存。
- **强一致兜底**：Canal 订阅 MySQL binlog，监听变更后异步删缓存（近实时、对业务无侵入）。

### Redis 数据结构选型 & 持久化

| 场景 | 结构 | 命令示例 |
|---|---|---|
| 计数器 / 限流 | String | INCR / EXPIRE |
| 对象字段存储 | Hash | HSET / HGETALL |
| 消息队列 / 栈 | List | LPUSH / BRPOP |
| 标签 / 去重集合 | Set | SADD / SISMEMBER |
| 排行榜 / 延迟队列 | ZSet | ZADD / ZRANGEBYSCORE |
| 海量基数去重统计 | HyperLogLog | PFADD / PFCOUNT |
| 附近的人 / 地理围栏 | GEO | GEOADD / GEOSEARCH |
| 签到 / 在线状态位图 | Bitmap | SETBIT / BITCOUNT |

持久化：**RDB**（定时快照，恢复快、体积小，但宕机丢最后一次快照后的数据）；**AOF**（追加写命令，`appendfsync everysec` 最多丢 1s 数据，文件大、恢复慢）；生产推荐 **RDB + AOF 混合持久化**（Redis 4.0+）。

### 分布式锁（Redis 实现，**失效场景必考**）

```
SET lock_key {unique_value} NX PX 30000
```

- **NX**：不存在才设置（保证互斥）；**PX**：过期时间（防止持锁者宕机后死锁）；**unique_value**：释放锁时用 Lua 脚本校验后再删（防误删别人的锁）。
- Redisson 进阶：**看门狗（Watch Dog）自动续期**、可重入、**RedLock**（向多数派节点加锁）。
- 失效场景：① **主从切换**——锁还没同步到从节点，主就挂了 → RedLock；② **业务执行超时**——锁已过期但业务没跑完 → 看门狗续期；③ **GC 停顿 / STW**——长时间停顿导致锁过期 → fencing token（递增版本号）。

### 消息队列对比（**案例选型题必背**）

| 维度 | Kafka | RabbitMQ | RocketMQ | Pulsar |
|---|---|---|---|---|
| 吞吐 | **百万级 TPS** | 万级 | 十万级 | 百万级 |
| 延迟 | ms 级 | **μs~ms 级（最低）** | ms 级 | ms 级 |
| 顺序 | 分区内有序 | 队列内有序 | Queue 内有序 + 顺序消息 API | 分区内有序 |
| 事务消息 | 弱（仅生产端事务） | 不支持 | **支持（half message + 回查）** | 支持 |
| 副本一致性 | ISR 半同步 | 镜像队列（性能差） | SYNC_MASTER 同步双写 | BookKeeper 多副本（存算分离） |
| 协议/生态 | 自有二进制，流计算生态强 | **AMQP，路由模式最丰富** | 自有 + OpenMessaging | 兼容 Kafka + MQTT |
| 适用 | 日志 / 大数据管道 | 业务消息 / 复杂路由 / 延迟消息 | **金融 / 电商 / 事务交易** | 云原生 / 多租户 |

核心定位：**Kafka = 大吞吐日志管道；RabbitMQ = 业务消息瑞士军刀；RocketMQ = 金融级业务消息；Pulsar = 云原生新一代**。

### 消息可靠性三要素（**不丢 / 不重 / 顺序**）

- **不丢消息**：生产端同步发送 + 确认 ACK + 失败重试（仍失败写本地兜底表）；Broker 多副本 + 持久化（Kafka `min.insync.replicas ≥ 2`，RocketMQ `SYNC_MASTER` 同步双写 + 关键 Topic 同步刷盘）；消费端**手动 ACK**，业务处理成功后再提交 offset。
- **不重复消费（幂等）**：MQ 一般只承诺 **at-least-once**，必须靠业务幂等——唯一键去重表（`UNIQUE INDEX`）、Redis `SETNX`、业务状态机单向流转。**`at-least-once + 业务幂等 = exactly-once 效果`**。
- **顺序消息**：全局顺序 → 单分区/单队列（吞吐低）；局部顺序 → 按业务主键 hash 到同一分区/队列（推荐，如 `hash(order_id) % queue_num`），消费端单线程串行消费该队列。

### 其他高频概念

- **削峰填谷**：突发流量先进 MQ，下游按自己的速率匀速消费——MQ 的核心价值之一（异步、解耦、削峰）。
- **本地消息表 / 事务消息**：解决"DB 写入"与"MQ 投递"的最终一致——本地事务里同时写业务表和消息表，再由后台任务投递；或用 RocketMQ 事务消息（half message + 事务回查）。
- **死信队列（DLQ）**：消费重试达上限仍失败的消息转入 DLQ，由人工/补偿任务处理；DLQ 也要监控告警，避免静默堆积。
- **消息堆积**：消费慢于生产 → 扩消费者（不超过分区数）、批量消费、排查下游慢点；Kafka 分区数决定消费并行度上限。

## 二、高频选择题（22 题，✅ 为正确选项）

### 1. 缓存"穿透"指的是：
✅ **A. 查询数据库中根本不存在的数据，请求每次都落到 DB**　B. 热点 Key 过期瞬间大量请求打到 DB　C. 大量 Key 同时过期导致 DB 压力骤增　D. Redis 内存被写满触发淘汰
> 穿透 = 数据不存在；击穿 = 单热点 Key 过期；雪崩 = 大批 Key 同时过期。

### 2. 解决缓存穿透**最有效**的方案是：
A. 增大缓存容量　B. 延长所有 Key 的 TTL　✅ **C. 布隆过滤器 + 对不存在的 Key 缓存空值**　D. 给 Redis 加从节点
> 布隆过滤器在查 DB 之前就拦掉不存在的 Key；空值缓存兜底防止"刚好被布隆误判通过"的请求反复打 DB。

### 3. 缓存"击穿"的针对性解法**不包括**：
A. 热点 Key 设置为永不过期，后台异步刷新　B. 互斥锁，只允许一个线程回源　C. 逻辑过期：value 内嵌过期时间，过期后异步刷新返回旧值　✅ **D. 给所有 Key 的 TTL 加随机值**
> "TTL 加随机值"是防**雪崩**（大批 Key 别同时失效），不解决单个热点 Key 击穿。

### 4. 关于缓存雪崩，下列描述**错误**的是：
A. 大量 Key 在同一时刻集中过期会引发雪崩　B. 缓存集群整体宕机也属于雪崩　C. 多级缓存（本地 Caffeine + 分布式 Redis）能缓解雪崩　✅ **D. 雪崩只能靠重启 Redis 解决**
> 雪崩靠 TTL 打散 + 多级缓存 + 熔断限流 + 集群高可用（主从/哨兵/Cluster）综合治理。

### 5. Cache Aside 模式下，更新数据时推荐的顺序是：
A. 先删缓存，再更新数据库　✅ **B. 先更新数据库，再删除缓存**　C. 先更新数据库，再更新缓存　D. 只更新缓存，由缓存层异步刷库
> 先删缓存会被并发读把旧值回写缓存造成长期脏数据；删而不是更新，是因为删是幂等的、避免写入中间状态。

### 6. "延迟双删"策略的步骤是：
A. 删两次数据库　✅ **B. 删缓存 → 更新数据库 → 延迟一小段时间后再删一次缓存**　C. 更新缓存两次　D. 先删从库缓存再删主库缓存
> 第二次删是为了清掉"删缓存与更库之间被并发读回写的旧值"。

### 7. 要让缓存与数据库达到**近实时强一致**且对业务代码无侵入，常用：
A. 给缓存设极短 TTL　B. 业务代码里多删几次缓存　✅ **C. 用 Canal 订阅 MySQL binlog，监听变更后异步失效缓存**　D. 关闭缓存
> Canal 解析 binlog → 投递到 MQ → 消费方删缓存，延迟约百毫秒级，业务无感知。

### 8. Redis 中实现**排行榜**最合适的数据结构是：
A. List　B. Hash　C. Set　✅ **D. ZSet（有序集合）**
> ZSet 按 score 排序，`ZADD`/`ZREVRANGE` 天然适合排行榜；ZSet 还能用 score 存时间戳做延迟队列。

### 9. 关于 Redis 持久化，下列说法**错误**的是：
A. RDB 是定时快照，恢复快、文件小　B. AOF 记录写命令，`appendfsync everysec` 最多丢约 1 秒数据　C. Redis 4.0+ 支持 RDB + AOF 混合持久化　✅ **D. 只要开启 RDB 就绝对不会丢数据**
> RDB 在两次快照之间宕机会丢失这段时间的写入；要更高可靠需配合 AOF。

### 10. Redis 实现分布式锁，正确的加锁命令是：
A. `SETNX lock 1` 然后 `EXPIRE lock 30`（两条命令）　✅ **B. `SET lock {uuid} NX PX 30000`（一条原子命令）**　C. `GETSET lock 1`　D. `INCR lock`
> 拆成 SETNX + EXPIRE 两条命令时，中间宕机会导致锁无过期时间而死锁；必须用一条原子的 `SET ... NX PX`。

### 11. 分布式锁释放时，"先判断是不是自己加的锁，再删除"必须**用 Lua 脚本**，原因是：
A. Lua 执行更快　✅ **B. 判断 + 删除两步需要原子执行，否则判断后锁刚好过期被别人持有，仍会误删**　C. Redis 不支持 DEL 命令　D. Lua 能绕过过期时间
> 经典 check-then-act 竞态，必须原子化。

### 12. Redisson 的"看门狗（Watch Dog）"机制解决的问题是：
A. 防止缓存穿透　✅ **B. 业务执行时间超过锁 TTL 时自动续期，避免锁提前释放**　C. 监控 Redis 内存　D. 自动清理过期 Key
> 默认每 10s 续期一次到 30s；显式指定 leaseTime 则不启用看门狗。

### 13. RedLock（红锁）算法主要为了解决 Redis 分布式锁的哪个问题：
A. 锁的可重入　✅ **B. 主从架构下主节点宕机、锁还没同步到从节点导致锁失效**　C. 锁的公平性　D. 锁的性能
> RedLock 向多数派（≥ N/2+1）独立节点加锁，单点故障不影响。

### 14. 消息队列**不是**用来做下列哪件事的：
A. 异步处理，缩短主链路响应时间　B. 系统解耦，上下游互不依赖　C. 流量削峰，突发请求先入队　✅ **D. 替代数据库做持久化存储和复杂查询**
> MQ 是管道不是数据库，不提供随机查询/事务/索引能力。

### 15. 下列消息队列中，**原生支持事务消息（half message + 事务回查）**的是：
A. Kafka　B. RabbitMQ　✅ **C. RocketMQ**　D. 以上都不支持
> Kafka 只有"生产者事务"（保证一批消息原子写入），不是业务意义的事务消息；RabbitMQ 不支持。

### 16. 某金融支付场景要求绝对不丢、绝对不重、账户级严格顺序、还要事务消息，最合适的 MQ 是：
A. Kafka　B. RabbitMQ　✅ **C. RocketMQ**　D. Redis Stream
> RocketMQ 同步双写 + 同步刷盘保不丢、顺序消息 API 保账户级有序、事务消息保 DB 与 MQ 一致，阿里金融场景长期验证。

### 17. 日均 800 亿条埋点、峰值 300 万条/秒、可容忍 0.01% 丢失的"用户行为日志采集"，最合适的 MQ 是：
✅ **A. Kafka**　B. RabbitMQ　C. RocketMQ　D. ActiveMQ
> 只有 Kafka 的百万级 TPS + 顺序写盘机制扛得住，且与 Flink/Spark/数据湖集成最成熟；RabbitMQ 万级、RocketMQ 十万级都不够。

### 18. 关于消息"不丢失"的保障，下列说法**错误**的是：
A. 生产端应同步发送并等待 Broker 确认 ACK　B. Broker 应多副本 + 持久化（如 Kafka `min.insync.replicas ≥ 2`）　C. 消费端应处理成功后再手动提交 offset　✅ **D. 消费端一拉到消息就立即自动提交 offset，能保证不丢**
> 自动提交 offset 后若业务处理失败，消息就丢了；应"先处理成功，再提交 offset"。

### 19. RocketMQ/Kafka 一般只承诺 **at-least-once（至少一次）**，要实现"有且仅一次"的效果，应：
A. 把 MQ 配置成 exactly-once 模式即可，无需其他处理　✅ **B. at-least-once + 消费端业务幂等（如去重表 UNIQUE INDEX）**　C. 生产端只发一次，不重试　D. 消费端关闭重试
> 网络抖动、Broker 重投、ACK 丢失都会导致重复投递，必须靠业务幂等兜底。

### 20. 要保证"同一个订单的下单→支付→出餐→送达事件被**按序消费**"，正确做法是：
A. 把所有事件发到不同分区　✅ **B. 以 order_id 作为 Sharding Key，hash 到同一队列/分区，消费端单线程串行消费该队列**　C. 给每条消息加全局递增序号让消费端排序　D. 用更多消费者并行消费提速
> 同一队列内 FIFO + 单线程消费保证局部有序；不同订单 hash 到不同队列，彼此无序也不影响（业务上无依赖）。

### 21. 消息"幂等去重"用下列哪种方式**最可靠**：
A. 消费前先 `SELECT` 查业务表是否处理过，没处理过就处理　✅ **B. 去重表对业务唯一键建 `UNIQUE INDEX`，处理前先 INSERT，主键冲突即跳过**　C. 在内存里用一个 HashSet 记录处理过的消息 ID　D. 让生产者保证不重复发送
> "先查再做"在并发下两个消费者可能同时查到"未处理"仍重复执行；唯一索引把判断与占位合并为一步原子操作。内存 HashSet 重启即失效、也不跨节点。

### 22. 消费失败重试达到上限的消息会被转入：
A. 重试队列（Retry Queue）　✅ **B. 死信队列（Dead Letter Queue, DLQ）**　C. 延迟队列　D. 直接丢弃
> DLQ 里的消息需人工排查或补偿处理，且 DLQ 本身也要监控告警，避免静默堆积。

## 三、案例答题套路（必考题型，25 分）

> 这一题型一般给一段"电商秒杀 / 订单中台 / 日志平台"的架构方案，让你点评缓存设计、补全可靠性方案、做 MQ 选型对比。配套速查表：[`cheatsheets/cache-patterns.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/cheatsheets/cache-patterns.md)、[`cheatsheets/middleware-comparison.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/cheatsheets/middleware-comparison.md)；完整模拟题（含题干、参考答案、评分要点）见 [`past-papers/case-types/06-messaging-caching.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/06-messaging-caching.md)。

### 套路 1：缓存方案设计（6 步模板）

```
1. 读：Cache Aside —— 先查本地 L1（Caffeine），未命中查 Redis L2，再未命中回源 DB 并回填
2. 写：先更新 DB，再删除 Redis，本地 L1 通过 Pub/Sub 或 MQ 通知失效
3. 防穿透：布隆过滤器前置 + 不存在的 Key 缓存空值（短 TTL）
4. 防击穿：热点 Key 永不过期 + 异步刷新（或互斥锁只放一个线程回源）
5. 防雪崩：TTL = base + random(0, N s)；多级缓存兜底；Redis 异常率超阈值熔断降级
6. 最终一致兜底：Canal 监听 binlog → MQ → 各节点删缓存
```

### 套路 2：消息队列选型（必须对比 2-3 种 + 给量化理由）

```
1. 先列业务约束：吞吐量级（万/十万/百万 TPS）、可靠性（可丢 0.01% / 绝对不丢）、是否要顺序、是否要事务消息、协议/多语言、运维成本
2. 候选对比：Kafka（百万级吞吐，日志大数据）/ RabbitMQ（μs 级延迟，AMQP 路由丰富）/ RocketMQ（事务消息 + 顺序，金融电商）/ Pulsar（云原生多租户）
3. 结合约束选型 + 写出淘汰理由：「RabbitMQ 万级吞吐不到日志业务的 1/300，直接出局」这种量化句最得分
```

### 套路 3：消息可靠性"三端三性"

```
三端：生产端 / Broker / 消费端    三性：不丢 / 不重 / 顺序
- 生产端：同步发送 + 确认 ACK + 失败重试（仍失败写本地兜底表）；可用事务消息保 DB-MQ 一致
- Broker：多副本 + 持久化（min.insync.replicas≥2 / SYNC_MASTER 同步双写）+ 关键 Topic 同步刷盘 + 跨可用区
- 消费端：手动 ACK（处理成功再提交 offset）+ 业务幂等去重表（UNIQUE INDEX）+ 失败重试 + DLQ
结论句：at-least-once + 业务幂等 = exactly-once 效果
```

### 万能高分句

- "读路径采用 **Cache Aside**，写路径**先更 DB 再删缓存**，并以 **Canal 监听 binlog** 异步失效兜底，达成**最终一致**"
- "通过 **布隆过滤器 + 缓存空值** 两级防穿透，可将穿透流量对数据库的冲击降低 **99%**"
- "热点 Key **逻辑过期 + 异步刷新**（阿里双 11 实战方案），过期瞬间仍返回旧值，避免击穿打垮数据库"
- "TTL 设为 **base + random(0, 300s)** 打散，叠加 **本地 Caffeine + Redis 双级缓存** 与 **Sentinel 熔断降级**，三重防雪崩"
- "MQ 选型 **RocketMQ**：同步双写零丢失 + 顺序消息 API 保账户级有序 + 事务消息保 DB-MQ 一致，**at-least-once + 去重表 = exactly-once**"
- "热点 Key 通过 **本地缓存兜底 + Key 多副本分片**（`sku:{id}:0..N` 轮询），把单分片 QPS 从 10 万拆到 1 万"

### 常见陷阱

| ❌ | ✅ |
|---|---|
| 穿透 / 击穿 / 雪崩混为一谈 | **穿透 = 数据不存在；击穿 = 单热点 Key 过期；雪崩 = 大批 Key 一起过期** |
| Cache Aside 写"先删缓存再更 DB" | **先更 DB 再删缓存**（并发安全） |
| 缓存一致性写"更新缓存" | **删缓存**（幂等，避免中间值） |
| 互斥锁 / 分布式锁不设 TTL | **必须设过期时间**防死锁，回源失败要主动释放 |
| MQ 选型只说"选 X"不给对比 | 必须对比 **2-3 种**并写淘汰理由 + 量化数字 |
| 消息可靠性只答"Broker 多副本" | **生产端 / Broker / 消费端三端**都要答，且讲全"不丢 / 不重 / 顺序" |
| 幂等用"先查再做" | 并发下仍会重复，必须 **唯一索引去重表** |
| 顺序消息答"保证全局顺序" | 一般只保 **队列/分区内局部有序**（按业务键 hash） |

## 四、完整模拟案例题（25 分）

> ⚠️ 自主命题改编，题干场景为基于公开考点改编的虚构案例（避免版权风险），技术参数贴合真实工程实践。建议严格 25 分钟限时作答，再对照参考答案。完整版（含更细评分要点与第 2、3 道模拟题：RocketMQ 顺序消息与幂等、四种 MQ 选型对比）见 [`case-types/06-messaging-caching.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/06-messaging-caching.md)。

**【题干简述】** 某综合电商平台筹备双 11"整点秒杀"：每天 10:00/14:00/20:00 各开 1 场，每场上架 200 个 SKU、库存 100~5000 件不等、持续 5 分钟。秒杀峰值 **QPS 5 万（瞬时 8 万）**、下单接口 **P99 < 200ms**、可用性 **99.99%**、单日活跃 **8000 万**、**热点访问 80% 集中在 20 个 SKU**；MySQL 订单库一主两从，单库 QPS 上限约 8000，远低于峰值。架构师 H 的缓存方案核心决策：① **三级缓存** Caffeine 本地（L1，10 万 Key，30s）+ Redis Cluster（L2，6 主 6 从，单分片 10 万 QPS）+ MySQL（L3）；② 读用 **Cache Aside**（L1→L2→DB 逐级回源回填）；③ 写**先更 MySQL，再删 L2**，L1 通过订阅 Redis Pub/Sub 失效；④ 商品详情 TTL = 600s + random(0,300s)，热点 SKU 用"逻辑过期 + 异步刷新"；⑤ 库存用 Redis Lua 脚本原子预扣 + RocketMQ 异步落库；⑥ Sentinel 网关按用户/IP/接口三维限流。评审中遇到三类质疑：黑产用不存在的 SKU ID 刷接口（**穿透**）、整点开抢瞬间热点 Key 集中失效（**击穿**）、大量商品 TTL 同时到期（**雪崩**）。

**问 1**（6 分）：用文字时序描述本系统 **Cache Aside 的读路径与写路径**，并说明"先更 DB 再删缓存"相比"先删缓存再更 DB"的优势。
**问 2**（10 分）：针对 **缓存穿透 / 击穿 / 雪崩** 三类问题，各给出**至少 2 种**针对性解决方案，并说明每种方案在本架构中的**具体落地形式（含参数）**。
**问 3**（5 分）：热点访问 80% 集中在 20 个 Key 会把 Redis 单分片打爆（QPS 突破 10 万），给出**至少 3 条**热点 Key 治理方案。
**问 4**（4 分）："先更 DB 再删缓存"仍存在**极小并发窗口**会产生脏数据，描述该并发场景，并给出"延迟双删"或"Canal 监听 binlog"任一兜底方案的实施细节。

**【参考答案要点】**

**问 1** 读路径：client → 查 L1（Caffeine）命中即返回；未命中 → 查 L2（Redis）命中则回写 L1（TTL 30s）后返回；再未命中 → **加分布式锁防并发回源** → 查 MySQL → 回写 L2（TTL 600+random(0,300)s）→ 回写 L1 → 返回。写路径：client → `UPDATE MySQL` → `DEL` L2 Key → `publish invalidate:{key}` 到 Redis Pub/Sub → 各应用节点订阅消息后 `DEL` 本地 Caffeine L1 Key。**"先更 DB 再删缓存"的优势**：① 反向（先删缓存）方案下，并发读请求会在"删缓存→更 DB"窗口内**用旧值回写缓存**，造成长期脏数据；② 正向方案脏数据窗口仅"更 DB 完成→删缓存完成"的 ms 级，且后续任意读请求会立即修正；③ 写后失效语义清晰，无需协调读锁，工程实现简单。

**问 2**
- **穿透**：① **布隆过滤器**——启动时把全量 SKU ID 加载入 RedisBloom（误判率 0.1%，约 10MB），查询前先过滤；每日凌晨全量重建 + Canal 监听 SKU 表增量更新。② **缓存空值**——MySQL 未查到的 Key 回写 `NULL` 占位，TTL 60s + random(0,30)s。
- **击穿**：① **互斥锁**——Redis `SET lock:{sku_id} {uuid} NX PX 30000`，只放 1 个线程回源，其他线程 sleep 50ms 后重试 L2；锁必须设 TTL 防死锁，回源失败主动 `DEL` 锁。② **逻辑过期 + 异步刷新**——热点 SKU 不设物理 TTL，value 内嵌 `expire_at`；发现逻辑过期则提交异步刷新任务，旧值继续返回（最终一致）。
- **雪崩**：① **TTL 打散**——基础 600s + random(0,300s)，避免整点同时失效。② **多级缓存 + 熔断降级**——L1 本地缓存先挡住一部分流量；Sentinel 配置 Redis 异常率 > 30% 时熔断，降级为本地 + DB 直连 + 兜底降级页；Redis 集群本身 6 主 6 从 + 跨可用区，单可用区故障自动切换。

**问 3** ① **本地缓存 L1 兜住热点**：80% 流量在 20 个 Key 上 → L1 命中率可达 95%+，本地命中无 Redis 网络开销，相当于把热点流量从 Redis 卸到应用进程内存。② **热点 Key 多副本（Hot Key 拆分）**：`sku:{id}` 拆为 `sku:{id}:0..N`（N=10），客户端按随机 hash 选副本，单分片 QPS 从 10 万拆到 1 万。③ **热点探测 + 自动推送**：JD-HotKey / Sentinel HotKey 实时统计 Top-K 热点，秒级推送给应用层强制写入本地缓存（TTL 5s）。④ 读多写少可让 Redis Cluster `readonly` 由从节点分担读。

**问 4** **脏数据窗口**：T1 读请求 R 查 L2 未命中，回源读到 `V_old`；同时 T2 写请求 W 更 DB 为 `V_new` 并 `DEL` L2；T3 时 R 把 `V_old` 写回 L2 —— 此后所有读都拿到旧值直到下次失效。**Canal 兜底**：部署 Canal 监听 MySQL binlog，订阅 `sku` 表的 UPDATE/DELETE → 解析后向 RocketMQ `cache_invalidate_topic` 投递失效消息 → 各应用节点消费后 `DEL L2 Key + publish L1 失效`，实现**最终一致**且**对业务代码无侵入**，延迟约 100~500ms 可接受。（或**延迟双删**：删 L2 → 更 DB → sleep 500ms~1s → 再 `DEL` L2，第二次删清掉窗口期被回写的旧值。）

---

> 软考专题系列第 5 篇。同系列：[架构评估 ATAM](/soft-exam-topic-atam-evaluation/)、[架构风格对比](/soft-exam-topic-architecture-styles/)、[微服务与云原生](/soft-exam-topic-microservice-cloud-native/)、[数据库设计](/soft-exam-topic-database-design/)。完整清单见 [软考导览页](/soft-exam-system-architect-2026-guide/)。发现题目错误欢迎到 [仓库](https://github.com/PeterGuy326/senior-software-architect-review) 开 issue。
