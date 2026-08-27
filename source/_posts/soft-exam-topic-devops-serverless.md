---
title: 软考专题 · DevOps 与 Serverless（CI/CD·IaC·FaaS｜选择题 18 + 案例答题套路 + 流水线模拟题 + 论文提纲）
date: 2026-05-17T22:00:00+08:00
updated: 2026-05-17T22:00:00+08:00
cover: /img/covers/sysarch-devops.jpg
top_img: /img/covers/sysarch-devops.jpg
tags:
  - 软考
  - 系统架构设计师
  - DevOps
  - Serverless
  - CI/CD
  - 论文
categories:
  - 软考
---

> DevOps 与 Serverless 是近年系统架构设计师的**新技术高频考点**——综合知识每年 1-3 道选择题（CI/CD、容器、12-Factor、FaaS、IaC、DORA），案例分析里"持续交付体系建设 / 上云 + DevOps 改造"会作为 25 分大题或子问出现，论文则是常见题（论 DevOps 在软件研发中的应用 / 论持续集成与持续交付 / 论 Serverless 架构及其应用）。这篇把必背理论、高频选择题（带 ✅ 答案 + 解析，自主命题避版权）、案例答题套路、1 道完整模拟案例题、论文万能提纲打包在一起。内容来自开源仓库 [`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)。回到 [软考导览页](/soft-exam-system-architect-2026-guide/) 看完整专题清单。

## 一、必背：核心理论

教材参考：《系统架构设计师教程（第 2 版）》第 11 章「未来信息综合技术」（云原生 / DevOps / Serverless）+ 软件工程相关章节（CI/CD、配置管理）。本篇与 [微服务与云原生](/soft-exam-topic-microservice-cloud-native/) 有交集，本文侧重 **CI/CD 流水线、基础设施即代码（IaC）、GitOps、Serverless/FaaS**。

### DevOps 定义与 CALMS 文化（必考）

DevOps = **Dev（开发）+ Ops（运维）一体化的工程文化与实践方法**，目标是缩短从代码提交到生产可用的周期、提高发布质量与可恢复性。核心理念用 **CALMS** 五字记：

| 字母 | 含义 | 落地体现 |
|---|---|---|
| **C**ulture | 文化 | 打破开发与运维之间的"部门墙"，共担质量与稳定性 |
| **A**utomation | 自动化 | 构建 / 测试 / 部署 / 基础设施全流程自动化（CI/CD + IaC） |
| **L**ean | 精益 | 小批量、快反馈、持续改进，减少在制品（WIP） |
| **M**easurement | 度量 | 用 DORA 四指标量化交付能力，数据驱动改进 |
| **S**haring | 分享 | 知识、工具、责任共享（无指责复盘、ChatOps、Runbook） |

**DevOps vs 敏捷 vs SRE**：敏捷解决"业务需求 → 开发"的快速迭代；DevOps 把敏捷延伸到"开发 → 运维 → 生产"的全链路自动化交付；SRE（Site Reliability Engineering，Google 提出）是 DevOps 的一种**具体实现/工程化落地**，强调用软件工程方法做运维（SLI/SLO/Error Budget、自动化降低 Toil）。一句话："**敏捷管想清楚要做什么，DevOps 管又快又稳地交付，SRE 管交付后稳定运行**"。

### CI / 持续交付 / 持续部署（最易混选择题）

| 概念 | 英文 | 范围 | 是否自动上生产 | 关键 |
|---|---|---|---|---|
| **持续集成 CI** | Continuous Integration | 代码频繁合并到主干，每次自动构建 + 自动化测试 | 否（不涉及部署） | 早集成早暴露、保持主干随时可构建 |
| **持续交付** | Continuous **Delivery** | 在 CI 基础上，每次变更都自动部署到类生产环境，**随时可一键发布到生产** | 否（**人工点一下**） | 制品在"可发布"状态、上线决策权在人 |
| **持续部署** | Continuous **Deployment** | 在持续交付基础上，通过所有门禁后**自动发布到生产**，无人工干预 | **是（全自动）** | 自动化测试 / 灰度 / 监控 / 回滚必须足够成熟 |

**CI/CD 流水线典型阶段（顺序题常考）**：

```
代码提交 Commit → 构建 Build → 单元测试 Unit Test → 静态扫描 SAST → 制品打包 Package(镜像入库)
  → 部署到开发/测试环境 Deploy(Dev/Test) → 集成测试 Integration Test
  → 部署到预发 Deploy(Staging) → 验收测试 / E2E
  → 部署到生产 Deploy(Prod，灰度) → 监控 Monitoring（指标/日志/告警）→ 必要时回滚
```

> 记忆：**"提交 → 构建 → 测 → 打包 → 逐环境部署 → 各级测试 → 发布 → 监控"**。安全左移：SAST（静态代码扫描）、SCA（依赖/镜像漏洞扫描，如 Trivy）尽量放在流水线早期。

### 发布（部署）策略对比（必考）

| 策略 | 机制 | 回滚速度 | 资源开销 | 适用 |
|---|---|---|---|---|
| **蓝绿部署** | 准备两套完全相同环境（蓝=旧、绿=新），新版本在绿环境就绪后**一次性切流量**；出问题切回蓝 | **极快**（切回即可，秒级） | **高**（双倍环境） | 核心交易系统、需要瞬时切换与瞬时回滚 |
| **金丝雀 / 灰度发布** | 新版本先接管 **1% → 10% → 50% → 100%** 小流量，观察指标无异常再逐步放量 | 快（缩回小流量/下掉金丝雀实例） | 较低（只多少量实例） | 大多数互联网业务的标准做法、风险可控渐进放量 |
| **滚动发布** | 逐批替换实例（K8s `RollingUpdate` 默认），新旧版本短时共存，平滑无中断 | 中（需逐批回滚上一版本） | 低（不需要双环境） | K8s 默认、对瞬时回滚要求不高的常规服务 |
| **A/B 测试** | 按用户特征/分流规则把不同版本投给不同人群，**目的是对比业务效果**（转化率等），不是单纯发布手段 | —（按实验配置切流量） | 中 | 产品功能效果验证、推荐/文案/价格策略实验 |
| 影子流量（Shadow） | 把生产真实流量**复制一份**打到新版本，但新版本响应不返回给用户 | —（不影响线上） | 中高（多一套处理算力） | 上线前用真实流量压测/验证新版本，零用户影响 |

> 易错点：**金丝雀 ≠ 滚动**。金丝雀按"流量比例"渐进放量并以观测指标作为放量门禁；滚动按"实例批次"逐批替换，本身不带流量比例门禁。蓝绿强调"两套环境瞬时切换"，回滚最快但最费资源。

### DevOps 工具链速查表（高频）

| 类别 | 代表工具 | 说明 |
|---|---|---|
| 版本控制 / 协作 | **Git** / GitLab / GitHub | 分支策略：GitFlow、主干开发（Trunk-Based）、GitHub Flow |
| CI/CD 引擎 | **Jenkins** / **GitLab CI** / **GitHub Actions** / Tekton | 编排流水线（构建-测试-部署）；Jenkins 老牌插件多，GitLab CI/GitHub Actions 配置即代码（`.yml`） |
| GitOps 持续部署 | **Argo CD** / **Flux** | 以 Git 仓库为期望状态，控制器持续把集群"对齐"到 Git 声明 |
| 制品库 | **Harbor**（容器镜像）/ **Nexus** / Artifactory | 镜像/二方包仓库，配镜像漏洞扫描（Trivy / Clair） |
| 容器 & 编排 | **Docker**（镜像/运行时）/ **Kubernetes**（编排） | 不可变基础设施的载体 |
| 配置管理 | **Ansible** / Chef / Puppet / SaltStack | 主机/中间件配置；Ansible 无 Agent、YAML、偏命令式（playbook） |
| 基础设施即代码 IaC | **Terraform** / Pulumi / CloudFormation | 声明式创建云资源（VPC、K8s 集群、RDS、负载均衡…） |
| 监控（Metrics） | **Prometheus** + **Grafana** | 时序指标采集 + 可视化 + 告警（Alertmanager） |
| 日志（Logs） | **ELK/EFK**（Elasticsearch + Logstash/Fluentd + Kibana）/ **Loki** | 集中式日志检索 |
| 链路追踪（Traces） | **SkyWalking** / **Jaeger** / Zipkin | 分布式调用链；OpenTelemetry 是统一采集标准 |
| 混沌工程 | ChaosBlade / Chaos Mesh / Gremlin | 主动注入故障验证韧性 |

### 基础设施即代码 IaC（高频）

**IaC** = 用**代码/配置文件**定义和管理基础设施（网络、虚机、容器集群、数据库、DNS…），变更走版本控制 + 评审 + 流水线，而非手工点控制台。

- **声明式 vs 命令式**：声明式（Terraform、CloudFormation、K8s manifest）描述"我要的最终状态"，工具自己算出差异并收敛；命令式（部分 Ansible playbook、Shell 脚本）描述"一步步怎么做"。**声明式更利于幂等和漂移检测**。
- **幂等性（Idempotency）**：同一份配置应用一次和应用 N 次结果一致——是 IaC 的核心属性，重复执行不会重复创建/破坏资源。
- **不可变基础设施（Immutable Infrastructure）**：服务器/实例一旦部署不再原地修改，升级=用新镜像替换旧实例（"重建而非修补"）。配合容器镜像、AMI、Packer。好处：环境一致、可重复、回滚=换回旧镜像。

| 工具 | 类型 | 定位 | 典型用途 |
|---|---|---|---|
| **Terraform** | 声明式、跨云 | 资源编排（Provisioning） | 创建/编排云资源（VPC、K8s、RDS、LB、DNS）；状态文件（state）记录现状 |
| **CloudFormation** | 声明式、AWS 专属 | 资源编排 | 仅 AWS 的资源栈（Stack）管理 |
| **Ansible** | 偏命令式（也支持声明式）、无 Agent | 配置管理（Configuration） | 在已存在的主机上装软件、改配置、部署应用（push 模式、SSH） |
| Pulumi | 声明式、用通用语言 | 资源编排 | 用 TS/Python/Go 写 IaC |

> 一句话区分：**Terraform 负责"把机器/集群建出来"，Ansible 负责"把建好的机器配置好"**，两者常配合使用。

### GitOps（高频新词）

**GitOps** = 以 **Git 仓库为"单一可信源（Single Source of Truth）"**，系统的期望状态全部声明式地写在 Git 里；集群里跑一个控制器（**Argo CD / Flux**）持续比对"Git 中的期望状态"与"集群实际状态"，发现漂移就自动同步（拉取式 Pull 部署）。优点：**审计可追溯（每次变更=一次 commit/PR）、回滚=git revert、防配置漂移、权限收敛在 Git**。GitOps 是"声明式 + 版本化 + 自动协调"三件套，常被视为 K8s 时代的最佳部署实践。

### 容器与镜像（呼应云原生）

- **Dockerfile 分层**：每条指令生成一层只读层，层可缓存、可复用——把不常变的（基础镜像、依赖安装）放前面、常变的（应用代码）放后面，能加速构建、减小拉取量。运行时在镜像层之上加一个可写层。
- **镜像仓库**：Harbor / Docker Registry / 云厂商 ACR，存版本化镜像，配漏洞扫描、签名（Cosign）、复制策略。
- **不可变基础设施**：上线新版本=构建新镜像 → 推仓库 → 用新镜像滚动/蓝绿替换旧 Pod，不在运行中的容器里改文件。

### 12-Factor App（十二要素，简表）

| # | 要素 | 要点 |
|---|---|---|
| 1 | 基准代码 Codebase | 一份代码库，多份部署 |
| 2 | 依赖 Dependencies | 显式声明并隔离依赖 |
| 3 | **配置 Config** | **配置存于环境变量**，与代码严格分离 |
| 4 | 后端服务 Backing Services | 数据库/缓存/MQ 当作可替换的附加资源 |
| 5 | 构建/发布/运行 Build/Release/Run | 三阶段严格分离，发布不可变、可回滚 |
| 6 | 进程 Processes | 应用是无状态进程，状态外置 |
| 7 | 端口绑定 Port Binding | 通过端口对外提供服务，自包含 |
| 8 | 并发 Concurrency | 通过进程模型水平扩展 |
| 9 | 易处理 Disposability | 快速启动、优雅终止 |
| 10 | 开发/生产等价 Dev/Prod Parity | 各环境尽量一致（差距小） |
| 11 | 日志 Logs | 日志作为事件流写到 stdout，由平台收集 |
| 12 | 管理进程 Admin Processes | 一次性管理任务（迁移脚本）以同环境运行 |

### Serverless / FaaS（高频新考点）

**Serverless（无服务器）** = 开发者**无需关心/管理服务器**，云厂商按"实际使用量"计费、自动弹性伸缩、按事件触发执行。注意"无服务器"是指**对使用者透明**，不是真没有服务器。

**FaaS（Function as a Service，函数即服务）** 是 Serverless 的核心形态：把一段函数代码部署上去，由**事件触发**（对象存储上传、消息到达、HTTP 请求、定时器、IoT 数据等）按需运行，运行完即释放。代表产品：**AWS Lambda、阿里云函数计算 FC、腾讯云 SCF、Azure Functions、Google Cloud Functions**；自建/开源方案：**Knative**（基于 K8s）、**OpenFaaS**、Kubeless。配套 **BaaS（Backend as a Service）**：DynamoDB、Firebase、对象存储、托管认证等"后端能力即服务"。

| 特征 | 说明 |
|---|---|
| 按调用计费 | 毫秒级计费（执行时长 × 内存），不调用不花钱（vs 长期常驻的 Pod/VM） |
| 自动弹性 | 0 → N 自动扩容，突发流量自动撑住，闲时缩到 0 |
| 事件驱动 | 由触发器拉起：OSS/S3、MQ/Kafka、API Gateway、Cron、IoT |
| 免运维 | 无需管理 OS、扩缩容、补丁、容量规划 |
| 无状态 | 实例随时被回收，状态必须外置（Redis / 表存储 / 对象存储） |

**适用场景**：低频/长尾任务（每天调用几百~几万次养一台机器不划算）、突发流量（秒杀活动、营销）、事件处理（图片上传后生成缩略图/打水印/AI 打标）、定时任务（对账、报表）、Webhook/回调（支付回调、第三方推送）、胶水/编排逻辑、IoT 数据预处理、边缘函数。

**不适用 / 慎用**：长连接服务（WebSocket 游戏服、IM 长连）、长任务（执行时长一般上限 ~15 分钟）、强状态/有状态计算、对延迟极敏感且无法接受冷启动的接口、超高 QPS 稳定负载（持续满负载时 FaaS 反而比常驻实例贵）、需要特殊硬件/内核能力的负载。

**冷启动（Cold Start）问题**：函数实例不存在时（首次调用、扩容、长时间无调用被回收后）需要"拉起容器 + 加载运行时 + 初始化代码"，会引入额外延迟（几十毫秒到数秒，Java/.NET 较重）。缓解手段：**预留/预热实例（Provisioned Concurrency）**、精简依赖包、使用轻量运行时 / GraalVM AOT 原生镜像、定时探活保活、把初始化代码移出处理函数（复用执行环境）。

### 度量：DORA 四大指标（必考）

| 指标 | 含义 | 方向 | Elite（精英级）参考 |
|---|---|---|---|
| **部署频率** Deployment Frequency | 多久能成功上线一次 | 越高越好 | 按需部署（日多次） |
| **变更前置时间** Lead Time for Changes | 代码 commit 到上生产的时间 | 越短越好 | < 1 天（甚至 < 1 小时） |
| **变更失败率** Change Failure Rate | 上线后导致故障/需回滚的比例 | 越低越好 | 0% ~ 15%（通常 < 5%） |
| **服务恢复时间** MTTR（Time to Restore Service） | 故障发生到恢复的时间 | 越短越好 | < 1 小时（甚至分钟级） |

> 前两个衡量**交付速度（吞吐）**，后两个衡量**交付质量/稳定性**。DORA 把团队分 Low / Medium / High / **Elite** 四档；"度量驱动改进"是 DevOps 落地的关键，论文里必写。

## 二、高频选择题（18 题，✅ 为正确选项）

### 1. 关于 **DevOps** 的描述，错误的是：
A. 是打通开发与运维的工程文化与实践　B. 强调自动化（构建 / 测试 / 部署 / 基础设施）　C. 用 DORA 等指标度量交付能力　✅ **D. 本质上就是一套自动化工具的组合**
> DevOps 是**文化 + 流程 + 工具**三位一体，工具只是承载，把它等同于"装了 Jenkins/K8s"是典型误区。

### 2. DevOps 的 **CALMS** 五要素**不包括**：
A. Culture（文化）　B. Automation（自动化）　✅ **C. Containerization（容器化）**　D. Measurement（度量）
> CALMS = Culture / Automation / **L**ean（精益）/ Measurement / **S**haring（分享）；容器化是实现手段，不在 CALMS 字面里。

### 3. 关于**持续集成（CI）、持续交付、持续部署**的区别，描述**正确**的是：
A. 三者完全等价　B. 持续交付一定会自动发布到生产　✅ **C. 持续部署在持续交付基础上去掉了发布前的人工审批，自动上生产**　D. 持续集成包含自动部署到生产
> CI 只管"频繁合并 + 自动构建/测试"；持续交付让制品"随时可一键发布"但**上线需人工点一下**；持续部署"全自动上生产"。

### 4. 典型 CI/CD 流水线，下列阶段顺序**正确**的是：
A. 构建 → 提交 → 单元测试 → 部署 → 打包　B. 提交 → 单元测试 → 构建 → 打包 → 部署　✅ **C. 提交 → 构建 → 单元测试 → 打包(制品) → 部署到环境 → 集成/验收测试 → 发布 → 监控**　D. 提交 → 部署 → 构建 → 测试 → 监控
> 先构建出可执行物，再跑单测，通过后打包成制品/镜像入库，然后逐环境部署并做集成/验收测试，最后发布到生产并监控。

### 5. 关于**蓝绿部署**的描述，**正确**的是：
✅ **A. 准备两套相同环境，新版本就绪后整体切换流量，出问题可瞬时切回旧环境**　B. 按 1%→10%→100% 逐步放量　C. 逐批替换实例，新旧短时共存　D. 按用户特征分流对比业务效果
> 选 B 是金丝雀、选 C 是滚动、选 D 是 A/B 测试。蓝绿的代价是需要双倍环境资源，换来的是最快回滚。

### 6. 关于**金丝雀（灰度）发布**的描述，**错误**的是：
A. 新版本先接管小比例流量　B. 以监控指标作为是否继续放量的门禁　C. 出问题只需缩回小流量或下掉金丝雀实例　✅ **D. 必须准备两套完全相同的环境同时运行**
> "两套完全相同环境整体切换"是蓝绿；金丝雀只需多出少量金丝雀实例，按流量比例渐进放量。

### 7. 下列工具中，定位为 **GitOps 持续部署控制器**（以 Git 为期望状态、持续协调 K8s 集群）的是：
A. Jenkins　B. Ansible　✅ **C. Argo CD**　D. Prometheus
> Jenkins 是 CI/CD 流水线引擎，Ansible 是配置管理，Prometheus 是监控；Argo CD（和 Flux）是 GitOps 工具。

### 8. 关于**基础设施即代码（IaC）**，描述**错误**的是：
A. 用代码/配置描述基础设施并纳入版本控制　B. 声明式 IaC 描述"期望的最终状态"由工具收敛　C. 幂等性意味着同一份配置应用一次或多次结果一致　✅ **D. 引入 IaC 后基础设施变更必须手工在控制台操作以保证安全**
> IaC 的目的恰恰是让基础设施变更走代码评审 + 流水线、可重复、可审计，**取代手工点控制台**。

### 9. 关于 **Terraform 与 Ansible** 的对比，描述**正确**的是：
✅ **A. Terraform 偏向声明式的资源编排（建出 VPC/集群/数据库），Ansible 偏向在已有主机上做配置管理**　B. 两者都只能管理 AWS 资源　C. Ansible 必须在每台被管机器上常驻 Agent　D. Terraform 是命令式脚本，无法跨云
> Terraform 跨云、声明式、用 state 记录现状；Ansible 无 Agent（SSH push）、playbook 偏命令式，常用来装软件改配置。两者常配合："先 Terraform 建，再 Ansible 配"。

### 10. 关于 **GitOps** 的描述，**错误**的是：
A. 以 Git 仓库作为系统期望状态的单一可信源　B. 通过 Argo CD / Flux 持续把集群对齐到 Git 声明　C. 回滚可以通过 git revert 实现　✅ **D. 强调由运维人员直接登录服务器手工修改配置以提高效率**
> 直接登服务器手改正是 GitOps 要消灭的"配置漂移"来源；GitOps = 声明式 + 版本化 + 自动协调。

### 11. 关于 **Docker 镜像分层**，描述**正确**的是：
✅ **A. Dockerfile 每条指令生成一层只读层，可被缓存复用，应把不常变的内容放前面**　B. 镜像只有一层，无法复用　C. 容器运行时不能在镜像之上写任何数据　D. 把应用代码放在最前面能加速构建
> 不常变的（基础镜像、依赖安装）放前面、常变的（应用代码）放后面，能最大化缓存命中、减小拉取量；运行时会在镜像层上叠一个可写层。

### 12. 关于**不可变基础设施（Immutable Infrastructure）**，描述**正确**的是：
A. 部署后经常登录服务器原地打补丁　✅ **B. 实例一旦部署不再原地修改，升级即用新镜像替换旧实例**　C. 只适用于物理机　D. 与容器、镜像无关
> "重建而非修补"——升级=构建新镜像→替换旧实例，回滚=换回旧镜像，保证环境一致与可重复。

### 13. 按 **12-Factor App**，应用的**配置（如数据库地址、密钥）**应当：
A. 硬编码在代码里　✅ **B. 存放在环境变量中，与代码严格分离**　C. 写死在 Docker 镜像里　D. 由 DBA 在生产机上手工维护
> "配置走环境变量"是 12-Factor 第 3 条，保证"一次构建、多环境运行"。

### 14. 关于 **Serverless / FaaS** 的特征，描述**错误**的是：
A. 按实际调用量计费、不调用基本不花钱　B. 自动弹性伸缩（0→N）　C. 由事件触发执行（对象存储 / MQ / HTTP / 定时器）　✅ **D. 适合承载需要长连接、长时间运行的有状态服务**
> 长连接（IM/游戏）、长任务（一般 >15 分钟超限）、强状态都不适合 FaaS；FaaS 实例无状态、随时被回收。

### 15. 下列场景中，**最适合**用 Serverless（FaaS）实现的是：
A. 在线对战游戏的长连接网关　✅ **B. 用户上传图片到对象存储后自动生成缩略图并打水印**　C. 7×24 持续满负载的核心交易主链路　D. 需要本地 GPU 的大模型训练
> 事件驱动 + 短时 + 触发频率不稳定的"图片处理"是 FaaS 经典场景；A 是长连接、C 是高 QPS 稳定负载（常驻更划算）、D 需特殊硬件且耗时长。

### 16. 关于 FaaS 的**冷启动（Cold Start）**，描述**错误**的是：
A. 函数实例不存在时需要拉起容器、加载运行时、初始化代码，引入额外延迟　B. 长时间无调用、扩容、首次调用时容易触发　C. 可用预留/预热实例、精简依赖、轻量运行时（如 GraalVM 原生镜像）缓解　✅ **D. 冷启动只影响计费金额，不影响请求延迟**
> 冷启动直接拉高首个/扩容请求的响应延迟（Java/.NET 可达秒级），对延迟敏感接口需重点优化。

### 17. 下列关于 **Knative** 的描述，**正确**的是：
✅ **A. 是构建在 Kubernetes 之上的 Serverless 框架，支持按请求自动扩缩（含缩容到 0）和事件驱动**　B. 是一个关系型数据库　C. 是 CI 流水线引擎，用于编译代码　D. 只能跑在 AWS 上
> Knative（Serving + Eventing）让你在自己的 K8s 集群上获得"按需扩缩、缩容到 0、事件驱动"的 Serverless 体验，避免厂商绑定。

### 18. 关于 **DORA 四大指标**，描述**错误**的是：
A. 包括部署频率、变更前置时间、变更失败率、服务恢复时间　B. 部署频率和变更前置时间衡量交付速度　C. 变更失败率和 MTTR 衡量交付质量/稳定性　✅ **D. 团队应只优化部署频率，其余三个指标不重要**
> 四个指标要平衡看——只追部署频率不顾失败率和 MTTR 会"快而脆"；DORA 据此把团队分 Low/Medium/High/Elite。

> 原文 + 解析：[`exam-bank/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/exam-bank) 中"未来信息综合技术 / 软件工程（配置管理与 CI/CD）"相关题、[`knowledge-index/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/knowledge-index) 新技术索引。

## 三、案例答题套路（持续交付 / 上云 + DevOps 改造，25 分）

> 这类题给一段"手工部署慢、环境不一致、发布窗口窄、回滚难、上云改造"的场景（企业系统 DevOps 转型、单体上 K8s、持续交付体系建设），按下面 6 步铺答案，每点一句结论 + 一句理由/参数。

### ① 现状痛点（先把"为什么要改"说清）
- 部署**手工**：打包靠人工敲命令、上线靠 SSH 拷文件，单次发版 X 小时；
- 环境**不一致**："在我机器上是好的"——开发/测试/预发/生产配置漂移；
- 发布**窗口窄**：只能周末凌晨上线、年发布次数个位数（部署频率极低，Lead Time 以周/月计）；
- **回滚难**：出故障靠人工回退，MTTR 数小时；
- 缺**可观测**：没有统一指标/日志/链路，故障靠用户投诉才发现；
- 开发与运维**对立**：出问题互相甩锅，无统一度量。
- 改造目标量化：**部署频率 月→日(多次)、Lead Time 周→天、变更失败率 25%→<5%、MTTR 小时→分钟**。

### ② CI/CD 流水线设计（DevOps 的核心载体）
- 代码：GitLab/GitHub + 分支策略（GitFlow 或主干开发 + 短分支）；
- 流水线 8 段：**Commit → Build → 单元测试 → SAST(SonarQube)/SCA(Trivy) → 制品打包(镜像入 Harbor) → 部署 Dev/Test → 集成测试 → 部署 Staging → E2E/验收 → 部署 Prod(灰度) → 监控**；
- 质量门禁：单测覆盖率 ≥ 80%、高危漏洞 0、关键接口冒烟通过，否则**卡住不让发**；
- 量化："流水线全自动，平均执行 ~8 分钟，自动拦截 ~70% 缺陷在上线前"。

### ③ 环境与基础设施（容器化 + K8s + IaC + 不可变）
- **容器化**：服务打成 Docker 镜像，"一次构建、各环境同一镜像"消除环境漂移；
- **编排**：跑在 **Kubernetes**（跨多可用区），HPA 自动扩缩、滚动更新无中断；
- **IaC**：用 **Terraform** 管理云资源（VPC/K8s 集群/RDS/LB/DNS），用 **Ansible** 做主机/中间件配置，基础设施变更走代码评审 + 流水线，**回滚 < 5 分钟**；
- **GitOps**：用 **Argo CD** 把"Git 中的 K8s 声明"持续同步到集群，部署可审计、git revert 即回滚；
- **不可变基础设施**：升级=换新镜像，绝不登容器手改。

### ④ 自动化测试分层 + 发布策略
- 测试金字塔：**单元测试（多、快）→ 接口/集成测试（中）→ UI/E2E（少、慢）**，外加性能压测、安全扫描；
- 发布策略：**金丝雀（1%→10%→50%→100%，以指标为门禁）** 用于大多数服务，**蓝绿** 用于核心交易（瞬时回滚），**滚动** 用于常规无状态服务；配 **特性开关（Feature Flag/Toggle）**——代码先合并但功能默认关闭，发布与上线解耦，出问题关开关而非回滚代码；
- **一键回滚**：保留上一版本镜像 + 声明，3 分钟回到上一版本；
- 配 **混沌工程（ChaosBlade / Chaos Mesh）** 定期注入故障验证韧性。

### ⑤ 可观测性三支柱（Metrics / Logs / Traces）
- **指标 Metrics**：Prometheus + Grafana（QPS、延迟 P99、错误率、饱和度——Google 黄金四指标 + USE/RED 方法），Alertmanager 告警；
- **日志 Logs**：ELK/EFK 或 Loki 集中采集检索，结构化日志 + TraceID 关联；
- **链路 Traces**：SkyWalking / Jaeger（+ OpenTelemetry 统一采集），定位跨服务慢调用；
- 配 SLO/Error Budget（呼应 SRE）、统一告警值班（On-Call）+ 无指责复盘（Postmortem）。

### ⑥ 度量与持续改进（DORA 四指标）
- 建 **DORA 看板**：部署频率、变更前置时间、变更失败率、MTTR，目标对标 **Elite 级**；
- 数据驱动：每周复盘四指标，定位瓶颈（如 Lead Time 卡在评审 → 拆小批量；失败率高 → 强制灰度 + 加测试）；
- 文化：CALMS 落地——高层背书 + 全员培训 + 用例 Owner 制 + 知识/工具共享。

### 万能高分句
- "遵循 **CALMS** 理念，从'手工部署月级发布'转向'全自动 CI/CD 日级多次发布'，打通 Dev-Ops 文化墙。"
- "流水线 8 段全自动化，配 SAST/SCA 安全左移与覆盖率门禁，**上线前自动拦截约 70% 缺陷**。"
- "基础设施用 **Terraform IaC + Argo CD GitOps** 声明式管理，所有变更可审计、git revert 即回滚，基础设施回滚 < 5 分钟。"
- "采用 **金丝雀发布（1%→10%→50%→100%）+ 特性开关** 把'发布'与'上线'解耦，核心交易用蓝绿保证瞬时回滚。"
- "可观测三支柱：**Prometheus(Metrics) + ELK(Logs) + SkyWalking(Traces)**，配 SLO/Error Budget 与无指责复盘。"
- "用 **DORA 四指标**度量并对标 Elite 级——部署频率 月→日 50 次、Lead Time 2 周→<1 天、变更失败率 25%→3%、MTTR 4 小时→12 分钟。"
- "非核心、事件驱动、流量突发的长尾任务（图片处理 / 定时对账 / Webhook）迁到 **Serverless（FaaS）**，资源成本降约 40%。"

### 常见陷阱
| ❌ | ✅ |
|---|---|
| 把 DevOps 写成"装了 Jenkins/K8s" | **文化 + 流程 + 工具**三位一体，CALMS 落地 |
| 流水线只写"构建-部署" | 8 段齐全：构建/单测/SAST/SCA/打包/逐环境部署/集成 E2E/灰度/监控 |
| 不谈 IaC | **Terraform/Ansible** 是基础，环境一致性 + 可重复 + 回滚靠它 |
| 不谈可观测 | **Metrics/Logs/Traces** 三支柱必写，配告警与 SLO |
| 发布一刀切 | **金丝雀/蓝绿/滚动**按场景选 + 特性开关 + 一键回滚 |
| 无量化指标 | **DORA 四指标**必写且要前后对比 |
| Serverless 一把梭 | 冷启动/有状态/长任务/高 QPS 稳定负载场景不适合 FaaS |
| 不估容量 | 服务实例数 / HPA 阈值 / 流水线并发 / 函数并发都应量化 |

## 四、完整模拟案例题（25 分）

> ⚠️ 自主命题改编（基于公开考点与历年真题方向，避免版权风险），建议严格 25 分钟限时作答。完整套路与更多模拟题见仓库 [`past-papers/case-types/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/case-types) 的 DevOps/上云改造题型。

