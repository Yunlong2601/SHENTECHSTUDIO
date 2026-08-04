-- i18n.lua
-- Bilingual text lookup. Source of truth for all in-game strings.
-- i18n/*.json in the repo is a build-tool-managed mirror of M.TEXT and must stay in sync.
-- Usage:
--   local i18n = require("i18n")
--   i18n.get(lang, key, ...)  -- returns formatted string for the given language + key

local M = {}

---@type table<string, table<string, string>>
M.TEXT = {
    zh_CN = {
        ["menu.title"] = "几何突围", ["menu.subtitle"] = "选择语言开始游戏",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "校准台已上线，准备开始突围。", ["menu.start"] = "开始突围",
        ["menu.footer"] = "几何突围 · Demo Build", ["game.integrity"] = "完整度：%d / %d",
        ["game.time"] = "突围时间：%ds", ["game.score"] = "击破：%d", ["game.wave"] = "波次：%d / %d",
        ["game.progress"] = "模式碎片：%d / %d", ["game.fragments"] = "数据碎片：%d", ["game.next_upgrade"] = "距离下一次升级：%d 个模式碎片", ["game.stats"] = "当前状态",
        ["game.module"] = "模块：%s Lv.%d", ["game.none"] = "未装配", ["game.enemy"] = "敌对几何体",
        ["game.elite"] = "精英核心", ["game.hint"] = "WASD / 方向键移动 · 自动模块锁定目标", ["game.mobile_hint"] = "触摸左侧并拖动移动 · 自动攻击",

        ["game.wave_pause"] = "波次校准完成", ["game.wave_next"] = "下一波：%d", ["game.continue"] = "继续突围",
        ["game.level_up"] = "升级：选择一项校准", ["game.level"] = "等级 %d",
        ["module.trace"] = "Trace Beam · 轨迹光束", ["module.trace_desc"] = "更快、更强的窄束自动追踪光束",
        ["module.orbit"] = "Orbit Seed · 环轨种子", ["module.orbit_desc"] = "旋转种子持续撞击附近敌人",
        ["module.pulse"] = "Pulse Bloom · 脉冲绽放", ["module.pulse_desc"] = "周期性释放圆形脉冲，击退并伤害敌人",
        ["module.shell"] = "Shell Lantern · 护壳灯", ["module.shell_desc"] = "可再生护盾壳体，优先承受完整度伤害",
        ["module.mine"] = "Anchor Mine · 锚雷", ["module.mine_desc"] = "周期性部署地雷，敌人靠近时引爆并造成范围伤害",
        ["module.hook"] = "Vector Hook · 矢量钩", ["module.hook_desc"] = "留下持续伤害的移动轨迹",
        ["upgrade.trace"] = "强化轨迹光束", ["upgrade.orbit"] = "强化环轨种子", ["upgrade.pulse"] = "强化脉冲绽放", ["upgrade.shell"] = "强化护壳灯",
        ["upgrade.mine"] = "强化锚雷", ["upgrade.hook"] = "强化矢量钩",
        ["upgrade.integrity"] = "加固完整度", ["upgrade.magnet"] = "扩大磁吸范围", ["upgrade.desc"] = "获得一项永久运行强化",
        ["game.defeated"] = "突围失败", ["game.victory"] = "突围成功", ["game.summary"] = "运行总结", ["game.reason"] = "原因：%s",
        ["game.final_score"] = "最终击破：%d", ["game.final_wave"] = "抵达波次：%d", ["game.final_level"] = "最终等级：%d",
        ["game.final_module"] = "装配模块：%s Lv.%d", ["game.final_fragments"] = "数据碎片：%d",
        ["game.restart"] = "重新开始", ["game.back"] = "返回主菜单", ["game.reason_contact"] = "与敌对几何体发生碰撞", ["game.reason_complete"] = "击破最终核心，完成全部波次",
        ["game.modifier"] = "场域：%s", ["modifier.compression"] = "压缩：内圈移动边界", ["modifier.surge"] = "涌潮：周期性场域脉冲", ["modifier.overclock"] = "超频：敌人更快，奖励更高",
        ["enemy.chaser"] = "追猎体", ["enemy.skimmer"] = "掠行体", ["enemy.charger"] = "蓄能体", ["enemy.splitter"] = "分裂体", ["enemy.shooter"] = "射击体", ["game.modules"] = "活动模块：%s", ["game.weapons"] = "武器：%s", ["weapon.melee"] = "近战", ["weapon.ranged"] = "远程", ["game.telegraph"] = "警告：场域脉冲",
        ["game.shell"] = "护壳：%d / %d",
        ["module.laser"] = "Laser Gun · 激光炮", ["module.laser_desc"] = "高伤害穿透激光束，瞄准最近敌人",
        ["module.poison"] = "Poison Bomb · 毒雾弹", ["module.poison_desc"] = "部署持续伤害毒云，造成范围伤害",
        ["upgrade.laser"] = "强化激光炮", ["upgrade.poison"] = "强化毒雾弹",
        ["meta.archive"] = "校准档案", ["meta.title"] = "校准档案（本次会话）", ["meta.currency"] = "校准片：%d", ["meta.integrity"] = "起始完整度 +1", ["meta.magnet"] = "磁吸范围 +35", ["meta.upgrade"] = "校准", ["meta.fallback"] = "未验证持久化：仅在本次会话有效", ["meta.close"] = "返回",

        ["boss.name"] = "核心破坏者", ["boss.bar"] = "核心：%d / %d", ["boss.telegraph"] = "警告：核心脉冲蓄能", ["boss.spawn"] = "核心破坏者出现", ["boss.defeated"] = "核心破坏者已被击破",
        ["game.boss_wave"] = "最终波次：核心战", ["game.reason_boss"] = "被核心破坏者击破",
        ["midboss.name"] = "守门者", ["midboss.bar"] = "守门者：%d / %d", ["midboss.spawn"] = "守门者出现", ["midboss.defeated"] = "守门者已被击破",

        ["stage.title"] = "选择竞技场", ["stage.subtitle"] = "不同阶段的场域配置不同，层层深入", ["stage.levels"] = "%d 个关卡",
        ["stage.name_tag"] = "%s", ["stage.level_tag"] = "关卡 %d · %d 波", ["stage.boss_tag"] = "⚠ 首领战",
        ["stage.midboss_tag"] = "◆ 精英战", ["stage.get_ready"] = "准备开始...",
        ["stage.cleared"] = "阶段通关！", ["stage.failed"] = "阶段失败",
        ["stage.unlocked"] = "已解锁：%s", ["stage.next_stage"] = "下一阶段 ▶",
        ["game.wave_info"] = "%s · Lv.%d · %d/%d 波",

        ["cosmetics.title"] = "工坊", ["cosmetics.subtitle"] = "外观定制 · 即将上线", ["cosmetics.skin_default"] = "矢量三角", ["cosmetics.skin_crimson"] = "猩红协议", ["cosmetics.skin_void"] = "虚空回路", ["cosmetics.skin_solar"] = "日冕引擎", ["cosmetics.locked"] = "未解锁", ["cosmetics.coming_soon"] = "即将上线", ["cosmetics.support"] = "支持开发者", ["cosmetics.support_desc"] = "未来可通过 TapTap 支持本项目", ["cosmetics.close"] = "返回主菜单",
        ["menu.workshop"] = "工坊",

        -- Brotato Transition (P2-P3)
        ["shop.title"] = "商店", ["shop.gold"] = "金币：%d",
        ["shop.reroll"] = "重摇 %dg", ["shop.lock"] = "锁定",
        ["shop.skip"] = "跳过 ▶", ["shop.weapons"] = "— 武器 —",
        ["shop.items"] = "— 道具 —", ["shop.timer"] = "%ds",
        ["currency.gold"] = "金币",
        ["stats.primary"] = "主要属性", ["stats.secondary"] = "次要属性",
        ["stats.hp"] = "生命", ["stats.dmg"] = "伤害", ["stats.spd"] = "攻速",
        ["stats.rng"] = "范围", ["stats.crt"] = "暴击", ["stats.ddg"] = "闪避",
        ["stats.mov"] = "移速", ["stats.lck"] = "幸运",
        ["stat.hp_name"] = "生命强化", ["stat.hp_desc"] = "最大生命 +2",
        ["stat.dmg_name"] = "伤害强化", ["stat.dmg_desc"] = "所有武器伤害 +8%",
        ["stat.spd_name"] = "攻速强化", ["stat.spd_desc"] = "攻击间隔 -4%",
        ["stat.rng_name"] = "范围强化", ["stat.rng_desc"] = "攻击距离 +5%",
        ["stat.crt_name"] = "暴击强化", ["stat.crt_desc"] = "暴击率 +4%",
        ["stat.ddg_name"] = "闪避强化", ["stat.ddg_desc"] = "闪避率 +4%",
        ["stat.mov_name"] = "移速强化", ["stat.mov_desc"] = "移动速度 +5%",
        ["stat.lck_name"] = "幸运强化", ["stat.lck_desc"] = "掉落金币 +15%",
    },
    en = {
        ["menu.title"] = "Geometry Breakout", ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Calibration deck online. Ready to break out.", ["menu.start"] = "Start Breakout",
        ["menu.footer"] = "Geometry Breakout · Demo Build", ["game.integrity"] = "Integrity: %d / %d",
        ["game.time"] = "Breakout time: %ds", ["game.score"] = "Defeated: %d", ["game.wave"] = "Wave: %d / %d",
        ["game.progress"] = "Pattern Shards: %d / %d", ["game.fragments"] = "Data Fragments: %d", ["game.next_upgrade"] = "%d Pattern Shards to next upgrade", ["game.stats"] = "Current status",
        ["game.module"] = "Module: %s Lv.%d", ["game.none"] = "Unassigned", ["game.enemy"] = "Hostile Form",
        ["game.elite"] = "Elite Core", ["game.hint"] = "WASD / arrows to move · module auto-locks targets", ["game.mobile_hint"] = "Touch and drag on the left side to move · auto-attacks",

        ["game.wave_pause"] = "Wave calibrated", ["game.wave_next"] = "Next wave: %d", ["game.continue"] = "Continue Breakout",
        ["game.level_up"] = "Level up: choose a calibration", ["game.level"] = "Level %d",
        ["module.trace"] = "Trace Beam", ["module.trace_desc"] = "A faster, stronger narrow auto-tracking beam",
        ["module.orbit"] = "Orbit Seed", ["module.orbit_desc"] = "A rotating seed that strikes nearby enemies",
        ["module.pulse"] = "Pulse Bloom", ["module.pulse_desc"] = "A periodic circular pulse that damages and pushes enemies",
        ["module.shell"] = "Shell Lantern", ["module.shell_desc"] = "Rechargeable shield that absorbs hits before Integrity",
        ["module.mine"] = "Anchor Mine", ["module.mine_desc"] = "Periodically deploys proximity mines that detonate and damage nearby enemies",
        ["module.hook"] = "Vector Hook", ["module.hook_desc"] = "Leaves a damaging trail behind the player that hurts enemies on contact",
        ["upgrade.trace"] = "Tune Trace Beam", ["upgrade.orbit"] = "Tune Orbit Seed", ["upgrade.pulse"] = "Tune Pulse Bloom", ["upgrade.shell"] = "Tune Shell Lantern",
        ["upgrade.mine"] = "Tune Anchor Mine", ["upgrade.hook"] = "Tune Vector Hook",
        ["upgrade.integrity"] = "Reinforce Integrity", ["upgrade.magnet"] = "Expand Magnet", ["upgrade.desc"] = "Gain one permanent run upgrade",
        ["game.defeated"] = "Breakout Failed", ["game.victory"] = "Breakout Complete", ["game.summary"] = "Run Summary", ["game.reason"] = "Cause: %s",
        ["game.final_score"] = "Final defeated: %d", ["game.final_wave"] = "Wave reached: %d", ["game.final_level"] = "Final level: %d",
        ["game.final_module"] = "Equipped module: %s Lv.%d", ["game.final_fragments"] = "Data Fragments: %d",
        ["game.restart"] = "Restart", ["game.back"] = "Back to main menu", ["game.reason_contact"] = "Collision with a hostile form", ["game.reason_complete"] = "Core Breaker destroyed — all waves cleared",
        ["game.modifier"] = "Field: %s", ["modifier.compression"] = "Compression: inner movement bounds", ["modifier.surge"] = "Surge: periodic arena pulse", ["modifier.overclock"] = "Overclock: faster enemies, richer drops",
        ["enemy.chaser"] = "Chaser", ["enemy.skimmer"] = "Skimmer", ["enemy.charger"] = "Charger", ["enemy.splitter"] = "Splitter", ["enemy.shooter"] = "Shooter", ["game.modules"] = "Active modules: %s", ["game.weapons"] = "Weapons: %s", ["weapon.melee"] = "Melee", ["weapon.ranged"] = "Ranged", ["game.telegraph"] = "WARNING: arena surge",
        ["game.shell"] = "Shell: %d / %d",
        ["module.laser"] = "Laser Gun", ["module.laser_desc"] = "High-damage piercing laser aimed at the nearest enemy",
        ["module.poison"] = "Poison Bomb", ["module.poison_desc"] = "Deploys a damaging poison cloud dealing area damage over time",
        ["upgrade.laser"] = "Tune Laser Gun", ["upgrade.poison"] = "Tune Poison Bomb",
        ["meta.archive"] = "Calibration Archive", ["meta.title"] = "Calibration Archive (session)", ["meta.currency"] = "Calibration: %d", ["meta.integrity"] = "+1 starting Integrity", ["meta.magnet"] = "+35 magnet range", ["meta.upgrade"] = "Calibrate", ["meta.fallback"] = "Persistence unverified: session fallback only", ["meta.close"] = "Back",

        ["boss.name"] = "Core Breaker", ["boss.bar"] = "Core: %d / %d", ["boss.telegraph"] = "WARNING: core pulse charging", ["boss.spawn"] = "Core Breaker has appeared", ["boss.defeated"] = "Core Breaker destroyed",
        ["game.boss_wave"] = "Final Wave: Boss Encounter", ["game.reason_boss"] = "Destroyed by the Core Breaker",
        ["midboss.name"] = "Gatekeeper", ["midboss.bar"] = "Gatekeeper: %d / %d", ["midboss.spawn"] = "Gatekeeper has appeared", ["midboss.defeated"] = "Gatekeeper destroyed",

        ["stage.title"] = "Select Arena", ["stage.subtitle"] = "Unique field configurations per stage, going deeper", ["stage.levels"] = "%d levels",
        ["stage.name_tag"] = "%s", ["stage.level_tag"] = "Level %d · %d waves", ["stage.boss_tag"] = "⚠ Boss Fight",
        ["stage.midboss_tag"] = "◆ Elite Fight", ["stage.get_ready"] = "Get Ready...",
        ["stage.cleared"] = "Stage Cleared!", ["stage.failed"] = "Stage Failed",
        ["stage.unlocked"] = "Unlocked: %s", ["stage.next_stage"] = "Next Stage ▶",
        ["game.wave_info"] = "%s · Lv.%d · %d/%d waves",

        ["cosmetics.title"] = "Workshop", ["cosmetics.subtitle"] = "Cosmetic Skins · Coming Soon", ["cosmetics.skin_default"] = "Vector Triangle", ["cosmetics.skin_crimson"] = "Crimson Protocol", ["cosmetics.skin_void"] = "Void Circuit", ["cosmetics.skin_solar"] = "Solar Engine", ["cosmetics.locked"] = "Locked", ["cosmetics.coming_soon"] = "Coming Soon", ["cosmetics.support"] = "Support the Developer", ["cosmetics.support_desc"] = "Future TapTap support option", ["cosmetics.close"] = "Back to main menu",
        ["menu.workshop"] = "Workshop",

        -- Brotato Transition (P2-P3)
        ["shop.title"] = "SHOP", ["shop.gold"] = "Gold: %d",
        ["shop.reroll"] = "REROLL %dg", ["shop.lock"] = "LOCK",
        ["shop.skip"] = "SKIP ▶", ["shop.weapons"] = "— WEAPONS —",
        ["shop.items"] = "— ITEMS —", ["shop.timer"] = "%ds",
        ["currency.gold"] = "Gold",
        ["stats.primary"] = "PRIMARY", ["stats.secondary"] = "SECONDARY",
        ["stats.hp"] = "HP", ["stats.dmg"] = "DMG", ["stats.spd"] = "SPD",
        ["stats.rng"] = "RNG", ["stats.crt"] = "CRT", ["stats.ddg"] = "DDG",
        ["stats.mov"] = "MOV", ["stats.lck"] = "LCK",
        ["stat.hp_name"] = "Vitality Up", ["stat.hp_desc"] = "+2 Max HP",
        ["stat.dmg_name"] = "Damage Up", ["stat.dmg_desc"] = "+8% weapon damage",
        ["stat.spd_name"] = "Speed Up", ["stat.spd_desc"] = "-4% attack cooldown",
        ["stat.rng_name"] = "Range Up", ["stat.rng_desc"] = "+5% weapon range",
        ["stat.crt_name"] = "Crit Up", ["stat.crt_desc"] = "+4% critical chance",
        ["stat.ddg_name"] = "Dodge Up", ["stat.ddg_desc"] = "+4% dodge chance",
        ["stat.mov_name"] = "Agility Up", ["stat.mov_desc"] = "+5% move speed",
        ["stat.lck_name"] = "Luck Up", ["stat.lck_desc"] = "+15% gold from drops",
    },
}

---Look up a translation key in the given language, with optional printf-style formatting.
---@param lang string  -- "zh_CN" or "en"
---@param key string   -- e.g. "menu.title"
---@param ... any      -- optional format args (passed to string.format)
---@return string
function M.get(lang, key, ...)
    local languageText = M.TEXT[lang] or M.TEXT.zh_CN
    local value = languageText[key] or M.TEXT.zh_CN[key] or key
    if select("#", ...) > 0 then return string.format(value, ...) end
    return value
end

return M
