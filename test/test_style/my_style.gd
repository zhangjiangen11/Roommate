@tool
class_name MyStyle
extends RoommateStyle

@export var new_mesh: Mesh
@export var new_offset := Vector3.ZERO


func _build_rulesets() -> void:
	select_all_blocks()
	select_all_walls()
	set_offset(new_offset)
	if new_mesh:
		set_mesh(new_mesh)
