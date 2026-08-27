---
title: 软考高级 · 系统架构设计师 2026 备考全攻略（开源题库 240+ 题 + 范文 5 篇）
date: 2026-05-10T22:00:00+08:00
updated: 2026-05-10T22:00:00+08:00
cover: /img/covers/sysarch-textbook.jpg
top_img: /img/covers/sysarch-textbook.jpg
tags:
  - 软考
  - 系统架构设计师
  - 备考
  - 软件架构
  - 自学
  - 题库
categories:
  - 软考
---

> 这是一份**面向 2026 上半年考期**的系统架构设计师（软考高级）备考资源专题。所有内容已开源在 [`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)，包括自主命题的 320 道选择题（带解析）、26 道案例完整模拟题、21 道论文仿真题、5 篇 2500+ 字范文，以及 22 个知识点 → 例题双向索引。本文是**导览 + 复习路线图**，按"科目结构 → 仓库定位 → 8 周节奏"三段展开，可以直接当成你考前的检查清单。

## 写在前面

软考高级系统架构设计师有两个让人头疼的地方：**广（覆盖 20+ 章）** 和 **杂（综合/案例/论文三科风格完全不同）**。市面上的题库要么是过期的纸质书 PDF，要么是付费课程把题切成"会员专享"，自学党靠 GitHub 凑齐高质量资料其实很难。

这个专题做的事情很简单：**把我自己刷题、整理笔记、写论文的过程沉淀成一个公开仓库**，按官方考纲的颗粒度拆分到每一章每一题型。零付费、可 fork、欢迎提 issue 共建错题本。

## 考试基本信息

> 以**全国计算机技术与软件专业技术资格（水平）考试**官网最新通知为准，此处仅作速查。

| 项 | 内容 |
|---|---|
| 资格等级 | 高级 |
| 考试频次 | 一年两次：**5 月 / 11 月** |
| 考试形式 | **机考**（2023 下半年起计算机化考试） |
| 科目一：综合知识 | 选择题 75 道，最短 120 / 最长 150 分钟 |
| 科目二：案例分析 | 问答题 5 选 3，与综合连考，合计 240 分钟 |
| 科目三：论文 | 4 选 1，120 分钟，**≥ 2500 字** |
| 合格线 | **三科均 ≥ 45 分**，成绩不跨期保留 |
| 官方教材 | 《系统架构设计师教程（第 2 版）》叶宏等，清华大学出版社，2022-11，ISBN 9787302619925 |

合格线是**三科齐过**这一条特别狠——综合刷高 60 分救不了论文 40 分。所以三科要按"综合稳过线 / 案例打 60+ / 论文搏 50+"的优先级分配时间。

## 仓库定位：240+ 题 + 三大题型分类 + 双向索引

仓库结构按"题型直达 + 知识点索引"两套入口设计：

```
senior-software-architect-review/
├── exam-bank/         # ⭐ 综合 320+ 选择题（带解析，17 章高频考点）
├── past-papers/
│   ├── case-types/    # ⭐ 案例 9 大题型 × 26 道完整模拟
│   ├── paper-topics/  # ⭐ 论文 13 大主题 × 21 道仿真模拟
│   ├── paper-samples/ # ⭐ 5 篇 2500+ 字范文（真实项目改编）
│   └── wrong-questions.md
├── notes/             # 教材 20 章 + 新技术（含 11-18 案例章节笔记）
├── mind-maps/         # 4 张核心知识域 Mermaid 思维导图
├── cheatsheets/       # 17 张高频考点速查表（质量属性 / UML / 模式 / 网络）
├── knowledge-index/   # 22 个知识点 → 例题双向索引
└── resources.md       # 外部权威资源
```

### 题库规模一览

| 科目 | 题型 | 题数 | 入口 |
|---|---|---|---|
| 综合知识 | 选择题（含答案 + 解析） | **320+** | [`exam-bank/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/exam-bank) |
| 案例分析 | 完整模拟题（题干+答案+评分点） | **26** | [`past-papers/case-types/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/case-types) |
| 论文 | 仿真模拟题（题目+提纲答案） | **21** | [`past-papers/paper-topics/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/paper-topics) |
| 论文 | 完整范文（2500-2800 字/篇） | **5** | [`past-papers/paper-samples/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/paper-samples) |

## 分专题刷题（持续更新）

把高频专题的「选择题 + 案例答题套路 + 完整模拟题 + 论文万能提纲」三件套打包成独立文章，一个专题一篇，照着刷就行：

| 专题 | 出题频率 | 覆盖内容 |
|---|---|---|
| [架构评估 ATAM](/soft-exam-topic-atam-evaluation/) | 选择每年 2-3 题 · 案例**必出 1 题** · 论文高频 | 四类点 / 6 元组 / 效用树 + 15 选择题 + 完整模拟案例 + 论文提纲 |
| [架构风格对比与选型](/soft-exam-topic-architecture-styles/) | 选择每年 4-6 题 · 案例约两年 1 题 | 五大风格速查 + 20 选择题 + SOA vs 微服务选型模拟案例 + 论文提纲 |
| [微服务与云原生](/soft-exam-topic-microservice-cloud-native/) | 选择每年 2-4 题 · 案例近 5 年多次 · 论文高频 | DDD 拆分 / 治理组件 / 分布式事务 + 15 选择题 + 单体拆分模拟案例 + 论文提纲 |
| [数据库设计](/soft-exam-topic-database-design/) | 选择每年 6-8 题（重灾区）· 案例几乎每年 1 题 | 范式 / ER 转换 / 事务隔离 / 反规范化 + 25 选择题 + 2 道模拟案例（ER+3NF 分解 · **MySQL+Redis+读写分离综合**）+ 答题模板 |
| [消息中间件与缓存](/soft-exam-topic-messaging-caching/) | 选择每年 2-4 题 · 案例近 5 年多次出 1 题 | 缓存三大问题 / Cache Aside / 分布式锁 / MQ 选型 / 顺序幂等 + 22 选择题 + 双 11 秒杀模拟案例 + 答题模板 |
| [法律法规与标准化](/soft-exam-topic-ip-and-standards/) | 选择每年 2-3 题（白给分） | 知识产权保护期/起算点 / 职务·委托·合作开发权属 / 思想 vs 表达 / GB 标准分类 / ISO 标准对应 + 26 选择题 + 速查表 + 易错对照 |
| [计算题专项](/soft-exam-topic-exam-calculations/) | 选择每年 8-12 题（套公式白给分） | 计算机系统（Cache/流水线/海明码/可靠性）+ 网络（子网/传输时间）+ 项目管理（关键路径/PERT/挣值）+ 软件度量（功能点/圈复杂度）+ 6 类公式速查 + 例题 |
| [软件架构安全](/soft-exam-topic-security/) | 选择每年 4-6 题 · 案例中频 1 题 · 论文高频 | CIA / STRIDE / 对称非对称加密+国密 / 数字签名+PKI / 认证授权 / WAF/IDS/IPS / SQL注入·XSS·CSRF / 等保 2.0 + 22 选择题 + 安全架构模拟案例 + 论文提纲 |
| [设计模式 GoF 23](/soft-exam-topic-design-patterns/) | 选择每年 2-4 题（含"看场景选模式"）· 论文偶考 | 创建型 5 / 结构型 7 / 行为型 11 一句话速查 + 8 组易混辨析 + SOLID + 25 选择题 + 场景识别速查表 + 论文提纲 |
| [大数据架构](/soft-exam-topic-big-data/) | 选择每年 1-3 题 · 案例中频 1 题 · 论文中频 | 5V / Hadoop 生态 / Lambda vs Kappa / 数仓·数据湖·数据中台 / OLTP vs OLAP / NoSQL 四类 + 18 选择题 + Lambda/Kappa 选型模拟案例 + 论文提纲 |
| [软件可靠性与容灾设计](/soft-exam-topic-reliability/) | 案例·论文高频（常和架构评估/微服务混考）· 选择含可靠性计算 | MTBF/MTTR/可用性 / 几个 9 / 串并联可靠性计算 / 避错·检错·容错 / 限流·熔断·降级·舱壁 / RTO·RPO·两地三中心 + 18 选择题 + 高可用改造模拟案例 + 论文提纲 |
| [DevOps 与 Serverless](/soft-exam-topic-devops-serverless/) | 选择每年 1-3 题 · 论文高频 | DevOps·CALMS / CI·持续交付·持续部署 / 蓝绿·金丝雀·滚动发布 / IaC·GitOps / 12-Factor / FaaS·冷启动 / DORA 四指标 + 18 选择题 + CI/CD 流水线改造模拟案例 + 论文提纲 |
| [企业应用集成](/soft-exam-topic-enterprise-integration/) | 案例·论文常见 · 选择含中间件分类 | EAI 四层次 / 点对点 vs Hub-and-Spoke vs ESB / ESB 能力 / 中间件分类（RPC·MOM·ORB·TPM）/ 集成模式 / Web Service 三件套 / 遗留系统演化 + 18 选择题 + 8 系统集成方案模拟案例 + 论文提纲 |
| [嵌入式系统架构](/soft-exam-topic-embedded/) | 案例中低频 1 题 · 选择含 RMS/EDF · 论文偶考 | 嵌入式特点·分层 / 硬实时 vs 软实时 / RTOS·优先级反转 / RMS·EDF 可调度性判定 / 基于构件开发 CBSD + 18 选择题 + ECU 实时调度模拟案例 + 论文提纲 |
| [SOA 与架构演化](/soft-exam-topic-soa-evolution/) | 选择每年 2-4 题 · 案例·论文高频 | SOA 八原则 / Web Service·ESB·BPEL / 编排 vs 编制 / SOA·微服务·单体三维对比 / 绞杀者·防腐层 / 上云 6R / 遗留系统四象限 + 18 选择题 + 单体→微服务上云演化模拟案例 + 论文提纲 |

> 三组共 **15 篇**专题文章已全部上线，覆盖案例的 9 大题型 + 综合知识高频章节 + 论文 13 大主题。所有专题文章统一归在 [软考分类页](/categories/软考/)，按需继续补充。

## 科目一：综合知识（75 选 1）

> 三科里最容易稳过线的——但**广**。覆盖 20+ 章，每章 3-5 题，没有偏科余地。

打法：用 [`exam-bank/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/exam-bank) 的题先扫一遍找薄弱章节，然后回 [`cheatsheets/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/cheatsheets) 单点强化，最后用 [`mind-maps/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/mind-maps) 做横向串联。

