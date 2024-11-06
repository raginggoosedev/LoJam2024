# Player.gd
extends CharacterBody2D

# Signals
signal interact
signal request_entangle(entangleable_object: Node, entanglement_id: String)
signal phase_changed(new_phase: String)
signal moved  # Signal emitted when the player moves

# Interaction variables
var can_interact: bool = false
var interaction_body: Node = null

@export var speed: int = 400  # Player's movement speed

# Tunneling variables
var tunneling_timer: float = 0.0
var next_tunneling_time: float = 0.0
var is_tunneling: bool = false

# Entanglement variables
var can_entangle: bool = false
var entangleable_object: Node = null
var is_entangled: bool = false
var current_entanglement_id: String = ""

@onready var interaction_area: Area2D = $Area2D  # Ensure this path is correct

func _ready() -> void:
	# Initialize random number generator
	randomize()
	
	# Set the next tunneling time
	_set_next_tunneling_time()
	
	# Connect to PhaseManager's phase_changed signal
	var phase_manager = get_tree().get_root().get_node("Main/PhaseManager")
	if phase_manager:
		phase_manager.phase_changed.connect(_on_phase_changed)
		print("Player: Connected to PhaseManager's phase_changed signal.")
	else:
		print("Player: Error - PhaseManager not found.")
	
	# Verify interaction_area
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
		print("Player: Connected to Area2D signals.")
	else:
		print("Player: Error - interaction_area is null.")

# Custom function to generate a unique ID
func generate_unique_id(length: int = 16) -> String:
	var chars: String = "0123456789abcdef"
	var uuid: String = ""
	for i in range(length):
		uuid += chars[randi() % chars.length()]
	return uuid

# Function to handle player input
func get_input() -> void:
	# Get player input and set velocity
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

# Physics process for movement and interactions
func _physics_process(delta: float) -> void:
	var old_position: Vector2 = global_position
	get_input()
	move_and_slide()
	
	# Emit moved signal if the player has moved
	if global_position != old_position:
		emit_signal("moved")
	
	# Tunneling Logic
	tunneling_timer += delta
	if tunneling_timer >= next_tunneling_time:
		_start_tunneling()
		tunneling_timer = 0.0
		_set_next_tunneling_time()
	
	# Interaction handling
	if Input.is_action_just_pressed("interact"):
		print("Player: Interact key pressed")
		if can_interact:
			print("Player: Can interact with object:", interaction_body.name)
			# Handle interaction with objects (e.g., switches)
			if interaction_body and interaction_body.has_method("interact"):
				interaction_body.interact()
				print("Player: Called interact() on:", interaction_body.name)
		elif can_entangle:
			if not is_entangled:
				print("Player: Can entangle and is not entangled, emitting request_entangle")
				# Generate a unique entanglement ID using the custom generator
				current_entanglement_id = "player_entangle_%s" % generate_unique_id(32)
				print("Player: Generated entanglement_id:", current_entanglement_id)
				emit_signal("request_entangle", entangleable_object, current_entanglement_id)
				is_entangled = true
			else:
				print("Player: Already entangled, attempting to disentangle")
				# Disentangle when already entangled
				if entangleable_object and entangleable_object.has_method("disentangle"):
					entangleable_object.disentangle()
					is_entangled = false
					current_entanglement_id = ""
					print("Player: Disentangled from object")

# Function to handle tunneling initiation
func _start_tunneling() -> void:
	is_tunneling = true
	# Debug message
	print("Player: Starting tunneling...")
	# Schedule the tunneling after a short delay
	await get_tree().create_timer(1.0).timeout
	_perform_tunneling()

# Function to perform the tunneling action
func _perform_tunneling() -> void:
	# Tunneling logic to handle linked points and random points
	var current_point: Node = null
	var tunneling_points: Array = get_tree().get_nodes_in_group("TunnelingPoints")
	
	# Find if the player is at a tunneling point
	for point in tunneling_points:
		if point.global_position.distance_to(global_position) < 10.0:
			# Player is at a tunneling point
			current_point = point
			break

	if current_point and current_point.linked_point_id != "":
		# Teleport to the linked point
		var target_point: Node = null
		for point in tunneling_points:
			if point != current_point and point.linked_point_id == current_point.linked_point_id:
				target_point = point
				break
		if target_point:
			global_position = target_point.global_position
			print("Player: Teleported to linked point at ", global_position)
		else:
			print("Player: Linked point not found!")
	elif tunneling_points.size() > 0:
		# Choose a random tunneling point
		var index: int = randi() % tunneling_points.size()
		global_position = tunneling_points[index].global_position
		print("Player: Teleported to random point at ", global_position)
	else:
		print("Player: No tunneling points available!")
	is_tunneling = false
	# Play post-tunneling effects or reset states if needed

# Function to set the next tunneling time
func _set_next_tunneling_time() -> void:
	# Random time between 10 to 20 seconds
	next_tunneling_time = randf_range(10.0, 20.0)
	print("Player: Next tunneling in", next_tunneling_time, "seconds")

# Function called when a body enters the Player's Area2D
func _on_body_entered(body: Node) -> void:
	print("Player: Body entered:", body.name, "Groups:", body.get_groups())
	if body.is_in_group("Interactable"):
		print("Player: Body is Interactable")
		can_interact = true
		interaction_body = body
	else:
		print("Player: Body is NOT Interactable")
	
	if body.is_in_group("Entangleable"):
		print("Player: Body is Entangleable")
		can_entangle = true
		entangleable_object = body
	else:
		print("Player: Body is NOT Entangleable")

# Function called when a body exits the Player's Area2D
func _on_body_exited(body: Node) -> void:
	print("Player: Body exited:", body.name)
	if body == interaction_body:
		print("Player: Exiting interaction with object")
		can_interact = false
		interaction_body = null
	if body == entangleable_object:
		print("Player: Exiting entanglement with object")
		can_entangle = false
		entangleable_object = null

# Function called when the phase changes
func _on_phase_changed(new_phase: String) -> void:
	print("Player: Phase changed to:", new_phase)
	# Emit phase_changed signal
	emit_signal("phase_changed", new_phase)
