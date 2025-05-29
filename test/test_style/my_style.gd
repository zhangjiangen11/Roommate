@tool
class_name MyStyle
extends RoommateStyle

@export var new_offset := Vector3.ZERO


func _build_rulesets() -> void:
	select_all_blocks()
	select_all_parts()
	set_offset(new_offset)
