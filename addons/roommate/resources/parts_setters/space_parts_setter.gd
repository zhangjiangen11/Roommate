@tool
class_name RoommateSpacePartsSetter
extends RoommatePartsSetter

@export var center_setter: RoommatePart
@export var ceil_setter: RoommatePart
@export var floor_setter: RoommatePart
@export var wall_left_setter: RoommatePart
@export var wall_right_setter: RoommatePart
@export var wall_forward_setter: RoommatePart
@export var wall_back_setter: RoommatePart


func set_all(source_parts: Array[RoommatePart]) -> void:
	for part in source_parts:
		var space_part := part as RoommateSpacePart
		if not space_part:
			continue
		_set_single(space_part, Vector3i.ZERO, center_setter)
		_set_single(space_part, Vector3i.UP, ceil_setter)
		_set_single(space_part, Vector3i.DOWN, floor_setter)
		_set_single(space_part, Vector3i.LEFT, wall_left_setter)
		_set_single(space_part, Vector3i.RIGHT, wall_right_setter)
		_set_single(space_part, Vector3i.FORWARD, wall_forward_setter)
		_set_single(space_part, Vector3i.BACK, wall_back_setter)


func get_materials() -> Array[Material]:
	var result: Array[Material] = []
	_add_single_material(result, center_setter)
	_add_single_material(result, ceil_setter)
	_add_single_material(result, floor_setter)
	_add_single_material(result, wall_left_setter)
	_add_single_material(result, wall_right_setter)
	_add_single_material(result, wall_forward_setter)
	_add_single_material(result, wall_back_setter)
	return result


func _add_single_material(array: Array[Material], setter: RoommatePart) -> void:
	if setter and setter.material and not setter.material in array:
		array.append(setter.material)


func _set_single(space_part: RoommateSpacePart, part_position: Vector3i, part_setter: RoommatePart) -> void:
	if space_part.part_position == part_position and part_setter:
		space_part.set_values(part_setter)
