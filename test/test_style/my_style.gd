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
	s1.transform.accumulate(Transform3D.IDENTITY.rotated(Vector3.RIGHT, deg_to_rad(10)))
	s1.collision_mesh.override(new_mesh)
	s1.override_fallback_surface().material.override(preload("res://test/floor_material.tres"))
	s1.override_fallback_surface().flip_faces.override(true)
	s1.override_fallback_surface().set_color(Color.WHITE)
	#s1.override_surface(2).color.override(Color.DARK_RED)
	
	var s2_ := r1.select_all_walls()
	s2_.override_fallback_surface().color.override(Color.GREEN_YELLOW)
	
	var sx := r1.select_all_walls()
	sx.override_surface(1).color.override(Color.CORNFLOWER_BLUE)
	sx.override_surface(1).flip_faces.override(false)
	sx.override_surface(1).material.override(preload("res://test/floor_material.tres"))
	sx.override_fallback_surface().material.override(preload("res://test/wall_material.tres"))
	
	#var s3_ := r1.select_all_walls()
	#s3_.override_all_surfaces().color.override(Color.MEDIUM_PURPLE)
	
	#s1.override_all_surfaces().set_color(Color.WHITE)
	#s1.override_surface(0).set_uv_tile(Vector2(2, 1), Vector2(8, 8), deg_to_rad(270))
	#s1.override_surface(1).flip_faces.override(false)
	#s1.override_surface(2).material.override(preload("res://test/wall_material.tres"))
	
	var random := RandomNumberGenerator.new()
	random.seed = hash("Roommate")
	
	var s2 := r1.select_floor()
	s2.handle_part = func (slot_id: StringName, part: RoommatePart, block: RoommateBlock) -> void:
		const ROTATIONS: Array[float] = [0, PI * 0.5, PI, PI * 1.5]
		var override := part.resolve_surface_override(0)
		#Vector2i(random.randi_range(1, 7), random.randi_range(1, 7))
		override.set_uv_tile(Vector2i(7, 7), Vector2i(8, 8), ROTATIONS[random.randi_range(0, ROTATIONS.size() - 1)])
	
	
	var r_inverse := create_ruleset()
	r_inverse.select_interval_blocks(Vector3i(2, 0, 2))
	r_inverse.select_all_blocks().invert()
	r_inverse.select_floor().override_fallback_surface().set_color(Color.ORANGE_RED)
