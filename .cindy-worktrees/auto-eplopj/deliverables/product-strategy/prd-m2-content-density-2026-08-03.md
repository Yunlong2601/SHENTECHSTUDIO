# M2 Content Density — Product Requirements Document (PRD)

**Date**: 2026-08-03
**Type**: PRD / 功能规格书
**参与成员**: 析客（requirement-analyst）、瑞思（user-researcher）、竞析（competitive-analyst）、数析（data-analyst）、路径（roadmap-planner）、方向明（product helmsman）

---

## 📌 TL;DR（执行摘要）

- **核心目标**：将 Geometry Breakout 从平坦难度曲线升级为节奏化战斗体验 — 引入 Wave 4 中场 Boss、Wave 8 终局 Boss 四阶段 DPS 检查、加权生成分布、帧率独立 Glitch 腐蚀叠加机制
- **关键决策**：终局 Boss HP 从原始建议 80→200→最终定为 300（竞品基准显示类型标准战斗时长 30-90s 而非 6-9s）；Glitch 不再替换而是腐蚀当前激活的 Modifier；Splitter 提前到 Wave 3 引入以避免与中 Boss 叠加
- **下一步**：P0+P1 作为 M2 发布目标（~3.5 周），分 3 个阶段实施；Week 1 启动 Spawn System Foundation（R-02/R-03/R-05/R-06）

---

## 🎯 核心结论卡片

| 项目 | 内容 |
|------|------|
| 推荐方案 | P0+P1（11 项需求）作为 M2 发布目标；P2（4 项）作为后续补丁 |
| 优先级 | P0: 6 项 / P1: 5 项 / P2: 4 项 |
| 预期影响 | 中 Boss 截断早期单调感；终局 Boss 四阶段将战斗时长从 ~9s 拉伸到 35-45s；Glitch 腐蚀叠加增加策略深度 |
| 资源需求 | 单人 Lua 开发，~105 工时（P0+P1），含集成测试和回归 |
| 风险等级 | 中 — R-03 Glitch 腐蚀叠加为架构新 Pattern；R-04 四阶段平衡需大量手感测试 |

---

## 1. 产品目标

1. **节奏化战斗曲线** — 通过中 Boss（W4）和终局 Boss 四阶段 DPS 检查，将 8 波战斗从均匀递增变为有起伏的节奏体验
2. **策略性 Modifier 交互** — Glitch 不再替换而是腐蚀叠加在当前 Modifier 上，创造 layered chaos（如 Glitch + Compression = 边界抖动）
3. **可读的战斗反馈** — 通过 Modifier Dock、Glitch Badge、中 Boss 血条和入场闪屏，让玩家理解正在发生什么

---

## 2. 用户故事

| # | 场景 | 用户故事 |
|---|------|----------|
| US-1 | 中 Boss 遭遇 | "作为玩家，我希望在 Wave 4 遇到一个有血条的独特 Boss，让我感觉前期战斗有目标感而不是无脑刷怪" |
| US-2 | 终局 Boss 决战 | "作为玩家，我希望终局 Boss 有多个阶段逐渐升级压力，让我有'差一点就赢了'的紧张感而不是秒杀" |
| US-3 | Glitch 腐蚀 | "作为玩家，我希望 Glitch 发生时能看到当前 Modifier 被扭曲而不是被替换，让我感觉混乱是有层次的" |
| US-4 | 生成多样性 | "作为玩家，我希望不同波次的敌人组合有辨识度，让我能用不同策略应对不同波次" |
| US-5 | Modifier 可读性 | "作为玩家，我希望 HUD 上能看到当前激活的 Modifier 和 Glitch 状态，让我不用猜发生了什么" |

---

## 3. 用户研究洞察（来自瑞思）

**关键洞察：**
- **Splitter 引入时机**：瑞思建议将 Splitter 从 Wave 4 提前到 Wave 3 — 避免与中 Boss 遭遇叠加导致信息过载。Wave 3 玩家已有 2 波适应期，可以接受新敌人类型
- **Boss 战时长预期**：玩家对"Boss 战"的心智模型是"有阶段的、需要策略的较长战斗"，而非"血量高一点的精英怪"。当前终局 Boss ~9s 的击杀时间严重偏离预期
- **Glitch 反馈缺失**：当前 Glitch 触发时玩家普遍不知道发生了什么 — 需要可视化指示器而非仅靠敌人位移感知
- **Modifier 叠加期望**：部分玩家反馈"希望 Glitch 和其他 Modifier 能同时存在" — 这直接催生了腐蚀叠加机制而非替换