### exam-bank：17 章高频题库

| # | 章节 | 题数 | 高频考点 |
|---|---|---|---|
| 01 | 计算机系统基础 | 15 | Cache / 流水线 / 编码 / 校验 / 浮点 |
| 02 | 操作系统 | 15 | 进程线程 / 调度 / 内存 / 文件 |
| 03 | 数据库 | 25 | 范式 / 事务 / 索引 / NoSQL |
| 05 | UML | 15 | 9 种图 / 关系 / 用例建模 |
| 06 | 知识产权与标准 | 25 | 著作权 / 专利 / 商标 / 职务作品 / GB标准 / ISO |
| 10 | 架构风格 | 20 | C/S / B/S / SOA / 微服务 / 事件驱动 |
| 11 | 质量属性 | 15 | ISO 25010 / 战术 / 场景 |
| 12 | ATAM 评估 | 15 | 风险点 / 敏感点 / 权衡点 |
| 13 | 设计模式（GoF 23） | 25 | 创建型 / 结构型 / 行为型 |
| 15 | 微服务与云原生 | 15 | 拆分 / 治理 / K8s / Service Mesh |
| 19 | 大数据架构 | 20 | Hadoop 生态 / Lambda·Kappa / 数仓·数据湖 / NoSQL |
| 20 | 软件可靠性与容灾 | 22 | MTBF·可用性计算 / 串并联可靠性 / 限流·熔断·降级 / RTO·RPO |
| 21 | 安全 | 20 | 加密 / 认证 / 攻击 / 防护 |
| 22 | 嵌入式系统架构 | 18 | RMS·EDF 可调度判定 / 优先级反转 / RTOS / CBSD 构件组装 |
| 24 | DevOps 与 Serverless | 19 | CI/CD / 蓝绿·金丝雀 / IaC·GitOps / 12-Factor / FaaS / DORA |
| 25 | 企业应用集成 | 18 | EAI 四层次 / ESB / 中间件分类 / 集成模式 EIP / 遗留系统演化 |
| 26 | SOA 与架构演化 | 20 | SOA 八原则 / 编排·编制 / SOA·微服务·单体对比 / 绞杀者·上云 6R |

