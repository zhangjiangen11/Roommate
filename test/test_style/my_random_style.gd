@tool
class_name MyRandomStyle
extends RoommateStyle


func _build_rulesets() -> void:
	var r1 := create_ruleset()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("123")
	r1.select_random_blocks(0.01, rng)
	r1.select_edge_blocks(Vector3(0, -1, 0)).exclude()
	
	var s1 := r1.select_all_parts()
	s1.set_mesh(null)
	s1.set_collision_mesh(null)