### 模拟题 · 某 SaaS 企业「从月度手工发布到日级自动化发布」DevOps 改造

**【题干简述】** 某企业级 SaaS 服务商"云策科技"，主力产品是 HR + 财务一体化云平台，服务 2300 家客户、日活 18 万、研发 90 人 + 运维 8 人。现状（2022 年前）：①后端是 Spring Boot 单体 + 少量服务，部署靠运维登录虚机执行脚本拷 jar 包，单次发版约 3 小时，**只能每月最后一个周六凌晨上线**，2022 年全年发布 11 次；②开发本地 / 测试 / 预发 / 生产配置各不相同，"本地能跑线上挂"故障 2022 年发生 14 次；③上线后出故障靠运维手工回退 jar 包，**平均恢复 3.5 小时**；④没有统一监控，故障常由客户工单发现；⑤每天定时跑的"客户用量对账"和"月末账单生成"是用一台常驻 8C16G 虚机跑的，平时利用率不到 10%；⑥财务上报模块每月初被第三方系统大量回调，峰值是平时的 30 倍，常驻容量扛不住、扩容又来不及。公司决定启动 DevOps 改造：上 **Kubernetes**，建 **GitLab CI** 流水线，用 **Argo CD** 做 GitOps 部署，并评估把部分任务迁到**阿里云函数计算（FaaS）**。

