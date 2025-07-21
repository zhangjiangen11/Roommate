# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends MenuButton

const ROOMMATE := preload("../../roommate_plugin.gd")

var plugin: ROOMMATE


func _ready() -> void:
	get_popup().id_pressed.connect(_on_popup_menu_id_pressed)


func _on_popup_menu_id_pressed(id: int) -> void:
	var nodes := plugin.get_editor_interface().get_selection().get_selected_nodes()
	var is_extends := func (node: Node) -> bool:
		return node is RoommateRoot
	var roots: Array[RoommateRoot] = []
	roots.assign(nodes.filter(is_extends))
	if roots.size() == 0:
		return
	match id:
		0:
			plugin.generate_roots(roots)
		1:
			plugin.snap_roots_areas(roots)
		2:
			plugin.clear_roots_scenes(roots)
