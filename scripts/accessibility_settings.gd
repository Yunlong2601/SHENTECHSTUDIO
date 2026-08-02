extends Node
class_name AccessibilitySettings

@export var colorblind_mode: String = "off"
@export var vfx_intensity: float = 1.0
@export var aim_assist: bool = false

func apply() -> void:
    print("Accessibility applied:", colorblind_mode, vfx_intensity, aim_assist)