**问 1**（8 分）：为该公司设计 CI/CD 流水线，给出从代码提交到生产发布的分阶段方案（≥ 7 个阶段），说明每个阶段做什么、设置哪些质量门禁。

**问 2**（6 分）：针对"上线后出故障靠手工回退、恢复慢"的痛点，给出发布策略与回滚方案（结合金丝雀 / 蓝绿 / 滚动、特性开关、一键回滚），并说明各自适用范围。

**问 3**（6 分）：用 IaC 与容器化解决"环境不一致"问题，给出工具选型（如 Terraform / Ansible / Docker / K8s）与各自职责，并解释"不可变基础设施"在这里的作用。

**问 4**（5 分）：哪些工作负载适合迁到 Serverless（FaaS）？请结合题干的"用量对账 / 月末账单 / 财务回调"分析，并指出哪些**不**适合迁、为什么；说明如何应对 FaaS 的冷启动与可观测问题。

**【参考答案要点】**

**问 1** CI/CD 流水线（≥7 段）：① **代码提交（Commit）**——push 触发流水线，分支策略主干开发 + 短分支，MR 必须 2 人 Review；② **构建（Build）**——Maven 编译打包；③ **单元测试**——门禁：覆盖率 ≥ 80%，失败即终止；④ **静态扫描 SAST + 依赖/镜像扫描 SCA**——SonarQube 代码质量门禁（无新增严重坏味道）、Trivy 扫描镜像（高危漏洞 0）；⑤ **制品打包**——构建 Docker 镜像并推送 Harbor，打 Git SHA 版本标签；⑥ **部署到测试环境 + 集成测试**——Argo CD 同步到 test 命名空间，跑接口自动化；⑦ **部署到预发 + E2E/验收测试**——跑端到端冒烟与回归；⑧ **部署到生产（金丝雀灰度）**——人工审批（持续交付）后金丝雀放量；⑨ **监控**——Prometheus/Grafana 看灰度期间错误率与延迟，异常自动告警/回滚。门禁汇总：覆盖率 80%、严重漏洞 0、冒烟通过、灰度指标达标——任一不过卡住不发。量化目标：流水线全自动 ~8 分钟，部署频率从月 1 次提到日多次。

