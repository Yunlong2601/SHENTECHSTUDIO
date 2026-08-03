# Week 1 Task Package — Spawn System Foundation

**下发人**: 方向明（产品舵手）
**执行方**: CodeBuddy
**周次**: Week 1 (Phase 1)
**需求覆盖**: R-02, R-03, R-05, R-06
**预估工时**: 27h + 6h 集成测试 = 33h

---

## 概述

本周目标是重建生成系统基础：加权随机分布、Glitch 帧率独立修复（含腐蚀叠加架构）、碎片上限和动态敌人上限。这四个需求是 M2 后续所有 Boss 遭遇和波次调参的基础。

**执行顺序**：R-02 和 R-03 可并行 → R-05 紧随 R-02 → R-06 紧随 R-02

---

## R-02: 加权生成分布

### 当前代码（`scripts/enemies.lua` 第 12-25 行）

```lua
function M.kind_for_id(enemyId, wave)
    if wave >= 5 then
        local cycle = (enemyId + wave) % 5
        if cycle == 0 then return "chaser" end
        if cycle == 1 then return "skimmer" end
        if cycle == 2 then return "charger" end
        if cycle == 3 then return "splitter" end
        return "shooter"
    end
    local cycle = (enemyId + wave) % 3
    if cycle == 0 then return "chaser" end
    if cycle == 1 then return "skimmer" end
    return "charger"
end
```

### 改动要求

将 `kind_for_id()` 从等概率取模改为**加权随机**，并调整敌人引入时机：

| 波次 | 可用敌人类型 | 权重分配 |
|------|-------------|---------|
| W1-2 | Chaser, Skimmer | Chaser 55% / Skimmer 45% |
| W3-4 | + Charger, Splitter | Chaser 35% / Skimmer 25% / Charger 20% / Splitter 10% (剩余10%给Chaser) |
| W5+ | + Shooter | Chaser 30% / Skimmer 22% / Charger 15% / Splitter 10% / Shooter 23% |

**关键变更**：
- Splitter 从 Wave 5 提前到 **Wave 3** 引入（避免与 W4 中 Boss 叠加导致信息过载）
- Shooter 保持 **Wave 5** 引入
- 使用 `math.random()` 做加权随机，不再用 `enemyId` 取模

### 实现参考

```lua
function M.kind_for_id(enemyId, wave)
    local weights = {}
    if wave <= 2 then
        weights = { chaser = 55, skimmer = 45 }
    elseif wave <= 4 then
        weights = { chaser = 35, skimmer = 25, charger = 20, splitter = 10, chaser_extra = 10 }
    else
        weights = { chaser = 30, skimmer = 22, charger = 15, splitter = 10, shooter = 23 }
    end
    -- 归一化并加权随机
    local total = 0
    for _, w in pairs(weights) do total = total + w end
    local roll = math.random() * total
    local cumulative = 0
    for kind, w in pairs(weights) do
        local k = kind == "chaser_extra" and "chaser" or kind
        cumulative = cumulative + w
        if roll <= cumulative then return k end
    end
    return "chaser"
end
```

> 注意：上面 `chaser_extra` 是把额外 10% 合并到 chaser 的技巧。也可以直接算好最终权重 `chaser = 45`。选择你认为更清晰的方式。

### 验收标准

- [ ] Wave 1-2 只生成 Chaser 和 Skimmer
- [ ] Wave 3 开始出现 Splitter
- [ ] Wave 5 开始出现 Shooter
- [ ] 任何波次不会出现单一敌人类型占比超过 50%
- [ ] 多次运行同一波次，敌人组合有随机变化（不等概率）
- [ ] Boss 的 minion 生成（`update_boss` 中第 234 行调用 `kind_for_id`）也使用新权重

---

## R-03: Glitch 帧率独立修复 + 腐蚀叠加架构

### 这是本周最复杂的需求，涉及 3 个文件

### 问题 1：帧率依赖

**当前代码**（`scripts/enemies.lua` 第 173 行）：
```lua
if isGlitch and math.random() < 0.02 then
    enemy.x = enemy.x + math.random(-12, 12)
    enemy.y = enemy.y + math.random(-12, 12)
end
```

