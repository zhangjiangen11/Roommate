@tool
extends RoommateStyle

@export var edge := Vector3i.ZERO


func _build_rulesets() -> void:
	var r := create_ruleset()
	#r.select_edge_blocks(edge)
	var s := r.select_all_parts()
	s.mesh.override(null)
	s.collision_mesh.override(null)