每题正确选项已用 ✅ + **加粗** 双标记，方便复盘扫读。

### cheatsheets：17 张速查表

考前一周就只翻这一组：

- 架构风格 / ABSD / ADL / 架构评估
- 质量属性 / ISO 25010 / 软件度量 / 软件可靠性
- UML / GoF 23 / 缓存模式 / 分布式事务
- 数据库范式 / 中间件对比 / 计算机系统公式
- 网络 / OS / 知识产权与标准 / 项目管理计算
- 论文摘要模板 / 论文写作模板 / 案例答题套路 / 英语阅读

### mind-maps：4 张 Mermaid 脑图

[`00-overall.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/mind-maps/00-overall.md) 是顶层全景，[`architecture-styles.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/mind-maps/architecture-styles.md) / [`design-patterns.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/mind-maps/design-patterns.md) / [`quality-attributes.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/mind-maps/quality-attributes.md) 是三大重灾区的展开。

## 科目二：案例分析（5 选 3）

> 决定及格线的科目。每题 25 分，3 题 75 分，过 45 分需要至少 2 题打 23 分以上，容错率比想象中低。

打法：[`case-types/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/case-types) 把过去十年真题按 9 种题型分类，**每种题型有固定答题套路**——把套路背熟，临场只填具体场景词。

### 9 大题型 × 26 道模拟

| # | 题型 | 出题频率 | 答题套路要点 |
|---|---|---|---|
| 01 | 架构评估（ATAM） | 高 | 风险/敏感/权衡点三分法 |
| 02 | 数据库设计 | 高 | ER → 范式 → 优化 → NoSQL 选型 |
| 03 | 架构风格对比 | 高 | C/S vs B/S / 单体 vs 微服务 / SOA vs 微服务 |
| 04 | UML 建模 | 中 | 用例图 / 类图 / 顺序图 / 活动图四件套 |
| 05 | 微服务拆分 | 高 | DDD 限界上下文 + 拆分原则 + 治理组件 |
| 06 | 消息缓存 | 中 | 削峰/异步/解耦 + 缓存一致性 |
| 07 | 安全架构 | 中 | 认证/授权/加密/审计四象限 |
| 08 | 嵌入式构件 | 低 | 实时性 / 可靠性 / 资源约束 |
| 09 | 大数据架构 | 中 | Lambda / Kappa / 数据湖 / 数据中台 |

配套速查表 [`cheatsheets/case-answer-patterns.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/cheatsheets/case-answer-patterns.md) 是答题模板，**带 9 大题型的标准开头/分点/收尾段式**。

