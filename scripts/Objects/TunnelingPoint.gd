# TunnelingPoint.gd
extends Marker2D

# Exported variable to specify linked tunneling points
@export var linked_point_id: String = ""  # Must match between linked points

# On-ready variables to access child nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Add this node to the 'TunnelingPoints' group
	add_to_group("TunnelingPoints")
	print("TunnelingPoint: Added to 'TunnelingPoints' group with linked_point_id: ", linked_point_id)
