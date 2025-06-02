# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends MenuButton


func _ready() -> void:
	get_popup().id_pressed.connect(_on_popup_menu_id_pressed)


func _on_popup_menu_id_pressed(id: int) -> void:
	var nodes := EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()
	var is_extends := func (node: Node) -> bool:
		return node is RoommateRoot
	var filtered := nodes.filter(is_extends)
	if filtered.size() == 0:
		return
	var add_collision := id in [0, 1]
	var add_navigation := id in [0, 2]
	for node in filtered:
		var root := node as RoommateRoot
		root.generate_mesh(add_collision, add_navigation)
