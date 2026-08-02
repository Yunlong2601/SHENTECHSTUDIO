extends Node
class_name ArenaModifierSystem

var modifiers: Array = []

func apply_modifier(name: String) -> void:
    modifiers.append(name)
    print("[ArenaModifierSystem] applied", name)

func current_modifiers() -> Array:
    return modifiers.duplicate()
