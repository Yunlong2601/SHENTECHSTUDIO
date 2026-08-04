# 设计决策记录

> 仅记录长期有效的设计或架构决策。每日开发记录不放在这里。

---

## DEC-001：Brotato 风格转型

- **日期**: 2026-08-04
- **状态**: Accepted
- **决策**: 从 8 模块手动施放技能系统转型为 Brotato 风格 — 6 武器槽自动开火 + 每波后商店升级
- **原因**: 更成熟的已验证玩法循环；降低操作复杂度；商店经济增加策略深度
- **影响范围**: 全部系统 — 武器、敌人、UI、经济、属性
- **相关文件**: GAME_DESIGN.md, ARCHITECTURE.md, SHOP_SPEC.md, ECONOMY.md, STATS_SPEC.md
- **何时重新讨论**: 如果 playtest 反馈证明 Brotato 风格不适合目标用户群

---

## DEC-002：Neon Vector Geometry 视觉风格

- **日期**: 2026-08-03（项目早期）
- **状态**: Accepted
- **决策**: 采用几何霓虹风格 — 纯色几何形状 + 发光描边 + 深色背景
- **原因**: 独特视觉辨识度；低成本（无需精灵/骨骼动画）；契合"几何突围"主题
- **影响范围**: 全部美术、UI 设计
- **相关文件**: ART_STYLE.md
- **何时重新讨论**: 如果 TapTap 用户反馈视觉疲劳或需要更高品质美术

---

## DEC-003：玩家角色与怪物视觉区分

- **日期**: 2026-08-04（P4 实现时确定）
- **状态**: Accepted
- **决策**: 玩家角色使用 diamond（菱形）身体 + 眼睛 + 面部横条 + 拖尾，与纯几何怪物明确区分
- **原因**: 避免在密集弹幕中混淆玩家和怪物
- **影响范围**: character.lua, enemies.lua
- **相关文件**: ART_STYLE.md, GAME_DESIGN.md
- **何时重新讨论**: 如果玩家反馈仍难以区分

---

## DEC-004：TapTap Maker main 为主源，GitHub 为镜像

- **日期**: 2026-08-04
- **状态**: Accepted
- **决策**: 所有推送先到 TapTap Maker remote (origin)，再同步到 GitHub (github)
- **原因**: TapTap Maker 自动同步配置文件（.meta / i18n cache）；Maker 是构建和运行时源
- **影响范围**: 部署流程
- **相关文件**: ARCHITECTURE.md, PROJECT_CONTEXT.md
- **何时重新讨论**: 如果迁移到非 TapTap Maker 构建流程

---

## DEC-005：武器稀有度分级

- **日期**: 2026-08-04（P4 实现时确定）
- **状态**: Accepted
- **决策**: 3 级稀有度 — Common / Uncommon / Legendary，影响基础伤害和特殊效果
- **原因**: 增加商店决策深度；Legendary 武器提供构筑锚点
- **影响范围**: weapons.lua, shop.lua
- **相关文件**: GAME_DESIGN.md, SHOP_SPEC.md
- **何时重新讨论**: 如果 3 级不足以支撑后期内容深度

---

## DEC-006：8 属性轴设计

- **日期**: 2026-08-04（P2 设计时确定）
- **状态**: Accepted
- **决策**: HP / DMG / SPD / RNG / CRT / DDG / MOV / LCK，每属性有独立颜色和效果公式
- **原因**: Brotato 验证过的属性体系；足够深度且不过于复杂
- **影响范围**: stats_panel.lua, shop.lua, 全部战斗计算
- **相关文件**: STATS_SPEC.md
- **何时重新讨论**: playtest 发现某属性无用或某属性过强
