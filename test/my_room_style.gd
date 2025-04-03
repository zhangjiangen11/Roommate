@tool
class_name MyRoomStyle
extends RoommateStyle

@export var all_material: Material
@export var wall_material: Material


func _build_rulesets() -> void:
	(
			select_all_blocks()
			.select_all_parts()
			.set_material(all_material)
	)
	(
			select_all_blocks()
			.select_all_walls()
			.set_material(wall_material)
	)
