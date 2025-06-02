@tool
class_name MyStyle
extends RoommateStyle

@export var coord := Vector2i.ZERO
@export var angle := 0.0
@export var new_mesh: Mesh


func _build_rulesets() -> void:
	var r1 := create_ruleset()
	r1.select_all_blocks()
	var s1 := r1.select_all_walls()
	s1.mesh.override(new_mesh)
	s1.collision_mesh.override(new_mesh)
	#s1.rotation.override(Vector3.ZERO)
	s1.rotation.accumulate(Vector3.FORWARD * deg_to_rad(85))
	s1.collision_rotation.accumulate(Vector3.FORWARD * deg_to_rad(5))
	s1.override_surface(0).set_uv_tile(Vector2(2, 1), Vector2(8, 4), deg_to_rad(270))
	
	var random := RandomNumberGenerator.new()
	random.seed = hash("Roommate")
	
	var s2 := r1.select_floor()
	s2.handle_part = func (part: RoommatePart) -> void:
		const ROTATIONS := [0, PI * 0.5, PI, PI * 1.5]
		var override := part.resolve_surface_override(0)
		override.set_uv_tile(Vector2i(random.randi_range(0, 7), random.randi_range(0, 7)), Vector2i(8, 8), ROTATIONS[random.randi_range(0, ROTATIONS.size() - 1)])
	
	var r2 := create_ruleset()
	r2.select_edge_blocks(Vector3(-1, 0, -1))
	var corner := r2.select_all_walls()
	corner.override_surface(0).material.override(preload("res://addons/roommate/defaults/default_material.tres"))
