extends Node

signal phase_changed(phase)

var current_phase := "A"
var phase_timer := 0.0
var next_phase_time := 0.0

func _ready():
	# Initialize the next phase time
	_set_next_phase_time()

func _process(delta):
	phase_timer += delta
	if phase_timer >= next_phase_time:
		_switch_phase()
		phase_timer = 0
		_set_next_phase_time()

func _switch_phase():
	current_phase = "B" if current_phase == "A" else "A"
	emit_signal("phase_changed", current_phase)
	# Optional: Print to console for testing
	print("Switched to Phase ", current_phase)

func _set_next_phase_time():
	# Random time between 5 to 10 seconds
	next_phase_time = randf_range(5.0, 10.0)
