---
title: 软考专题 · 微服务与云原生（选择题 15 + 案例答题套路 + 模拟题 + 论文提纲）
date: 2026-05-10T23:30:00+08:00
updated: 2026-05-10T23:30:00+08:00
cover: /img/covers/sysarch-microservice.jpg
top_img: /img/covers/sysarch-microservice.jpg
tags:
  - 软考
  - 系统架构设计师
  - 微服务
  - 云原生
  - DDD
  - 案例分析
  - 论文
categories:
  - 软考
---

> 微服务与云原生是近年系统架构设计师的"年度热点"——综合知识每年 2-4 道选择题，案例分析近 5 年多次出"单体拆微服务"大题，论文也是高频主题（论微服务架构设计及其应用）。这篇把高频选择题（带 ✅ 答案 + 解析）、案例拆分答题套路、1 道完整模拟题、论文万能提纲打包在一起。内容来自开源仓库 [`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)。回到 [软考导览页](/soft-exam-system-architect-2026-guide/) 看完整专题清单。

## 一、必背：核心理论

### 云原生四要素 + 12-Factor

云原生四要素 = **容器化（Docker）+ 微服务 + DevOps + 持续交付**。CNCF 定义还强调容器、微服务、服务网格、声明式 API。

12-Factor App 12 条：代码库、依赖、**配置（环境变量注入）**、后端服务、构建/发布/运行、进程、端口绑定、并发、易处理、开发/生产一致、日志、管理进程。

### 微服务拆分原则（DDD）

1. **单一职责** 2. **限界上下文（Bounded Context）** 3. **业务能力驱动** 4. **Database Per Service**（红线） 5. **团队自治（Two-Pizza Team）** 6. 数据独立、共享数据通过接口

> 限界上下文与微服务拆分**天然对应**。粒度并非越小越好——过小会导致网络开销、一致性复杂度、运维复杂度暴增。

### 治理组件速查（必记）

| 类别 | 代表 |
|---|---|
| 注册中心 | **Nacos** / Eureka / Consul |
| 网关 | **Spring Cloud Gateway** / Kong |
| 熔断限流 | **Sentinel** / Hystrix / Resilience4j |
| 配置中心 | **Apollo** / Nacos |
| 链路追踪 | **SkyWalking** / Jaeger / Zipkin |
| 服务网格 | **Istio** / Linkerd（+ Envoy） |
| 容器编排 | **Kubernetes** |

熔断器三态：**Closed（正常）→ Open（快速失败）→ Half-Open（试探恢复）**。Sidecar 模式：横切关注点（限流/熔断/加密/日志/追踪）下沉到独立容器，业务代码零侵入。

### 分布式事务方案

| 方案 | 一致性 | 性能 | 复杂度 | 适用 |
|---|---|---|---|---|
| 2PC / XA | 强 | 差 | 中 | 传统金融（协调者阻塞） |
| **TCC** | 强 | 中 | 高 | 核心交易（Confirm/Cancel 必须幂等） |
| Saga | 最终 | 好 | 中 | 长流程 |
| 本地消息表 | 最终 | 好 | 低 | 一般业务 |
| MQ 事务消息 | 最终 | 好 | 低 | RocketMQ |

CAP：Consistency / Availability / Partition Tolerance，分布式**必选 P**，AP（MongoDB/Cassandra）vs CP（ZooKeeper/Etcd）。BASE = **B**asically Available + **S**oft state + **E**ventually consistent。

### Kubernetes 核心对象

- **Pod**：一个或多个容器的最小调度单位
- **Deployment**：管理无状态副本｜**StatefulSet**：有状态、有序、持久存储｜**DaemonSet**：每节点一个｜**Job**：单次任务
- **Service**：稳定 IP + DNS 名，为 Pod 提供负载均衡（ClusterIP / NodePort / LoadBalancer / ExternalName）
- **Ingress**：集群入口，基于域名/路径的七层 HTTP(S) 路由 + SSL 终止

## 二、高频选择题（15 题，✅ 为正确选项）

### 1. 下列关于**微服务架构**描述错误的是：
A. 单一职责、轻量通信、独立部署　B. 每个服务拥有独立数据库　✅ **C. 服务粒度应尽可能小**　D. 去中心化治理
> 粒度并非越小越好，合理粒度围绕限界上下文。

### 2. DDD 中**限界上下文**的核心作用：
✅ **A. 划分领域模型的边界，保证同一术语在上下文内含义一致**　B. 定义数据库表　C. 描述 UI 布局　D. 生成代码

### 3. 12-Factor App 中，**配置**应：
A. 硬编码在代码中　✅ **B. 存储在环境变量中**　C. 存储在本地文件　D. 由 DBA 人工管理
> 严格区分代码与配置，做到"一次构建、到处运行"。

### 4. Kubernetes 中**Pod**的定义是：
A. 一个物理机　B. 一个容器　✅ **C. 一个或多个容器的最小调度单位**　D. 一个虚拟机

### 5. **服务网格（Service Mesh）**的典型代表是：
A. Spring Cloud　B. Dubbo　✅ **C. Istio**　D. Kafka
> Spring Cloud / Dubbo 是应用层微服务框架。

### 6. 下列关于**Sidecar 模式**描述正确的是：
✅ **A. 与主应用并肩运行的辅助容器，承担通用能力（限流、日志、追踪）**　B. 必须部署在独立节点　C. 主要用于批处理　D. 只能用于前端

### 7. 下列 K8s 资源中用于**无状态服务**的是：
✅ **A. Deployment**　B. StatefulSet　C. DaemonSet　D. Job

### 8. 下列关于**熔断器模式**描述正确的是：
✅ **A. 故障检测 + 快速失败 + 半开探测**　B. 永不恢复　C. 需要人工开启　D. 只在 TCP 层生效
> 三态 Closed → Open → Half-Open，实现 Hystrix / Resilience4j / Sentinel。

### 9. 下列关于**API Gateway**描述错误的是：
A. 统一入口、路由转发　B. 鉴权、限流、日志　✅ **C. 适合承载复杂业务逻辑**　D. 常与 Service Mesh 搭配
> 网关应轻量，业务逻辑下沉到后端服务。

### 10. 下列云原生概念描述错误的是：
A. 容器化　B. 微服务　C. DevOps 和持续交付　✅ **D. 必须用公有云**
> 私有云 / 混合云 / 公有云都可。

### 11. 下列关于**Kubernetes Service**描述正确的是：
✅ **A. 提供稳定 IP 和 DNS 名，为 Pod 提供负载均衡**　B. 管理 Pod 生命周期　C. 存储持久化数据　D. 执行定时任务

### 12. 下列描述属于**Serverless**的典型场景是：
A. 长连接游戏服务器　✅ **B. 低频触发的事件处理（如 S3 上传后触发图片压缩）**　C. 大规模机器学习训练　D. 本地开发

### 13. **DDD** 中的"战略设计"**不包括**：
A. 限界上下文　B. 上下文映射　C. 领域事件　✅ **D. 枚举类型**
> 战略设计 = 限界上下文 + 上下文映射 + 通用语言 + 领域事件；枚举是战术级。

### 14. Kubernetes 中 **Ingress** 的作用是：
✅ **A. 集群入口路由、基于域名/路径分发 HTTP(S) 流量**　B. Pod 间通信　C. 容器监控　D. 日志收集

### 15. 下列关于**微服务与 SOA** 对比描述错误的是：
A. 微服务强调"智能终端，哑管道"　B. SOA 重 ESB 集成　✅ **C. 微服务倾向共用数据库**　D. 微服务去中心化治理
> 微服务强调 Database Per Service。

> 原文 + 解析：[`exam-bank/15-microservice-cloud-native.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/exam-bank/15-microservice-cloud-native.md)

