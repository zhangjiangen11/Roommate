@tool
class_name RoommateSpaceSelectorBase
extends RoommateSelectorBase

@export var ceil := true
@export var floor := true
@export var wall_left := true
@export var wall_right := true
@export var wall_forward := true
@export var wall_back := true
@export var center := false


func get_selected_part_positions() -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	if center:
		result.append(Vector3i.ZERO)
	if ceil:
		result.append(Vector3i.UP)
	if floor:
		result.append(Vector3i.DOWN)
	if wall_left:
		result.append(Vector3i.LEFT)
	if wall_right:
		result.append(Vector3i.RIGHT)
	if wall_forward:
		result.append(Vector3i.FORWARD)
	if wall_back:
		result.append(Vector3i.BACK)
	return result
