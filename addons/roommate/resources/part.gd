@tool
class_name RoommatePart
extends Resource

@export var mesh: Mesh
@export var material: Material
@export var skip := false


func set_values(other_part: RoommatePart) -> void:
	if not other_part:
		return
	if other_part.mesh:
		mesh = other_part.mesh
	if other_part.material:
		material = other_part.material
	skip = other_part.skip