**问 2** 发布策略 + 回滚：① **金丝雀（灰度）发布**——大多数业务服务用，新版本接管 1%→10%→50%→100% 流量，每一档观察 P99 延迟/错误率/业务指标，达标才放量，出问题缩回小流量或下掉金丝雀实例（适用：迭代频繁、风险可控的常规服务）；② **蓝绿部署**——核心的财务/账单计算服务用，绿环境验证通过后整体切流量，出问题秒级切回蓝环境（适用：要求瞬时回滚、不能容忍灰度期间脏数据的关键链路；代价是双倍环境资源）；③ **滚动发布**——无状态的展示类/查询类服务用 K8s 默认 RollingUpdate，逐批替换无中断（代价小但回滚需逐批回退）；④ **特性开关（Feature Flag）**——大功能代码先合并但默认关闭，发布与上线解耦，灰度放开给部分租户，出问题关开关而非回滚代码；⑤ **一键回滚**——Argo CD 回滚到上一个 Git 版本（声明 + 镜像都在 Git/Harbor），3 分钟内恢复。整体把 MTTR 从 3.5 小时降到分钟级。

**问 3** IaC + 容器化解决环境不一致：① **Docker 容器化**——所有服务打成镜像，"一次构建、各环境同一镜像"，从根上消除"jar 包 + 各环境不同配置文件"导致的漂移；配置按 12-Factor 走环境变量/ConfigMap/Secret 注入；② **Kubernetes**——统一编排，dev/test/staging/prod 用同一套 manifest 模板（Helm/Kustomize 区分参数），跨可用区部署 + HPA 弹性；③ **Terraform**——声明式管理云资源：VPC、K8s 集群、RDS、SLB、DNS、对象存储，状态文件记录现状，变更走 MR + plan 评审，可重复创建一套等价环境，回滚 < 5 分钟；④ **Ansible**——对少量遗留虚机/中间件做配置管理（无 Agent、SSH push、playbook）；⑤ **不可变基础设施**的作用——服务器/容器一旦部署不再原地改，升级=用新镜像替换旧实例、回滚=换回旧镜像，保证"任意时刻任意环境的实例都来自同一份可追溯的镜像"，彻底告别"运维手改后没人知道改了啥"。

