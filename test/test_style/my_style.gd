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
	s1.set_mesh(new_mesh)
	s1.set_uv_rotation(deg_to_rad(89), 0)
	s1.set_uv_scale(Vector2.ONE * 2, 0)
	s1.set_uv_offset(Vector2.ONE / 2, 0)
	
	var random := RandomNumberGenerator.new()
	random.seed = hash("Roommate")
	
	var s2 := r1.select_floor()
	s2.set_uv_tile(coord, Vector2(8, 8), deg_to_rad(angle), 0)
#	s2.handle_part = func (part: RoommatePart) -> void:
#		var override := part.material_overrides.get(0, RoommatePart.MaterialOverride.new()) as RoommatePart.MaterialOverride
#		override.set_uv_tile(Vector2i(random.randi_range(0, 7), random.randi_range(0, 7)), Vector2i(8, 8))
#		part.material_overrides[0] = override