---

## 4. 竞品对比（来自竞析，5-7 个产品）

### 竞品 Boss 战基准

| 竞品 | 中 Boss 模式 | 终局 Boss 时长 | Boss HP 范围 | 阶段切换 |
|------|-------------|---------------|-------------|----------|
| Vampire Survivors | 每 5min精英 | 3-5min | 200-500 | 血量阶段 |
| Brotato | N/A (wave-based) | 2-3min | 150-300 | 武器切换 |
| 20 Minutes Till Dawn | 每 5min Boss | 1-2min | 100-250 | 2-3 阶段 |
| Spellbook Demonslayers | 每 3 波 Boss | 45-90s | 80-200 | 速度/模式切换 |
| Halls of Torment | 每 10min Boss | 2-4min | 300-800 | 多阶段 + 机制 |

**关键结论：**
- 类型标准战斗时长：**30-90s**（我们当前 ~9s 严重偏低）
- 中 Boss 是标准做法 — 多数竞品在游戏中期引入截断点
- 多阶段 Boss 是类型标配 — 2-4 个阶段，通常通过血量百分比或时间触发
- HP 300 在竞品中属于中低区间，适合我们的 8 波短局制

### 竞品 Glitch/混乱机制对比

| 竞品 | 混乱机制 | 是否叠加 | 玩家反馈 |
|------|---------|---------|---------|
| Vampire Survivors | N/A | N/A | N/A |
| Brotato | 难度修饰符 | 独立 | 可读性好 |
| 20 Minutes Till Dawn | 诅咒 | 叠加 | 玩家喜欢叠加 |
| Spellbook Demonslayers | 混沌 | 替换 | 玩家觉得突兀 |

**关键结论：** 叠加式混乱机制（如 20 Minutes Till Dawn 的诅咒叠加）比替换式（Spellbook Demonslayers）更受玩家欢迎。这验证了 Glitch 腐蚀叠加的设计方向。

---

## 5. 数据依据（来自数析）

### 当前游戏指标

| 指标 | 当前值 | 目标值 | 变化原因 |
|------|--------|--------|---------|
| 终局 Boss 击杀时间 | ~9s | 35-45s | HP 40→300 + 四阶段 DPS 检查 |
| 终局 Boss HP (W8) | 40+8*3=64 | 100+8*25=300 | 竞品基准对标 |
| Wave 7 (Glitch) 敌人上限 | 24 (硬编码) | 25 (动态) | 视觉清晰度 |
| 普通波敌人上限 | 24 (硬编码) | 30 (动态) | 内容密度提升 |
| Glitch 触发概率 | 2%/帧 (帧率依赖) | λ≈0.18/s (帧率独立) | 公平性修复 |
| Overclock 倍率 (W6) | 1.25 | 1.15 | 防止 W6-W7 连续高压 |

### Boss HP 演化决策链

```
数析初始建议: 80-88 (基于当前击杀时间 × 1.5)
    ↓
竞析基准校准: 类型标准 30-90s → 需要大幅提升
    ↓
主理人决策 v1: 200 HP (击杀时间 ~25s)
    ↓
团队共识: 25s 仍偏短 → 300 HP (击杀时间 ~35-45s, 对标竞品中低区间)
    ↓
最终决策: 300 HP + 四阶段递进 (0-15s 基础 / 15-25s 加速 / 25-35s +小怪 / 35s+ 压缩)
```

---

## 6. 需求池（P0/P1/P2 优先级）

### P0 — 必须发布