**问 4** Serverless（FaaS）适配分析：**适合迁**——① "客户用量对账"：每天定时跑（Cron 触发）、短时、平时利用率 < 10%，用常驻 8C16G 虚机浪费，迁到 FaaS 后**不跑不计费**，按执行时长付费，成本大幅下降；② "月末账单生成"：月初集中跑、平时空闲，弹性需求强、时段性明显，适合 FaaS 按需弹起（注意单函数执行时长上限，账单大可拆分/分片并行执行多个函数）；③ "财务回调"：HTTP/MQ 事件触发、峰值是平时 30 倍，FaaS 自动扩容到大量实例瞬时撑住突发，闲时缩回，避免按峰值常备容量。**不适合迁**——主产品的 HR/财务在线业务主链路（持续稳定负载、对延迟敏感、有会话状态、需要复杂依赖与连接池），常驻 K8s Pod 更划算也更可控；任何长连接（如实时协作）和超过执行时长上限的批处理也不宜。**冷启动应对**——核心回调函数配预留实例（Provisioned Concurrency）常驻 N 个、精简依赖包、把 DB 连接等初始化移出处理函数复用执行环境、必要时定时探活保活；Java 较重可考虑 GraalVM 原生镜像把启动从秒级降到百毫秒级。**可观测应对**——函数日志统一汇聚到日志服务、用 OpenTelemetry/云厂商 APM 做链路追踪、监控调用次数/延迟/失败率/冷启动率并配预算告警；并抽象一层运行时（或保留 Knative/OpenFaaS 备选）降低 Vendor Lock-In 风险。预期：迁移后这部分资源成本降约 40%~55%，突发流量自动扛住。

