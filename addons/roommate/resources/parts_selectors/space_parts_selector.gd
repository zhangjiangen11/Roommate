@tool
class_name RoommateSpacePartsSelector
extends RoommatePartsSelector

@export var center := false
@export var ceil := true
@export var floor := true
@export var left_wall := true
@export var right_wall := true
@export var forward_wall := true
@export var back_wall := true


func select(selected_parts: Array[RoommatePart], source_parts: Array[RoommatePart]) -> Array[RoommatePart]:
	var result: Array[RoommatePart] = []
	for selected_part in selected_parts:
		if center:
			_try_add_part(selected_part, result, Vector3i.ZERO)
		if ceil:
			_try_add_part(selected_part, result, Vector3i.UP)
		if floor:
			_try_add_part(selected_part, result, Vector3i.DOWN)
		if left_wall:
			_try_add_part(selected_part, result, Vector3i.LEFT)
		if right_wall:
			_try_add_part(selected_part, result, Vector3i.RIGHT)
		if forward_wall:
			_try_add_part(selected_part, result, Vector3i.FORWARD)
		if back_wall:
			_try_add_part(selected_part, result, Vector3i.BACK)
	return result


func _try_add_part(selected_part: RoommatePart, result: Array[RoommatePart], target_part_position: Vector3i) -> void:
	var part := selected_part as RoommateSpacePart
	if not part or part.part_position != target_part_position:
		return
	result.append(part)