| 编号 | 需求 | 优先级 | 验收标准 | 估算工作量 |
|------|------|--------|---------|-----------|
| R-01 | 中 Boss 遭遇（Wave 4） | P0 | Wave 4 生成 HP=60 的中 Boss；有独立血条；击败后必掉模块；无 Modifier；无计时器（Boss 死亡+清怪才过关） | 12h |
| R-02 | 加权生成分布 | P0 | `kind_for_id()` 改为加权随机；Splitter W3 引入、Shooter W5 引入；Chaser 30%/Skimmer 20-25%/Charger 15%/Splitter 10%/Shooter 20-25% | 8h |
| R-03 | Glitch 帧率独立修复 | P0 | 替换 `math.random()<0.02` 为 delta-time Poisson (λ≈0.18/s)；Glitch 腐蚀叠加当前 Modifier 而非替换；闪烁 50ms/最多3个；脉冲 1.5s 激活/1.5-2s 间歇 | 14h |
| R-04 | 终局 Boss HP 升级 | P0 | HP 改为 `100+wave*25`（W8=300）；移除 Boss 波计时器；四阶段递进（0-15s 基础 / 15-25s +30% 生成 / 25-35s +每3s 小怪 / 35s+ 竞技场压缩10%+Glitch 视觉开裂） | 14h |
| R-05 | 碎片上限 | P0 | `spawn_fragment()` 限制最多 8-10 个碎片；防止 Splitter 死亡在 Glitch 波刷屏 | 2h |
| R-06 | 动态敌人上限 | P0 | 硬编码 24 改为动态；普通波 30 / Glitch 波 25 | 3h |

### P1 — 应当发布

| 编号 | 需求 | 优先级 | 验收标准 | 估算工作量 |
|------|------|--------|---------|-----------|
| R-07 | Wave 6 Overclock 调整 | P1 | 倍率 1.25→1.15 或生成目标 26→23；防止 W6-W7 连续高压 | 3h |
| R-08 | Wave 7 Glitch 生成削减 | P1 | 生成运行时间降至 ~70-75%；生成密度降 15-20%（目标 26→21-22） | 4h |
| R-09 | Modifier Dock UI | P1 | HUD 新增 Modifier 指示面板；显示当前 Modifier 图标；Glitch 激活时叠加腐蚀标识 | 5h |
| R-10 | Glitch Badge 动画 | P1 | Badge 在 Glitch 腐蚀时脉冲/闪烁；绑定 `glitchPulseTimer_`；Alpha 60-100% 与敌人闪烁同步 | 3h |
| R-11 | 中 Boss 入场闪屏 | P1 | 中 Boss 生成时 500ms 屏幕闪烁 + "WARNING" 文字；渐隐 | 3h |

### P2 — 锦上添花

| 编号 | 需求 | 优先级 | 验收标准 | 估算工作量 |
|------|------|--------|---------|-----------|
| R-12 | 阶段切换播报 | P2 | 终局 Boss 阶段转换时显示 "Phase 2/3/4" 文字；非侵入式自动渐隐 | 3h |
| R-13 | Glitch 屏幕开裂特效 | P2 | 阶段 4 屏幕边缘出现裂纹线；纯装饰性张力增强 | 4h |
| R-14 | 敌人类型击杀计数器 | P2 | 追踪各类型敌人击杀数；战后统计屏展示 | 3h |
| R-15 | 波次预览提示 | P2 | 波次转换时显示 2s 即将到来的 Modifier 预览 | 4h |

---

## 7. 关键流程

### 7.1 中 Boss 遭遇流程

```
Wave 4 开始
    ↓
is_midboss_wave() == true → 生成中 Boss (HP=60, speed=34, size=48px)
    ↓
屏幕闪烁 500ms + "WARNING" 文字 (R-11)
    ↓
中 Boss 血条出现在 HUD (复用 bossCard_ 模式)
    ↓
Wave 4 无 Modifier (中 Boss 本身就是内容)
    ↓
玩家战斗 → 中 Boss HP 归零
    ↓
ApplyUpgrade() 强制触发模块掉落 (必掉)
    ↓
等待剩余敌人清空 → 波次完成
    ↓
进入 Wave 5 (Shooter 引入)
```

### 7.2 终局 Boss 四阶段 DPS 检查

```
Wave 8 开始 → 生成终局 Boss (HP=300, 无计时器)
    ↓
Stage 1 (0-15s): 基础模式 — 正常脉冲速度
    ↓
Stage 2 (15-25s): 加速脉冲 — 生成速率 +30%
    ↓
Stage 3 (25-35s): 每 3s 生成 2-3 个 Chaser 小怪
    ↓
Stage 4 (35s+): 竞技场压缩 10% + Glitch 视觉开裂 (屏幕边缘闪烁)
    ↓
Boss HP 归零 + 所有敌人清空 → 游戏胜利
```