## 五、论文万能提纲（约 2500 字）

**典型题目**：论 DevOps 在软件研发中的应用 / 论持续集成与持续交付（CI/CD）/ 论无服务器架构（Serverless / FaaS）及其应用 / 论基础设施即代码（IaC）在系统运维中的应用。

```
1. 背景（350 字）— 原状态：发布周期月级、Lead Time 以周计、变更失败率高（25%）、MTTR 小时级、
   开发与运维对立、环境不一致故障多、无可观测；改造目标量化：部署频率月→日(多次)、Lead Time 周→天、
   失败率 25%→<5%、MTTR 小时→分钟；团队规模（研发 90 + 运维 8 + 平台 10）、关键质量属性（交付速度/变更稳定性/可观测性/可恢复性/成本效率）

2. 理论（350 字）— DevOps 与 CALMS（Culture/Automation/Lean/Measurement/Sharing）+ DevOps 与敏捷/SRE 的关系
   + CI vs 持续交付 vs 持续部署 + CI/CD 流水线 8 段 + 部署策略（蓝绿/金丝雀/滚动/A-B/影子）
   + IaC（声明式/幂等/不可变基础设施）+ GitOps（Argo CD/Flux）+ 12-Factor（配置走环境变量）
   + Serverless/FaaS（按调用计费/自动弹性/事件驱动/无状态，冷启动局限）+ DORA 四指标与 Elite 级

3. 实践论述（约 1600 字）⭐⭐⭐⭐⭐ —— 六要点：
   (1) CI/CD 流水线建设：GitLab + GitLab CI/Jenkins + Argo CD GitOps + Harbor 制品库；
       8 段全自动（Commit→Build→UnitTest→SAST/SCA→Package→Deploy(各环境)→集成/E2E→Deploy(Prod 灰度)→监控）；
       质量门禁（覆盖率 80%、高危漏洞 0、冒烟通过）；流水线平均 8 分钟、上线前拦截约 70% 缺陷
   (2) 容器化 + Kubernetes：服务打镜像"一次构建多环境运行"消除漂移；K8s 跨可用区 + HPA 弹性 + 滚动更新；
       配置按 12-Factor 走 ConfigMap/Secret/环境变量
   (3) 基础设施即代码 IaC：Terraform 管云资源（VPC/K8s/RDS/LB/DNS，state 记录现状）+ Ansible 配主机；
       不可变基础设施（重建而非修补）；基础设施变更走 MR 评审 + 流水线，回滚 < 5 分钟
   (4) 自动化测试分层：测试金字塔（单元多、接口中、UI/E2E 少）+ 性能压测 + 安全扫描（SAST/DAST/SCA）；
       质量门禁卡在流水线；用例 Owner 制 + 每周修复失效用例
   (5) 发布策略 + 特性开关：金丝雀（1%→10%→50%→100%，以指标为门禁）为主、蓝绿用于核心交易（瞬时回滚）、
       滚动用于常规无状态服务；特性开关把"发布"与"上线"解耦；Argo CD 一键回滚到上一 Git 版本；ChaosBlade 定期混沌演练
   (6) 可观测三支柱 + 度量改进：Prometheus+Grafana(Metrics) + ELK/Loki(Logs) + SkyWalking/Jaeger(Traces, OpenTelemetry 采集)；
       SLO/Error Budget + 无指责复盘 + DORA 看板；非核心事件驱动长尾任务（图片处理/定时对账/Webhook）迁 Serverless(FaaS)，资源成本降约 40%

4. 权衡与教训（约 250 字）—
   ① 流水线/平台维护成本高 → 平台工程（Platform Engineering）建内部开发者平台、模板化、GitOps 收敛
   ② Serverless 冷启动 vs 弹性收益的取舍 → 核心场景用预留实例 + GraalVM；只把低频/突发/事件驱动场景上 FaaS，不一把梭
   ③ Vendor Lock-In → 抽象运行时、保留 Knative/OpenFaaS 备选
   ④ 文化阻力 → 高层背书 + 全员培训 + DORA 看板让数据说话 + 无指责复盘
   ⑤ 安全与合规 → 安全左移（SAST/SCA/镜像签名）+ 流水线即审计 + 最小权限

5. 成效（约 200 字）— 部署频率 月 1 次→日 50 次、Lead Time 2 周→<1 天、变更失败率 25%→3%、MTTR 3.5h→12 分钟（DORA 达 Elite 级）；
   环境不一致故障 14 次/年→0；非核心任务迁 FaaS 后资源成本降约 40%、突发流量自动扛住；
   教训：DevOps 是文化+流程+工具三位一体、度量驱动改进、可观测是自动化的前提、Serverless 不是银弹
```

