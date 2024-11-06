# PhaseManager.gd
extends Node

# Signal emitted when the phase changes
signal phase_changed(new_phase: String)

var current_phase: String = "A"
var phase_timer: float = 0.0
var next_phase_time: float = 0.0

func _ready() -> void:
	_set_next_phase_time()
	print("PhaseManager: Initialized with phase ", current_phase)

func _process(delta: float) -> void:
	phase_timer += delta
	if phase_timer >= next_phase_time:
		_switch_phase()
		phase_timer = 0.0
		_set_next_phase_time()

# Toggles between phases and emits the phase_changed signal
func _switch_phase() -> void:
	current_phase = "B" if current_phase == "A" else "A"
	emit_signal("phase_changed", current_phase)
	print("PhaseManager: Switched to phase ", current_phase)

# Sets the next phase switch time randomly between 5 and 10 seconds
func _set_next_phase_time() -> void:
	next_phase_time = randf_range(5.0, 10.0)
	print("PhaseManager: Next phase switch in ", next_phase_time, " seconds.")
