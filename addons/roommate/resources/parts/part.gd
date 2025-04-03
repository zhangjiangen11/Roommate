@tool
class_name RoommatePart
extends Resource

enum Action { UNDEFINED, INCLUDE, SKIP }

@export var action := Action.UNDEFINED
@export var mesh: Mesh
@export var material: Material


func set_values(other_part: RoommatePart) -> void:
	if not other_part:
		return
	if other_part.mesh:
		mesh = other_part.mesh
	if other_part.material:
		material = other_part.material
	if other_part.action != Action.UNDEFINED:
		action = other_part.action


func set_material(new_material: Material) -> RoommatePart:
	material = new_material
	return self
