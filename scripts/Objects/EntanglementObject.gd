# EntangleableObject.gd
extends Node2D

# Signals
signal phase_changed(new_phase: String)

# Exported variables for configuration
@export var entanglement_id: String = ""  # Unique ID for this entanglement
@export var is_entangleable_with_player: bool = false  # Determines if the player can entangle with this object
@export var initial_entangled_object_path: NodePath = ""  # Path to another object this is initially entangled with

# On-ready variables to access child nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

# Entanglement state variables
var is_entangled: bool = false
var entangled_with: Node = null  # The node this object is entangled with
var current_phase: String = "A"
var entanglement_offset: Vector2 = Vector2.ZERO  # Offset between this object and the entangled object

# Flags to track connected signals
var entangled_with_phase_changed_connected: bool = false
var entangled_with_moved_connected: bool = false

func _ready() -> void:
	# If this object can be entangled with the player
	if is_entangleable_with_player:
		# Add to "Entangleable" and "Interactable" groups so the player can detect it
		add_to_group("Entangleable")
		add_to_group("Interactable")
		print("EntangleableObject: Added to 'Entangleable' and 'Interactable' groups.")
		
		# Connect to Area2D signals to detect when the player is near
		if area:
			area.body_entered.connect(_on_body_entered)
			area.body_exited.connect(_on_body_exited)
			print("EntangleableObject: Connected to Area2D signals.")
		else:
			print("EntangleableObject: Error - Area2D node not found.")
	else:
		# If an initial entangled object is specified, entangle with it
		if initial_entangled_object_path != null:
			var initial_entangled_object = get_node(initial_entangled_object_path)
			if initial_entangled_object != null:
				entangle_with_object(initial_entangled_object)
				print("EntangleableObject: Initially entangled with:", initial_entangled_object.name)
			else:
				print("EntangleableObject: Error - Initial entangled object not found at path:", initial_entangled_object_path)
	
	# Connect to PhaseManager's phase_changed signal
	var phase_manager = get_tree().get_root().get_node("Main/PhaseManager")
	if phase_manager:
		phase_manager.phase_changed.connect(_on_phase_changed)
		print("EntangleableObject: Connected to PhaseManager's phase_changed signal.")
	else:
		print("EntangleableObject: Error - PhaseManager not found.")
	
	# Initialize phase
	if phase_manager:
		_on_phase_changed(phase_manager.current_phase)

# Function called when a body enters the EntangleableObject's Area2D
func _on_body_entered(body: Node) -> void:
	print("EntangleableObject: Body entered:", body.name, "Groups:", body.get_groups())
	
	# Check if the body is the Player
	if body.is_in_group("Player"):
		print("EntangleableObject: Body is in 'Player' group:", body.name)
		
		# Connect to the Player's 'request_entangle' signal
		if body.has_signal("request_entangle") and is_entangleable_with_player:
			body.request_entangle.connect(Callable(self, "_on_request_entangle"))
			print("EntangleableObject: Connected to Player's 'request_entangle' signal.")
		else:
			print("EntangleableObject: Player lacks 'request_entangle' signal or is not entangleable.")
	else:
		print("EntangleableObject: Body is NOT the Player.")

# Function called when a body exits the EntangleableObject's Area2D
func _on_body_exited(body: Node) -> void:
	print("EntangleableObject: Body exited:", body.name)
	
	# Check if the body is the Player
	if body.is_in_group("Player"):
		print("EntangleableObject: Body is in 'Player' group:", body.name)
		
		# Disconnect from the Player's 'request_entangle' signal
		if body.has_signal("request_entangle") and is_entangleable_with_player:
			body.request_entangle.disconnect(Callable(self, "_on_request_entangle"))
			print("EntangleableObject: Disconnected from Player's 'request_entangle' signal.")
	else:
		print("EntangleableObject: Body exited is NOT the Player.")

# Function called when the Player requests an entanglement
func _on_request_entangle(entangleable_object: Node, entanglement_id: String) -> void:
	print("EntangleableObject: Received 'request_entangle' signal with entanglement_id:", entanglement_id)
	
	# Proceed only if the entangleable_object is this object and it's not already entangled
	if entangleable_object == self and not is_entangled:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			var player = players[0]
			entangle_with_object(player)
			
			# Assign the unique entanglement ID
			self.entanglement_id = entanglement_id
			print("EntangleableObject: Entangled with Player using ID:", entanglement_id)
			
			# Change sprite color to indicate entanglement
			sprite.modulate = Color(0, 1, 0)  # Green
		else:
			print("EntangleableObject: No Player found in 'Player' group.")

# Function to handle entangling with another object
func entangle_with_object(other_object: Node) -> void:
	if not is_entangled:
		is_entangled = true
		entangled_with = other_object
		entanglement_offset = global_position - entangled_with.global_position
		print("EntangleableObject: Entangled with", other_object.name)
		
		# Connect to the entangled object's 'phase_changed' and 'moved' signals
		if entangled_with.has_signal("phase_changed"):
			entangled_with.phase_changed.connect(_on_phase_changed)
			entangled_with_phase_changed_connected = true
			print("EntangleableObject: Connected to entangled object's 'phase_changed' signal.")
		else:
			print("EntangleableObject: Entangled object lacks 'phase_changed' signal.")
		
		if entangled_with.has_signal("moved"):
			entangled_with.moved.connect(_on_entangled_object_moved)
			entangled_with_moved_connected = true
			print("EntangleableObject: Connected to entangled object's 'moved' signal.")
		else:
			print("EntangleableObject: Entangled object lacks 'moved' signal.")
		
		# Update to match the entangled object's current phase
		_on_phase_changed(entangled_with.current_phase)
	else:
		print("EntangleableObject: Already entangled.")

# Function to disentangle from the current entangled object
func disentangle() -> void:
	if is_entangled:
		is_entangled = false
		
		# Disconnect from the entangled object's signals
		if entangled_with_phase_changed_connected and entangled_with.has_signal("phase_changed"):
			entangled_with.phase_changed.disconnect(_on_phase_changed)
			entangled_with_phase_changed_connected = false
			print("EntangleableObject: Disconnected from entangled object's 'phase_changed' signal.")
		if entangled_with_moved_connected and entangled_with.has_signal("moved"):
			entangled_with.moved.disconnect(_on_entangled_object_moved)
			entangled_with_moved_connected = false
			print("EntangleableObject: Disconnected from entangled object's 'moved' signal.")
		
		entangled_with = null
		print("EntangleableObject: Disentangled from Player.")
		
		# Reset sprite color
		sprite.modulate = Color(1, 1, 1)  # White

# Function called when the phase changes
func _on_phase_changed(new_phase: String) -> void:
	current_phase = new_phase
	_update_phase()
	print("EntangleableObject: Phase changed to:", new_phase)

# Function to update the object's appearance based on the current phase
func _update_phase() -> void:
	# Example: Toggle visibility based on phase
	# Modify this function based on your game's requirements
	sprite.visible = (current_phase == "A")  # Visible only in phase "A"

# Physics process to update the object's position if entangled
func _physics_process(delta: float) -> void:
	if is_entangled and entangled_with:
		# Update this object's position relative to the entangled object's movement
		global_position = entangled_with.global_position + entanglement_offset
		print("EntangleableObject: Updated position to:", global_position)

# Function called when the entangled object moves
func _on_entangled_object_moved() -> void:
	if is_entangled and entangled_with:
		global_position = entangled_with.global_position + entanglement_offset
		print("EntangleableObject: Updated position due to entangled object's movement.")