### 7.3 Glitch 腐蚀叠加机制

```
当前 Modifier 激活 (如 Compression)
    ↓
Glitch Poisson 触发 (λ≈0.18/s, 帧率独立)
    ↓
Glitch 不替换 Compression → 腐蚀叠加:
  - Compression 边界抖动 ±18px
  - 敌人闪烁 50ms (最多3个并发, alpha 60-100%)
  - 1.5s 激活脉冲
    ↓
1.5-2s 间歇期 (Glitch 暂停, Compression 恢复正常)
    ↓
循环直到波次结束
```

### 7.4 加权生成分布

```
Wave 1-2: Chaser 60% / Skimmer 40% (仅基础敌人)
Wave 3-4: Chaser 35% / Skimmer 25% / Charger 20% / Splitter 10% (Splitter 引入)
Wave 5-6: Chaser 30% / Skimmer 22% / Charger 15% / Splitter 10% / Shooter 23% (Shooter 引入)
Wave 7-8: Chaser 30% / Skimmer 20% / Charger 15% / Splitter 10% / Shooter 25% (全类型混合)
```

---

## 8. Non-goals（明确不做什么）

- ❌ 不做中 Boss 的多阶段（中 Boss 是单阶段，区别于终局 Boss 的四阶段）
- ❌ 不做 Glitch 作为独立 Modifier 使用（Glitch 始终是腐蚀叠加，不会单独出现）
- ❌ 不做 Wave 4 的 Modifier（中 Boss 本身就是 Wave 4 的内容）
- ❌ 不做在线多人或排行榜（M2 聚焦内容密度，社交功能属于 M3）
- ❌ 不做新模块/武器（M2 不扩展模块池，仅调整中 Boss 必掉机制）
- ❌ 不做难度选择系统（M2 保持单一难度曲线，通过波次设计调节）

---

## 9. 时间线 & 里程碑（来自路径）

### 三阶段实施计划

| 阶段 | 周次 | 重点 | 需求 | 交付物 |
|------|------|------|------|--------|
| Phase 1 | Week 1 | 生成系统基础 | R-02, R-03, R-05, R-06 | 加权生成、Glitch 修复、碎片/敌人上限 |
| Phase 2 | Week 2-3 | Boss 遭遇 & 节奏 | R-01, R-04, R-07, R-08 | 中 Boss、终局 Boss 四阶段、波次调参 |
| Phase 3 | Week 3.5 | UI 反馈 & 打磨 | R-09, R-10, R-11, (R-12~R-15) | Modifier Dock、Glitch Badge、入场闪屏 |

### 里程碑定义

| 里程碑 | 内容 | 工时 | 日历周 |
|--------|------|------|--------|
| Tier 1 (MVP) | P0 only (6 项) | 75h | ~2.5 周 |
| **Tier 2 (推荐发布)** | **P0+P1 (11 项)** | **105h** | **~3.5 周** |
| Tier 3 (完全打磨) | P0+P1+P2 (15 项) | 140h | ~4.5-5 周 |

### 依赖关系

```
Phase 1: R-02 → R-05, R-06 (生成系统先建)
         R-03 (独立, 但阻塞 R-08, R-09, R-10)

Phase 2: R-01 (依赖 Phase 1 生成系统)
         R-04 (独立, 但阻塞 R-12, R-13)
         R-07 (依赖 R-01 上下文)
         R-08 (依赖 R-03)

Phase 3: R-09 (依赖 R-03) → R-10 (依赖 R-09 + R-03)
         R-11 (依赖 R-01)
         R-12, R-13 (依赖 R-04)
         R-14, R-15 (独立)
```

### P0 关键路径

**R-02 (8h) → R-01 (12h) + R-04 (14h)** — 最长 P0 链
**R-03 (14h)** 与上述并行，但阻塞 3 个下游需求

### 风险评估

| 风险 | 需求 | 等级 | 缓解方案 |
|------|------|------|---------|
| Glitch 腐蚀叠加架构新 Pattern | R-03 | 🔴 高 | 提前建立 Modifier 交互测试矩阵；保守 λ=0.15/s 起步 |
| 终局 Boss 四阶段平衡 | R-04 | 🔴 高 | 先做 Stage 1+2 验证手感，再加 3+4；可用 3 阶段降级 |
| 生成曲线调参迭代 | R-02 | 🟡 中 | R-05 紧随其后防碎片刷屏；调试覆盖层显示实时分布 |
| 中 Boss 多文件集成 | R-01 | 🟡 中 | 严格分层实现：state → spawn → drop → wave → UI |

