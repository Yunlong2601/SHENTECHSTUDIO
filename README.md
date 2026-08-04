# 几何突围 / Geometry Breakout 🎯

> **一句话定位**：Brotato 风格俯视角几何霓虹生存 Roguelite — 6 武器槽自动开火、每波后商店升级、20 波 ~20 分钟一局。

**当前阶段**：P0-P9 全部完成 — 完整 Brotato 游戏循环可运行。
**平台**：TapTap 中国区优先 → 未来 Steam
**引擎**：TapTap Maker (UrhoX) / Lua 5.4

---

## 核心玩法

1. **自动战斗** — 6 武器槽自动索敌射击
2. **波次生存** — 20 波递增难度，每波 ~30 秒
3. **商店经济** — 每波间进商店：买武器/属性道具、重刷、锁定、回收
4. **属性构筑** — 8 属性轴：HP / DMG / SPD / RNG / CRT / DDG / MOV / LCK
5. **Neon Vector Geometry** — 几何霓虹视觉风格

---

## 目录地图

```
taptapgame/
├── scripts/          ← 游戏 Lua 源码（13 .lua）
├── data/             ← 外部化游戏数据
├── project-source/   ← 📖 游戏设计文档（权威来源）
├── deliverables/     ← 发布材料 / 研究 / 策略
├── docs/             ← 📋 文档导航中心（从这里开始）
├── i18n/             ← 多语言翻译
├── archive/          ← 旧引擎参考
├── engine-docs/      ← 引擎文档（只读）
├── urhox-libs/       ← 引擎库（只读）
└── .workbuddy/       ← AI 工作记忆（只读）
```

---

## 文档阅读入口

**新成员 / AI Agent → 从 `docs/INDEX.md` 开始**

| 想做什么 | 先读 |
|---------|------|
| 了解项目 | `project-source/CONTEXT.md` |
| 改玩法/武器/敌人 | `project-source/GAME_DESIGN.md` |
| 改数值/属性 | `project-source/STATS_SPEC.md` |
| 改商店/经济 | `project-source/SHOP_SPEC.md` + `ECONOMY.md` |
| 改 UI/美术 | `project-source/UI_LAYOUT.md` + `ART_STYLE.md` |
| 改 Lua 架构 | `project-source/ARCHITECTURE.md` |
| 查看进度 | `project-source/ROADMAP.md` |
| 不确定术语 | `project-source/TERMINOLOGY.md` |

---

## 快速链接

- **GitHub**: [Yunlong2601/SHENTECHSTUDIO](https://github.com/Yunlong2601/SHENTECHSTUDIO)
- **完整设计**: `project-source/GAME_DESIGN.md`
- **文档地图**: `docs/INDEX.md`
- **Agent 规则**: `AGENTS.md`
