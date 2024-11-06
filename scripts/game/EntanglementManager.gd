# EntanglementManager.gd
extends Node

# Signal emitted when an entanglement is created or removed
signal entangled(id: String, entangled_with: Node)

# Dictionary to store active entanglements: {entanglement_id: entangled_with_node}
var entanglements: Dictionary = {}

func _ready() -> void:
	print("EntanglementManager: Ready and managing entanglements.")

# Function to create a new entanglement
func entangle(id: String, entangled_with: Node) -> void:
	entanglements[id] = entangled_with
	emit_signal("entangled", id, entangled_with)
	print("EntanglementManager: Created entanglement with ID: ", id, " and entity: ", entangled_with.name)

# Function to remove an existing entanglement
func disentangle(id: String) -> void:
	if entanglements.has(id):
		var entangled_with: Node = entanglements[id]
		entanglements.erase(id)
		emit_signal("entangled", id, null)
		print("EntanglementManager: Disentangled ID: ", id, " from entity: ", entangled_with.name)
