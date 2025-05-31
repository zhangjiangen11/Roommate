# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePartsSetter
extends RefCounted

var selected_slot_ids: Array[StringName] = []
var _new_values := {}


func apply(slots: Dictionary) -> void:
	for slot_id in slots:
		if not slot_id in selected_slot_ids:
			continue
		var current_part := slots.get(slot_id) as RoommatePart
		if not current_part:
			continue
		for property_name in _new_values:
			current_part.set(property_name, _new_values[property_name])


func set_offset(offset: Vector3) -> void:
	_new_values[&"offset_position"] = offset


func set_euler(euler: Vector3) -> void:
	_new_values[&"offset_euler"] = euler


func set_scale(scale: Vector3) -> void:
	_new_values[&"offset_scale"] = scale


func set_mesh(mesh: Mesh) -> void:
	_new_values[&"mesh"] = mesh