**摘要模板**："我于 2023 年牵头了 {SaaS HR 财务平台 / 电商交易 / 在线教育} 系统的 DevOps 转型，担任 {DevOps 平台架构师}。原状态 {单体 + 手工部署 / 月发布 1 次 / Lead Time 2 周 / 变更失败率 25% / MTTR 3.5 小时 / 环境不一致故障 14 次/年}。本文以该项目为背景，论述 DevOps 与持续交付体系建设：基于 CALMS 理念，建设 GitLab CI + Argo CD(GitOps) + Harbor + Kubernetes 工具链与 8 段全自动 CI/CD 流水线、SonarQube/Trivy 安全门禁、Terraform IaC + 不可变基础设施、测试金字塔分层自动化、金丝雀发布 + 特性开关 + 一键回滚、Prometheus+ELK+SkyWalking 可观测三支柱，并把图片处理/定时对账/Webhook 等长尾事件驱动任务迁移到阿里云函数计算（FaaS）。1 年后 DORA 达 Elite 级——部署频率 日 50 次、Lead Time < 1 天、变更失败率 3%、MTTR 12 分钟，环境不一致故障归零，Serverless 化使该部分资源成本下降约 40%。同时分析了流水线维护成本、Serverless 冷启动与 Vendor Lock-In、文化阻力等权衡。"

