extends CharacterBody2D

@export var speed = 400
#Tunneling Variables
var tunneling_timer = 0.0
var next_tunneling_time := 0.0
var is_tunneling := false

func _ready() -> void:
	_set_next_tunneling_time()
	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	
	#Tunneling Logic
	tunneling_timer += delta
	if tunneling_timer >= next_tunneling_time:
		_start_tunneling()
		tunneling_timer = 0.0
		_set_next_tunneling_time()

func _start_tunneling():
	is_tunneling = true
	# Play pre-tunneling effects (e.g., glow or ripple)
	# For testing, we can print a message
	print("Starting tunneling...")
	# Schedule the actual tunneling after a short delay
	await get_tree().create_timer(1.0).timeout
	_perform_tunneling()

func _perform_tunneling():
	# Choose a random tunneling point
	var tunneling_points = get_tree().get_nodes_in_group("TunnelingPoints")
	if tunneling_points.size() > 0:
		var index = randi() % tunneling_points.size()
		global_position = tunneling_points[index].global_position
		print("Teleported to ", global_position)
	else:
		print("No tunneling points available!")
	is_tunneling = false
	# Play post-tunneling effects
	# Reset any necessary states

func _set_next_tunneling_time():
	# Random time between 10 to 20 seconds
	next_tunneling_time = randf_range(10.0, 20.0)
