@tool
class_name MyEdgeStyle
extends RoommateStyle


func _build_rulesets() -> void:
	var r1 := create_ruleset()
	r1.select_edge_blocks(Vector3i(0, -1, 0))
	var s1 := r1.select_parts([&"sid_center"])
	var mesh := CylinderMesh.new()
	mesh.height = 0.2
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.1
	s1.set_mesh(mesh)
	
	var s2 := r1.select_parts([&"sid_down"])
	s2.set_offset(Vector3.FORWARD)
	s2.set_euler(Vector3(deg_to_rad(20), 0, 0))
	s2.set_scale(Vector3.ONE * 0.5)