## 科目三：论文（4 选 1）

> 最容易翻车也最容易出彩。120 分钟写 2500 字，只有"已经在脑里有 5 个项目案例"的人能稳过。

打法：[`paper-topics/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/paper-topics) 是 13 大主题的**万能提纲**（开头/三段论/收尾的可复用模板），[`paper-samples/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/past-papers/paper-samples) 是 5 篇 2500-2800 字真实项目改编范文，可以直接拆字数比例对照。

### 13 大主题 × 21 道仿真

| # | 主题 | 真实项目可借的角度 |
|---|---|---|
| 01 | 架构设计 | 任意 to-C / to-B 项目 |
| 02 | 架构评估（ATAM） | 上线前的架构 review |
| 03 | 可靠性设计 | 容灾 / 限流 / 熔断 / 重试 |
| 04 | 安全设计 | 鉴权 / 加密 / WAF / 等保 |
| 05 | 微服务与云原生 | DDD 拆分 + K8s / Service Mesh |
| 06 | 大数据 / NoSQL | 数据中台 / 实时数仓 |
| 07 | SOA | 老系统改造 / ESB |
| 08 | 基于构件 | 内部组件库 / 外部 SDK 集成 |
| 09 | 架构演化 | 单体 → 微服务 / 上云 |
| 10 | 设计模式 | 任何含"扩展点"的项目 |
| 11 | 企业集成 | 对接 ERP / OA / SAP |
| 12 | 测试与 QA | 自动化测试 / 性能压测 |
| 13 | DevOps / Serverless | CI/CD 流水线 / FaaS 落地 |