## 三、案例答题套路（25 分）

### 问题 1：识别拆分边界
1. 画**业务能力**地图（用户 / 商品 / 订单 / 支付 / 物流 / 库存）
2. 每个能力 = 一个**限界上下文** = 一个微服务
3. 数据库**私有**
4. 通信：同步 REST/gRPC + 异步 MQ

### 问题 2：给拆分方案（标准模板）
> 依据 **DDD 限界上下文**，将单体拆为：用户服务（账户/认证/权限）、商品服务（SKU/类目/库存）、订单服务（下单/查询）、支付服务（多渠道支付）、物流服务（发货/追踪）。每服务**独立数据库**，**API Gateway** 统一入口，**Nacos** 注册发现，**Sentinel** 熔断限流，**RocketMQ** 处理异步事件。

### 问题 3：分布式事务设计（模板）
> 下单 → 扣库存 → 扣积分 → 支付 → 发货：下单扣库存用 **TCC**（try 预扣 / confirm 确认 / cancel 回滚）；订单→物流通知用**本地消息表 + MQ** 保证最终一致；支付回调**幂等 + 重试**。

### 问题 4：数据一致性（模板）
- **写入一致**：主库写，**Canal 监听 binlog** 同步到 ES / 缓存
- **读一致**：**Cache Aside** —— 先删缓存再更库
- **跨服务一致**：**Saga / 本地消息表**