---

## 10. 待确认问题

1. **中 Boss 视觉设计** — 中 Boss 使用什么形状/颜色区别于普通敌人和终局 Boss？（当前建议：六边形 + 橙色，普通敌人为三角形/方形，终局 Boss 为大八边形 + 红色）
2. **阶段切换播报文案** — R-12 的 "Phase 2/3/4" 是否需要 i18n？还是用通用符号？
3. **竞技场压缩实现** — Stage 4 的 10% 压缩是缩小竞技场边界还是视觉缩放？需要确认引擎支持哪种
4. **Glitch 视觉开裂** — R-13 的裂纹是固定位置还是随机生成？是否需要动画？
5. **P2 优先级排序** — 如果时间只够做 2 个 P2，哪 2 个优先？建议 R-12（阶段播报）+ R-14（击杀计数器）

---

## ✅ 行动清单

| # | 行动 | 负责方 | 时间窗 |
|---|------|--------|--------|
| 1 | 下发 Week 1 任务包（R-02/R-03/R-05/R-06）给 CodeBuddy | 方向明 | 2026-08-03 |
| 2 | 实施 R-02 加权生成分布 | CodeBuddy | Week 1 |
| 3 | 实施 R-03 Glitch 帧率独立修复 | CodeBuddy | Week 1 |
| 4 | 实施 R-05 碎片上限 | CodeBuddy | Week 1 |
| 5 | 实施 R-06 动态敌人上限 | CodeBuddy | Week 1 |
| 6 | Week 1 回归测试 + 报告 | CodeBuddy → 方向明 | Week 1 末 |
| 7 | 评审 Week 1 产出 + 下发 Week 2 任务包 | 方向明 | Week 2 初 |
| 8 | 实施 R-01 中 Boss 遭遇 | CodeBuddy | Week 2 |
| 9 | 实施 R-04 终局 Boss HP 升级 | CodeBuddy | Week 2-3 |
| 10 | 实施 R-07/R-08 波次调参 | CodeBuddy | Week 2.5-3 |
| 11 | 实施 R-09/R-10/R-11 UI 反馈 | CodeBuddy | Week 3.5 |
| 12 | M2 完整回归 + 发布 | CodeBuddy → 方向明 | Week 3.5 |

---

## ⚠️ 待确认 / 假设 / Non-goals

**假设：**
- TapTap Maker 引擎支持竞技场边界动态调整（R-04 Stage 4 压缩）
- `UI.Panel` 系统支持 alpha 动画和定时器回调（R-10/R-11 闪烁效果）
- 当前 Lua 运行时性能足以支撑 30 个敌人 + 3 个并发闪烁 + Glitch 腐蚀叠加

**Non-goals（重申）：**
- 不扩展模块/武器池
- 不做难度选择
- 不做社交/排行榜功能
- 不做新美术资源（复用现有 Neon Vector Geometry 风格）

---

## 📚 数据来源 & 成员产出索引

- **析客（requirement-analyst）**：15 项需求规格（R-01~R-15），文件影响分析，P0/P1/P2 分级
- **瑞思（user-researcher）**：用户研究综合 — Splitter 时机建议（W3）、Boss 战时长预期、Glitch 反馈缺失洞察、Modifier 叠加期望
- **竞析（competitive-analyst）**：5 款竞品 Boss 战基准 — 类型标准 30-90s、HP 100-800 区间、多阶段标配；Glitch/混乱机制叠加 vs 替换对比
- **数析（data-analyst）**：当前游戏指标 — Boss 击杀 ~9s、Glitch 2%/帧帧率依赖、24 敌人硬编码；Boss HP 演化决策链（80→200→300）
- **路径（roadmap-planner）**：三阶段实施计划、PERT 工时估算（P0 53h / P0+P1 71h / Full 85h）、依赖图、4 项风险评估、3 级里程碑定义
- **方向明（product helmsman）**：团队编排、Boss HP 三轮迭代决策、参数修正终值、最终汇编

---

> 本报告由产品战略团队 AI 协作生成，重要决策请由产品负责人审定。
