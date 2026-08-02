extends CanvasLayer
class_name DebugOverlay

@export var enabled: bool = true

var player_stats: Dictionary = {}
var spawned_label: Label
var stats_label: Label
var spawn_button: Button

func _ready() -> void:
    if not enabled:
        visible = false
        return
    spawned_label = Label.new()
    stats_label = Label.new()
    spawn_button = Button.new()
    spawn_button.text = "Spawn test enemy"
    spawn_button.pressed.connect(_on_spawn_pressed)
    var panel = VBoxContainer.new()
    panel.add_child(spawned_label)
    panel.add_child(stats_label)
    panel.add_child(spawn_button)
    add_child(panel)
    _refresh()

func _refresh() -> void:
    spawned_label.text = "Debug Overlay"
    var lines: Array = []
    for key in player_stats.keys():
        lines.append("%s: %s" % [key, str(player_stats[key])])
    stats_label.text = "\n".join(lines)

func _on_spawn_pressed() -> void:
    print("[DebugOverlay] spawn test enemy")

func update_stats(stats: Dictionary) -> void:
    player_stats = stats.duplicate(true)
    _refresh()