### 万能高分句
- "基于 **DDD 限界上下文**将单体拆分为 **10 个业务微服务 + 5 个基础服务**"
- "核心支付交易采用 **TCC** 保证强一致，辅助通知场景用**本地消息表 + MQ** 实现最终一致"
- "服务治理通过 **Nacos（注册）+ Sentinel（熔断限流）+ SkyWalking（链路追踪）**"
- "遵循 **Database Per Service**，服务间不共享库，通过**接口**交换数据"
- 留一个合理的单体（如促销引擎，事务边界强），避免"微服务一把梭"

### 常见陷阱
| ❌ | ✅ |
|---|---|
| 拆太细 / 太粗 | **限界上下文**决定粒度 |
| 共享数据库 | **Database Per Service** 是红线 |
| 不谈治理 | **熔断 / 限流 / 追踪** 必写 |
| 分布式事务一把梭 | **场景选方案**：强一致 TCC / 最终一致 MQ |
| 忽视容量 | 每个服务都应估 **QPS / 实例数** |

## 四、完整模拟案例题（25 分）

> ⚠️ 自主命题改编，建议严格 25 分钟限时作答。完整模拟题（含参考答案）见 [`case-types/05-microservice-refactor.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/05-microservice-refactor.md)。

**【题干】** 某连锁零售集团"康源百货"运营 318 家直营 + 1240 家加盟店，年营收 220 亿，员工 3.6 万。2014 年自建 ERP（Java EE 6 + EJB 3 + Oracle 11g 集中式单体，480 万行代码、3700 接口、1280 表，3 台物理机），痛点：①单次发版编译 40 分钟 + 测试 2 天 + 仅周日凌晨上线，年发布 18 次；②任一模块异常拖垮整个 ERP，2024 年 OOM 故障 7 次，单次影响 2.5 小时；③财务与供应链团队共用 1 个代码仓，合并冲突日均 8 次；④新增直播电商和社区团购，开发 6 个月仍上不了线；⑤Oracle 单库连接数常态 800 / 峰值 1500，CPU 75%+，已到扩容上限。

**问 1**（10 分）：基于 DDD 限界上下文，给出该 ERP 的微服务拆分方案（≥ 6 个服务），说明每个服务的限界上下文边界，并指出哪些模块**应保留单体**及原因。
**问 2**（8 分）：设计该系统的服务治理体系（注册、网关、配置、熔断限流、链路追踪、容器编排），给出关键组件清单并说明各自作用。
**问 3**（7 分）：针对"采购下单 → 库存预占 → 财务挂账 → 供应商通知"4 步跨服务流程，给出分布式事务方案（哪步用 TCC、哪步用本地消息表/MQ），并说明 Confirm/Cancel 为何必须幂等。

**【参考答案要点】**

**问 1** 拆分（≥6）：采购服务（采购单/比价/合同）、库存服务（多门店库存/调拨/盘点）、销售服务（POS/订单/退换）、财务服务（应收应付/总账/对账）、HR 服务（员工/薪资/排班）、供应链协同服务（供应商门户/履约/物流）、商品主数据服务（SKU/类目/价格）。每服务围绕一个限界上下文，**Database Per Service**（按业务垂直拆 Oracle），通信同步 gRPC/REST + 异步 RocketMQ。**保留单体**：财务总账 + 期末结账（事务边界强、强一致要求高、变更频率低），先包成"财务核心"单体模块，二期再评估是否拆分——避免一上来就把强事务边界硬拆成分布式事务。

**问 2** 治理体系：Nacos（服务注册发现 + 配置中心）｜Spring Cloud Gateway（统一入口 + 路由 + 鉴权 + 限流）｜Sentinel（按调用方+接口维度熔断限流降级）｜SkyWalking + ELK + Prometheus（链路追踪 + 日志 + 指标，可观测三支柱）｜Kubernetes 跨多可用区（容器编排 + 弹性扩缩 + 滚动发布）｜Istio（可选，流量灰度 + mTLS + 超时重试下沉）。作用：把"发布缓慢、故障扩散、无法弹性"三大痛点逐一对位——独立部署解决发布慢、熔断隔离解决故障扩散、HPA 解决弹性。

**问 3** 分布式事务：采购下单 → 库存预占 = **TCC**（Try 预占库存 / Confirm 确认扣减 / Cancel 释放预占）；财务挂账 = 本地消息表（采购单确认后写本地消息，定时投递到财务服务，财务消费后挂账，**最终一致**）；供应商通知 = **MQ 事件**（RocketMQ 广播，供应商门户、物流、对账多消费者订阅）。**Confirm/Cancel 必须幂等**：网络抖动 / 超时重试会导致同一 Confirm 或 Cancel 被多次调用，若不幂等会重复扣库存或重复释放，引发数据错乱；实现上用"事务状态表 + 唯一事务 ID"做幂等控制。

## 五、论文万能提纲（约 2500 字）

**典型题目**：论微服务架构设计及其应用 / 论无服务器架构（Serverless）/ 论云原生架构在 XX 中的应用 / 论基于容器的应用架构。

```
1. 背景（400 字）— 原单体瓶颈（耦合高、发布慢、无法弹性）；改造目标 QPS 5k→50k、发布日级→小时级、MTTR 小时→分钟
2. 理论（350 字）— 云原生四要素 + 12-Factor + 微服务拆分原则（DDD）+ 核心组件作用
3. 实践论述（1600 字）⭐⭐⭐⭐⭐
   (1) 服务拆分：DDD 限界上下文（订单/支付/库存/用户/商品/促销），先共性后差异、先冷数据后热数据，留单体（促销引擎）
   (2) 数据库拆分：Database Per Service + 分库分表（商品库 16 库 64 表 tenant_id 哈希），跨库查询走 ES 聚合
   (3) 通信：同步 gRPC/REST + 异步 RocketMQ
   (4) 基础设施 + 治理：K8s 跨 3 可用区 30 节点、Istio 流量治理、Sentinel 限流、SkyWalking+ELK+Prometheus 三支柱
   (5) 分布式事务：TCC（核心交易）+ 本地消息表（最终一致）+ 对账兜底
   (6) 风险与应对：服务过细链路过长 → 合并粗粒度领域服务 / 分布式事务失败 → 对账+补偿日志 / 治理成本高 → Istio+GitOps
4. 成效（250 字）— QPS 6 万、P99 178ms、可用性 99.995%、发布 30 次/日、MTTR 15 分钟；教训：别"微服务一把梭"、可观测性前置、Database Per Service 是红线
```

**摘要模板**："我于 2023 年主导了 {电商订单 / 在线教育 / SaaS} 系统的微服务化改造，担任 {架构师}。原单体 {Java 80 万行 / 月发布 1 次 / QPS 5000}，改造后 {15 个微服务 / 日发布 30 次 / QPS 6 万}。本文以该项目为背景，论述微服务+云原生的实践：基于 DDD 拆分服务、Database Per Service、TCC + 本地消息表、K8s + Istio + Prometheus + SkyWalking 治理体系、金丝雀发布。最终 QPS 提升 12 倍、可用性 99.99%、MTTR 从 2 小时降至 15 分钟。"

**加分关键词**：云原生四要素、12-Factor、限界上下文、Database Per Service、Two-Pizza Team、CAP、BASE、DDD、TCC、Saga、本地消息表、可靠消息、Cache Aside、Sidecar、BFF；业界对标：Netflix Hystrix、阿里 Dubbo、字节 Service Mesh、京东 JDOS、CNCF Landscape。

**避坑**：①"全部微服务化" → 共同数据/紧耦合场景留单体（如促销引擎）；②不谈治理 → 熔断限流链路追踪必写；③忽视分布式事务 → TCC/Saga/MQ 选型有理由；④数据库不拆 → Database Per Service 是红线；⑤无监控 → 可观测三支柱 Metrics + Logs + Traces。

> 完整理论 + 模拟论文 + 提纲：[`paper-topics/05-microservice-cloud-native.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/paper-topics/05-microservice-cloud-native.md)；范文：[`paper-samples/05-microservice-cloud-native.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/paper-samples/05-microservice-cloud-native.md)

---

> 软考专题系列第 3 篇。同系列：架构评估 ATAM、架构风格对比、数据库设计。完整清单见 [软考导览页](/soft-exam-system-architect-2026-guide/)。
