# 系统模块关系图

> 基于 2026-08-04 实际 Lua 文件和 ARCHITECTURE.md。
> 不确定行为标注「待确认」。

---

## 模块一览

| 模块 | 文件 | 职责 | 主要依赖 | 高风险修改点 | 相关规格 |
|------|------|------|---------|-------------|---------|
| **主调度** | `scripts/main.lua` | 入口：每帧调度各子系统更新 | weapons, character, enemies, player, ui, shop, waves | 修改 update 顺序可能引起时序 bug | ARCHITECTURE |
| **武器系统** | `scripts/weapons.lua` | 6 武器类型 / 6 槽位 / 自动索敌开火 | state (weapons_) | 武器平衡数值 | GAME_DESIGN, STATS_SPEC |
| **角色渲染** | `scripts/character.lua` | 玩家角色可视化：diamond 身体 + 眼睛 + 拖尾 | state (charWidgets_) | 视觉区分度 | ART_STYLE |
| **玩家控制** | `scripts/player.lua` | 移动 / 碰撞 / 速度追踪 | — | 碰撞精度 | GAME_DESIGN |
| **敌人系统** | `scripts/enemies.lua` | 生成 / 伤害 / 弹幕 / onHitAoE | waves (波次信息) | 弹幕模式 / 性能 | GAME_DESIGN, STATS_SPEC |
| **波次管理** | `scripts/waves.lua` | 波次生成规则 / 难度递增 | enemies | 难度曲线 | GAME_DESIGN, ROADMAP |
| **关卡数据** | `scripts/stages.lua` | 关卡/波次数据定义 | waves | 数据格式 | GAME_DESIGN |
| **共享状态** | `scripts/state.lua` | 全局状态：weapons_, charWidgets_, gold_ | — | 状态结构变更（影响所有模块） | ARCHITECTURE |
| **商店** | `scripts/shop.lua` | 购买/重刷/锁定/回收 UI | state (gold_), stats_panel, weapons | 价格公式 | SHOP_SPEC, ECONOMY |
| **属性面板** | `scripts/stats_panel.lua` | 8 属性显示 UI | state (stats) | 属性颜色映射 | STATS_SPEC |
| **通用 UI** | `scripts/ui.lua` | 通用 UI 组件 | — | — | UI_LAYOUT |
| **特效** | `scripts/vfx.lua` | 视觉效果 | — | 待确认 | ART_STYLE |
| **外部数据** | `data/` | 武器/敌人/波次 外部化数据 | — | 数据格式 | GAME_DESIGN |

---

## 更新管线

```
main.lua
  ├── player.update()          ← 玩家输入 + 移动
  ├── weapons.update()         ← 自动索敌 + 开火（使用 state.weapons_）
  ├── character.update()       ← 角色渲染（使用 state.charWidgets_）
  ├── enemies.update()         ← 生成 + AI + 碰撞
  ├── waves.update()           ← 波次计时 + 触发
  ├── shop.update()            ← 商店界面（波间）
  └── ui.update()              ← 通用 UI
```

---

## 数据流

```
waves.lua → enemies.lua (生成参数)
         → stages.lua (关卡数据)

weapons.lua → state.lua (武器状态)
            → enemies.lua (伤害输出)

shop.lua → state.lua (金币消耗)
        → weapons.lua (武器购买)
        → stats_panel.lua (属性升级)

enemies.lua → state.lua (金币掉落)
```

---

## 修改风险矩阵

| 修改目标 | 影响范围 | 风险等级 |
|---------|---------|---------|
| state.lua 数据结构 | 全部模块 | 🔴 高 |
| main.lua update 顺序 | 全部模块 | 🔴 高 |
| weapons.lua 伤害公式 | enemies, shop | 🟡 中 |
| enemies.lua 弹幕模式 | 性能 | 🟡 中 |
| shop.lua 价格/机制 | economy 平衡 | 🟡 中 |
| character.lua 渲染 | 仅视觉效果 | 🟢 低 |
| ui.lua 组件 | 仅 UI 层 | 🟢 低 |
