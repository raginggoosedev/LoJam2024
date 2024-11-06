# PhaseObject.gd
extends StaticBody2D

@export var active_phases: Array = ["A"]  # The phases in which the object is active
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Connect to the PhaseManager's phase_changed signal
	var phase_manager = get_tree().get_root().get_node("Main/PhaseManager")
	if phase_manager:
		phase_manager.phase_changed.connect(_on_phase_changed)
		print("%s: Connected to PhaseManager's phase_changed signal." % name)
		_update_phase(phase_manager.current_phase)

# Updates the object's collision and visibility based on the current phase
func _on_phase_changed(new_phase: String) -> void:
	_update_phase(new_phase)
	print("%s: Phase changed to %s." % [name, new_phase])

func _update_phase(current_phase: String) -> void:
	var is_active = current_phase in active_phases
	collision_shape.disabled = not is_active
	sprite.visible = is_active
	print("%s: Set is_active to %s." % [name, is_active])
