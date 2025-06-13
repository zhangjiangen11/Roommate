@tool
extends RoommateStyle


func _build_rulesets() -> void:
	var r := create_ruleset()
	
	#r.select_inner_blocks([Vector3i(1, 0, 1), Vector3i(-1, 0, 1)], [1, 1])
	#r.select_inner_blocks([Vector3i.FORWARD], [2])
	#r.select_edge_blocks_axis(Vector3i(-1, 1, -1))
	r.select_edge_blocks_axis(Vector3i(0, -1, -1))
	r.select_all_parts().override_fallback_surface().set_color(Color.RED)
	var walls := r.select_all_walls()
	walls.scene.override(preload("res://test/decor/window.tscn"))
	walls.scene_parent_path.override(^"./Doors")
	walls.scene_transform.accumulate(Transform3D(Basis.from_euler(Vector3(0, 0, 0)), Vector3(0, -0.5, 0)))
