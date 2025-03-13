@tool
class_name RoommateAllSpacePartsSetter
extends RoommatePartsSetter

@export var setter: RoommatePart
@export var exclude_center := true


func set_all(source_parts: Array[RoommatePart]) -> void:
	for part in source_parts:
		var space_part := part as RoommateSpacePart
		if not space_part:
			continue
		if exclude_center and space_part.part_position == Vector3i.ZERO:
			continue
		space_part.set_values(setter)


func get_materials() -> Array[Material]:
	if setter and setter.material:
		return [setter.material]
	return []
