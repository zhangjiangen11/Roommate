@tool
class_name RoommateRootActions
extends MenuButton


func _ready() -> void:
	get_popup().id_pressed.connect(_on_popup_menu_id_pressed)


func _on_popup_menu_id_pressed(id: int) -> void:
	var nodes := EditorInterface.get_selection().get_selected_nodes()
	var is_extends := func (node: Node) -> bool:
		return node is RoommateRoot
	var filtered := nodes.filter(is_extends)
	if filtered.size() == 0:
		return
	for node in filtered:
		var root := node as RoommateRoot
		root.generate_mesh()