### 5 篇完整范文

| # | 主题 | 字数 | 可改编为 |
|---|---|---|---|
| 01 | 架构设计 | 2800 | 几乎所有架构题 |
| 02 | 架构评估 | 2700 | ATAM / 评估方法论 |
| 03 | 可靠性设计 | 2750 | 容灾 / 高可用 |
| 04 | 安全设计 | 2800 | 安全架构 / 等保 |
| 05 | 微服务与云原生 | 2800 | 微服务拆分 / DDD |

写作模板见 [`cheatsheets/paper-writing-templates.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/cheatsheets/paper-writing-templates.md) 和 [`cheatsheets/paper-abstract-template.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/cheatsheets/paper-abstract-template.md)。

## 终极复习入口：知识点 → 例题双向索引

[`knowledge-index/`](https://github.com/PeterGuy326/senior-software-architect-review/tree/master/knowledge-index) 是这个仓库最值钱的部分——把 22 个高频知识点反向映射到对应的选择题、案例题、论文角度。

> **考前最短路径**：找一个你心虚的知识点 → 跳到对应的 index 文件 → 一次性把这个点的所有真题打完 → 回到 cheatsheet 再扫一遍 → 收工。

例如「架构风格」这个知识点，索引里会列出：
- 选择题：[`exam-bank/10-architecture-styles.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/exam-bank/10-architecture-styles.md) 第 1-20 题
- 案例：[`case-types/03-style-comparison.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/case-types/03-style-comparison.md)
- 论文：[`paper-topics/01-architecture-design.md`](https://github.com/PeterGuy326/senior-software-architect-review/blob/master/past-papers/paper-topics/01-architecture-design.md)

一个点吃透一组题，比按章节顺序硬刷有效得多。

## 8 周复习节奏建议

> 假设你是在职党，每周稳定投入 8-10 小时。距离考期不足 8 周时，砍掉前两周，从第 3 周开始。

| 周次 | 重点 | 产出 |
|---|---|---|
| W1 | 通读教材前 10 章 + mind-maps/00-overall | 知道考什么，找出薄弱章 |
| W2 | exam-bank 11 章每章打一遍 | 第一份错题本（wrong-questions.md） |
| W3 | cheatsheets 17 张过完 | 笔记本上手抄关键公式 |
| W4 | case-types 9 题型每种打 1 题 | 9 篇答题模板 |
| W5 | paper-samples 5 篇精读 + 拆结构 | 自己列出 5 个项目素材 |
| W6 | paper-topics 13 主题任选 5 篇仿写 | 5 篇 1500 字简版论文 |
| W7 | 错题本 + knowledge-index 反向刷 | 弱点清单 |
| W8 | 模考 2 套（综合 + 案例 + 论文） | 预估分数 + 调整心态 |

## 仓库链接 + 反馈渠道

- **仓库主页**：[`PeterGuy326/senior-software-architect-review`](https://github.com/PeterGuy326/senior-software-architect-review)
- **错题本贡献**：欢迎 PR 加入你做错过的题
- **issue 反馈**：发现题目错误 / 解析有歧义直接开 issue
- **配套博客**：本站 [软考分类页](/categories/软考/) 持续更新

> 这个专题会随我自己的复习进度滚动更新，2026 上半年考前会再发一篇"考前一周清单"短文。如果你也在备考，欢迎在评论区留下你的弱点章节，下一篇优先补强。