**加分关键词**：DevOps、CALMS、SRE、SLI/SLO/Error Budget、CI、持续交付、持续部署、CI/CD 流水线、安全左移（Shift-Left）、SAST/DAST/SCA、质量门禁、GitLab CI/Jenkins/GitHub Actions、Argo CD/Flux、**GitOps**、Harbor、Docker、Kubernetes/HPA、12-Factor、**基础设施即代码 IaC**、Terraform/Ansible/Pulumi、声明式、幂等性、**不可变基础设施**、蓝绿部署、**金丝雀/灰度发布**、滚动发布、影子流量、**特性开关（Feature Flag/Toggle）**、一键回滚、混沌工程（ChaosBlade/Chaos Mesh）、可观测三支柱 Metrics/Logs/Traces、Prometheus/Grafana/ELK/Loki/SkyWalking/Jaeger/OpenTelemetry、**DORA 四指标**（部署频率/变更前置时间/变更失败率/MTTR）、Elite 级、**Serverless/FaaS/BaaS**、AWS Lambda/阿里云函数计算 FC/腾讯云 SCF、Knative/OpenFaaS、按调用计费、自动弹性、事件驱动、**冷启动**、Provisioned Concurrency、GraalVM、Vendor Lock-In、平台工程（Platform Engineering）、AIOps、FinOps；业界对标：Google SRE / DORA《Accelerate》、Netflix Spinnaker、Weaveworks GitOps、HashiCorp Terraform、阿里 AHAS/云效、腾讯蓝鲸、字节 ByteAOPS。

**避坑**：① DevOps = 自动化工具 → **文化 + 流程 + 工具**三位一体，CALMS 落地；② 无量化指标 → **DORA 四指标必量化前后对比**；③ 不讲 IaC → Terraform/Ansible + 不可变基础设施是基础；④ 不讲可观测 → **Metrics/Logs/Traces** 三支柱 + SLO + 告警必写；⑤ 部署一刀切 → 金丝雀/蓝绿/滚动按场景选 + 特性开关 + 一键回滚；⑥ Serverless 一把梭 → 冷启动/有状态/长任务/高 QPS 稳定负载场景不适合，只迁低频/突发/事件驱动；⑦ 忽略 Vendor Lock-In → 抽象运行时 + Knative/OpenFaaS 备选；⑧ 不讲安全 → 安全左移（SAST/SCA/镜像签名）+ 流水线即审计；⑨ 流水线只写"构建-部署" → 8 段齐全（含 SAST/SCA/集成/E2E/灰度/监控）。

> 完整理论 + 模拟论文（2 道：论 DevOps 工程实践与 CI/CD 流水线建设 · 论 Serverless/FaaS 在事件驱动场景中的应用，含提纲式参考答案、加分关键词清单、评分维度对照表、避坑提醒）：[`past-papers/paper-topics/13-devops-serverless.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/paper-topics/13-devops-serverless.md)；新技术笔记：[`notes/10-emerging-tech/README.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/notes/10-emerging-tech/README.md)、[`notes/23-frontier-tech/README.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/notes/23-frontier-tech/README.md)。

---

> 软考专题系列第 12 篇（"DevOps·Serverless / 企业集成 / 嵌入式 / SOA·演化"这一组的第 1 篇）。同组：[企业应用集成](/soft-exam-topic-enterprise-integration/) · [嵌入式系统架构](/soft-exam-topic-embedded/) · [SOA 与架构演化](/soft-exam-topic-soa-evolution/)。完整专题清单见 [软考导览页](/soft-exam-system-architect-2026-guide/)。发现题目错误欢迎到 [仓库](https://github.com/PeterGuy326/senior-software-architect-review) 开 issue。
