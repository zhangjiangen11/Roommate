@tool
extends RoommateStyle


func _build_rulesets() -> void:
	var r := create_ruleset()
	
	#r.select_inner_blocks([Vector3i(1, 0, 1), Vector3i(-1, 0, 1)], [1, 1])
	r.select_inner_blocks_axis(Vector3i(1, -1, 3))
	r.select_all_parts().override_fallback_surface().set_color(Color.RED)