`math.random() < 0.02` 是**每帧**判定，在 60fps 下触发率 ≈ 1.2/s，在 30fps 下 ≈ 0.6/s。需要改为 **delta-time Poisson 过程**。

### 问题 2：Glitch 替换而非叠加

**当前代码**（`scripts/waves.lua` 第 5-6 行）：
```lua
function M.modifier_for_wave(wave)
    if wave >= 7 then return "glitch" end
    ...
end
```

Wave 7-8 直接把 modifier 设为 "glitch"，**替换**了本应有的 compression/surge/overclock。需要改为：Glitch 是一个**腐蚀叠加层**，在基础 Modifier 之上运作。

### 改动 1：`scripts/state.lua` — 新增 Glitch 状态字段

在 Boss state 区块后（约第 194 行后）新增：

```lua
-- ─── Glitch corruption state ────────────────────────────────────────────
---@type boolean  -- 当前波次是否为 Glitch 波（W7+）
M.glitchWave_ = false
---@type boolean  -- Glitch 脉冲当前是否激活
M.glitchActive_ = false
---@type number   -- Glitch 脉冲计时器（正=激活倒计时，负=间歇倒计时）
M.glitchPulseTimer_ = 0
---@type number   -- 当前并发闪烁计数（最多3）
M.glitchFlickerCount_ = 0
---@type number   -- 动态敌人上限（普通波30，Glitch波25）
M.maxEnemies_ = 30
```

### 改动 2：`scripts/waves.lua` — Glitch 改为叠加层

```lua
function M.modifier_for_wave(wave)
    -- Wave 7+ 不再返回 "glitch"；Glitch 变为叠加层
    -- 基础 modifier 继续按周期循环
    local cycle = (wave - 1) % 3
    if cycle == 0 then return "compression" end
    if cycle == 1 then return "surge" end
    return "overclock"
end

function M.is_glitch_wave(wave)
    return wave >= 7
end

function M.is_boss_wave(wave)
    return wave >= state.maxWaves_
end
```

在 `begin_wave()` 中设置 glitch 波标记：

```lua
function M.begin_wave()
    state.screen_ = state.SCREEN_GAME
    state.modifier_ = M.modifier_for_wave(state.wave_)
    state.surgeTimer_, state.waveTime_, state.waveSpawned_, state.spawnTimer_ = 2.5, 0, 0, 0
    -- Glitch 波标记
    state.glitchWave_ = M.is_glitch_wave(state.wave_)
    state.glitchActive_ = false
    state.glitchPulseTimer_ = 0
    -- 动态敌人上限
    state.maxEnemies_ = state.glitchWave_ and 25 or 30
    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    else
        state.waveSpawnTarget_ = 8 + state.wave_ * 3
    end
end
```

### 改动 3：`scripts/enemies.lua` — Glitch 脉冲 + 腐蚀叠加

在 `M.update(timeStep)` 函数开头（第 141 行后）添加 Glitch 脉冲更新：

```lua
function M.update(timeStep)
    local bound = state.modifier_ == "compression" and 70 or 0; local player = p()
    local isGlitchWave = state.glitchWave_

    -- Glitch 脉冲计时（帧率独立 Poisson 替代旧 per-frame random）
    if isGlitchWave then
        state.glitchPulseTimer_ = state.glitchPulseTimer_ - timeStep
        if state.glitchPulseTimer_ <= 0 then
            if state.glitchActive_ then
                -- 从激活切换到间歇
                state.glitchActive_ = false
                state.glitchPulseTimer_ = 1.5 + math.random() * 0.5  -- 1.5-2s 间歇
                state.glitchFlickerCount_ = 0
            else
                -- 从间歇切换到激活
                state.glitchActive_ = true
                state.glitchPulseTimer_ = 1.5  -- 1.5s 激活
            end
        end
    end
    local glitchActive = state.glitchActive_
```

然后将第 173 行的旧 Glitch 逻辑替换为腐蚀叠加：

