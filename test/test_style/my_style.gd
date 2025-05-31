@tool
class_name MyStyle
extends RoommateStyle

@export var new_mesh: Mesh
@export var new_offset := Vector3.ZERO


func _build_rulesets() -> void:
	var r1 := create_ruleset()
	r1.select_all_blocks()
	var s1 := r1.select_all_walls()
	s1.set_offset(new_offset)
	if new_mesh:
		s1.set_mesh(new_mesh)
