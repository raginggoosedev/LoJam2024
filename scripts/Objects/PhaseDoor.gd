extends StaticBody2D

@export var active_phase: String = "A"  # The phase in which the door is solid
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	# Find the PhaseManager in the scene tree
	var phase_manager = get_tree().root.get_node("Main/PhaseManager")
	phase_manager.phase_changed.connect(_on_phase_changed)
	_update_phase(phase_manager.current_phase)

func _on_phase_changed(new_phase):
	_update_phase(new_phase)

func _update_phase(current_phase):
	var is_active = (current_phase == active_phase)
	collision_shape.disabled = not is_active
	sprite.visible = is_active