```lua
            -- 旧代码（删除）:
            -- if isGlitch and math.random() < 0.02 then
            --     enemy.x = enemy.x + math.random(-12, 12)
            --     enemy.y = enemy.y + math.random(-12, 12)
            -- end

            -- 新代码：Glitch 腐蚀叠加
            if glitchActive and state.glitchFlickerCount_ < 3 then
                -- Poisson 过程：λ≈0.18/s，帧率独立
                -- P(触发) = 1 - e^(-λ * dt)
                if math.random() < (1 - math.exp(-0.18 * timeStep)) then
                    state.glitchFlickerCount_ = state.glitchFlickerCount_ + 1
                    -- 腐蚀效果：基于当前 modifier 叠加
                    if state.modifier_ == "compression" then
                        -- 压缩边界抖动 ±18px
                        enemy.x = enemy.x + math.random(-18, 18)
                        enemy.y = enemy.y + math.random(-18, 18)
                    elseif state.modifier_ == "overclock" then
                        -- 加速波动：随机位移 + 短暂速度波动
                        enemy.x = enemy.x + math.random(-15, 15)
                        enemy.y = enemy.y + math.random(-15, 15)
                    elseif state.modifier_ == "surge" then
                        -- 浪涌扭曲：更大位移
                        enemy.x = enemy.x + math.random(-22, 22)
                        enemy.y = enemy.y + math.random(-22, 22)
                    else
                        -- 默认位移
                        enemy.x = enemy.x + math.random(-12, 12)
                        enemy.y = enemy.y + math.random(-12, 12)
                    end
                    -- 视觉闪烁（50ms 后由主循环重置）
                    enemy.widget:SetStyle({ opacity = 0.6 + math.random() * 0.4 })
                end
            end
```

同时需要在 `update()` 函数末尾（清理 dead 敌人之后，第 184 行后）添加闪烁计数衰减：

```lua
    -- 闪烁计数衰减（每帧减少，模拟 50ms 闪烁结束）
    if state.glitchFlickerCount_ > 0 and not state.glitchActive_ then
        state.glitchFlickerCount_ = 0
    end
    -- 重置非闪烁敌人的透明度
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead and enemy.widget then
            -- 恢复正常透明度（如果没在闪烁中）
            enemy.widget:SetStyle({ opacity = 1.0 })
        end
    end
```

> **注意**：上面的透明度恢复逻辑需要更精细 — 只有不在当前闪烁帧的敌人才恢复。如果性能有问题，可以用 enemy 上的 flag 标记闪烁状态而非每帧 SetStyle。根据实际测试调整。

### 改动 4：`scripts/waves.lua` `reset()` 函数也要同步

```lua
function M.reset()
    state.modifier_ = M.modifier_for_wave(state.wave_)
    state.waveSpawnTarget_ = 10
    state.wavePauseTimer_ = 0
    state.glitchWave_ = false
    state.glitchActive_ = false
    state.glitchPulseTimer_ = 0
    state.glitchFlickerCount_ = 0
    state.maxEnemies_ = 30
end
```

### 验收标准

- [ ] Wave 7-8 仍有基础 modifier（compression/surge/overclock 之一），不再是 "glitch"
- [ ] Glitch 以脉冲方式激活：1.5s 激活 → 1.5-2s 间歇 → 循环
- [ ] Glitch 激活时，当前 modifier 的效果被腐蚀（如 Compression 边界抖动 ±18px）
- [ ] Glitch 位移概率在 60fps 和 30fps 下一致（Poisson λ≈0.18/s）
- [ ] 最多 3 个敌人并发闪烁
- [ ] 闪烁时 enemy alpha 在 60-100% 之间
- [ ] 非 Glitch 波（W1-6）完全不受影响
- [ ] `state.modifier_` 在 W7-8 显示基础 modifier 而非 "glitch"

---

## R-05: 碎片上限

### 当前代码（`scripts/enemies.lua` 第 74-81 行）

```lua
function M.spawn_fragment(x, y)
    if not state.gameWorld_ or #state.enemies_ >= 24 then return end
    ...
end
```

### 改动要求

碎片上限改为 **8-10 个**，独立于总敌人上限。需要统计当前碎片数量：

