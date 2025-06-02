@tool
class_name MyEdgeStyle
extends RoommateStyle


func _build_rulesets() -> void:
	var r1 := create_ruleset()
	r1.select_edge_blocks(Vector3i(0, -1, 0))
	var s1 := r1.select_center()
	var mesh := CylinderMesh.new()
	mesh.height = 0.2
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.1
	s1.mesh.override(mesh)
	
	var s2 := r1.select_floor()
	s2.offset.override(Vector3.FORWARD)
	s2.rotation.override(Vector3(deg_to_rad(-80), 0, 0))
	s2.scale.override(Vector3.ONE * 0.5)
	s2.collision_offset.override(Vector3.FORWARD)
	s2.collision_rotation.override(Vector3(deg_to_rad(-80), 0, 0))
	s2.collision_scale.override(Vector3.ONE * 0.5)
