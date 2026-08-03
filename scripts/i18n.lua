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
        ["menu.footer"] = "几何突围 · Prototype 03", ["game.integrity"] = "完整度：%d / %d",
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
        ["game.defeated"] = "突围失败", ["game.summary"] = "运行总结", ["game.reason"] = "原因：%s",
        ["game.final_score"] = "最终击破：%d", ["game.final_wave"] = "抵达波次：%d", ["game.final_level"] = "最终等级：%d",
        ["game.final_module"] = "装配模块：%s Lv.%d", ["game.final_fragments"] = "数据碎片：%d",
        ["game.restart"] = "重新开始", ["game.back"] = "返回语言选择", ["game.reason_contact"] = "与敌对几何体发生碰撞", ["game.reason_complete"] = "完成全部波次",
        ["game.modifier"] = "场域：%s", ["modifier.compression"] = "压缩：内圈移动边界", ["modifier.surge"] = "涌潮：周期性场域脉冲", ["modifier.overclock"] = "超频：敌人更快，奖励更高",
        ["enemy.chaser"] = "追猎体", ["enemy.skimmer"] = "掠行体", ["enemy.charger"] = "蓄能体", ["game.modules"] = "活动模块：%s", ["game.telegraph"] = "警告：场域脉冲",
        ["meta.archive"] = "校准档案", ["meta.title"] = "校准档案（本次会话）", ["meta.currency"] = "校准片：%d", ["meta.integrity"] = "起始完整度 +1", ["meta.magnet"] = "磁吸范围 +35", ["meta.upgrade"] = "校准", ["meta.fallback"] = "未验证持久化：仅在本次会话有效", ["meta.close"] = "返回",
    },
    en = {
        ["menu.title"] = "Geometry Breakout", ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Calibration deck online. Ready to break out.", ["menu.start"] = "Start Breakout",
        ["menu.footer"] = "Geometry Breakout · Prototype 03", ["game.integrity"] = "Integrity: %d / %d",
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
        ["game.defeated"] = "Breakout Failed", ["game.summary"] = "Run Summary", ["game.reason"] = "Cause: %s",
        ["game.final_score"] = "Final defeated: %d", ["game.final_wave"] = "Wave reached: %d", ["game.final_level"] = "Final level: %d",
        ["game.final_module"] = "Equipped module: %s Lv.%d", ["game.final_fragments"] = "Data Fragments: %d",
        ["game.restart"] = "Restart", ["game.back"] = "Back to language selection", ["game.reason_contact"] = "Collision with a hostile form", ["game.reason_complete"] = "All waves completed",
        ["game.modifier"] = "Field: %s", ["modifier.compression"] = "Compression: inner movement bounds", ["modifier.surge"] = "Surge: periodic arena pulse", ["modifier.overclock"] = "Overclock: faster enemies, richer drops",
        ["enemy.chaser"] = "Chaser", ["enemy.skimmer"] = "Skimmer", ["enemy.charger"] = "Charger", ["game.modules"] = "Active modules: %s", ["game.telegraph"] = "WARNING: arena surge",
        ["meta.archive"] = "Calibration Archive", ["meta.title"] = "Calibration Archive (session)", ["meta.currency"] = "Calibration: %d", ["meta.integrity"] = "+1 starting Integrity", ["meta.magnet"] = "+35 magnet range", ["meta.upgrade"] = "Calibrate", ["meta.fallback"] = "Persistence unverified: session fallback only", ["meta.close"] = "Back",
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