```lua
function M.spawn_fragment(x, y)
    if not state.gameWorld_ then return end
    -- 统计当前碎片数
    local fragmentCount = 0
    for _, e in ipairs(state.enemies_) do
        if not e.dead and e.isFragment then fragmentCount = fragmentCount + 1 end
    end
    if fragmentCount >= 10 then return end  -- 碎片上限 10
    ...
end
```

### 验收标准

- [ ] 碎片数量永远不超过 10 个
- [ ] Splitter 死亡生成碎片时，如果已达上限则不再生成（静默跳过，不报错）
- [ ] 碎片上限独立于总敌人上限（碎片也计入总敌人数，但有自己的额外限制）

---

## R-06: 动态敌人上限

### 当前代码

- `scripts/enemies.lua` 第 28 行：`if not state.gameWorld_ or #state.enemies_ >= 24 or ...`
- `scripts/enemies.lua` 第 75 行：`if not state.gameWorld_ or #state.enemies_ >= 24 then return end`

### 改动要求

将硬编码的 `24` 替换为 `state.maxEnemies_`（已在 R-03 改动 1 中声明）：

**第 28 行**（`spawn()` 函数）：
```lua
function M.spawn(elite)
    if not state.gameWorld_ or #state.enemies_ >= state.maxEnemies_ or state.waveSpawned_ >= state.waveSpawnTarget_ then return end
    ...
end
```

**第 75 行**（`spawn_fragment()` 函数）：
```lua
function M.spawn_fragment(x, y)
    if not state.gameWorld_ or #state.enemies_ >= state.maxEnemies_ then return end
    ...
end
```

`state.maxEnemies_` 的值已在 `waves.lua` 的 `begin_wave()` 中设置：
- 普通波：30
- Glitch 波（W7+）：25

### 验收标准

- [ ] 普通波（W1-6）最多同时存在 30 个敌人
- [ ] Glitch 波（W7+）最多同时存在 25 个敌人
- [ ] `spawn_fragment()` 也使用动态上限
- [ ] Boss minion 生成（`update_boss` 中第 231 行 `#state.enemies_ < 12`）保持不变（Boss 有独立限制）

---

## 集成测试清单

完成以上 4 个需求后，执行以下测试：

1. **基础回归**：W1-8 完整通关，无 Lua 报错
2. **生成分布**：观察 W1-2 只有 Chaser/Skimmer，W3 出现 Splitter，W5 出现 Shooter
3. **Glitch 脉冲**：W7 观察 Glitch 以脉冲方式激活/间歇，而非持续
4. **Glitch 腐蚀**：W7 的基础 modifier（compression）在 Glitch 激活时边界抖动
5. **帧率独立**：在低帧率下 Glitch 触发频率不变（如果无法测帧率，至少逻辑上使用 Poisson 公式）
6. **碎片上限**：大量杀死 Splitter，碎片不超过 10 个
7. **敌人上限**：普通波最多 30，Glitch 波最多 25
8. **Boss 战**：W8 Boss 仍正常生成和战斗（minion 生成使用新 `kind_for_id`）

---

## 文件变更清单

| 文件 | 变更内容 | 涉及需求 |
|------|---------|---------|
| `scripts/enemies.lua` | 重写 `kind_for_id()`；重写 Glitch 逻辑；修改 `spawn()` 和 `spawn_fragment()` 上限 | R-02, R-03, R-05, R-06 |
| `scripts/state.lua` | 新增 `glitchWave_`, `glitchActive_`, `glitchPulseTimer_`, `glitchFlickerCount_`, `maxEnemies_` | R-03, R-06 |
| `scripts/waves.lua` | `modifier_for_wave()` 不再返回 "glitch"；新增 `is_glitch_wave()`；`begin_wave()` 和 `reset()` 设置 glitch 状态 | R-03, R-06 |

---

## 完成后报告格式

完成后请提供：
1. 修改的文件列表和行号范围
2. 每个验收标准的通过/失败状态
3. 遇到的问题和解决方案
4. 构建/运行结果（如果执行了 TapTap Maker 构建）
5. Git commit hash（如果提交了）

---

> 本任务包由产品战略团队方向明（产品舵手）下发。如有疑问，回传给方向明评审。
