@tool
extends RoommateStyle

@export var test := 0


func _build_rulesets() -> void:
	var r := create_ruleset()
	r.select_all_blocks()
	var s := r.select_all_walls()
	s.mesh.override(null)
	s.collision_mesh.override(null)
