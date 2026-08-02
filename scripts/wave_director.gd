extends Node
class_name WaveDirector

signal wave_started(wave_index)
signal wave_completed(wave_index)
signal elite_spawned(elite_id)

var rng: RandomNumberGenerator
var run_seed: int = 0
var waves: Array = []
var current_wave_index: int = 0
var current_wave_time: float = 0.0
var active: bool = false

func setup(seed_value: int, wave_definitions: Array) -> void:
    run_seed = seed_value
    waves = wave_definitions.duplicate(true)
    rng = RandomNumberGenerator.new()
    rng.seed = run_seed
    current_wave_index = 0
    current_wave_time = 0.0
    active = true
    emit_signal("wave_started", current_wave_index)

func process_wave(delta: float) -> void:
    if not active:
        return
    if current_wave_index >= waves.size():
        active = false
        return
    current_wave_time += delta
    var wave_data = waves[current_wave_index]
    var duration = float(wave_data.get("duration", 45.0))
    if current_wave_time >= duration:
        current_wave_index += 1
        current_wave_time = 0.0
        if current_wave_index < waves.size():
            emit_signal("wave_completed", current_wave_index)
            emit_signal("wave_started", current_wave_index)
        else:
            active = false
            emit_signal("wave_completed", current_wave_index)
        return
    var spawn_defs = wave_data.get("spawn", [])
    for spawn_def in spawn_defs:
        var interval = float(spawn_def.get("interval", 1.0))
        if interval <= 0.0:
            continue
        var count = int(spawn_def.get("count", 0))
        if count <= 0:
            continue
        var time_index = int(floor(current_wave_time / interval))
        if time_index < count and int(floor((current_wave_time - delta) / interval)) < time_index:
            var enemy_id = String(spawn_def.get("enemy", ""))
            _spawn_enemy(enemy_id, wave_data)
    var elite_id = wave_data.get("elite", null)
    if elite_id != null and not wave_data.has("elite_spawned"):
        wave_data["elite_spawned"] = true
        emit_signal("elite_spawned", elite_id)

func _spawn_enemy(enemy_id: String, wave_data: Dictionary) -> void:
    var pick = rng.randi_range(0, 1000000)
    print("[WaveDirector] spawn", enemy_id, "wave", current_wave_index, "seed", run_seed, "pick", pick)

func current_wave() -> Dictionary:
    if current_wave_index < waves.size():
        return waves[current_wave_index]
    return {}
