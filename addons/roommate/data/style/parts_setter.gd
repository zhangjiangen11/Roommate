# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePartsSetter
extends "./object_setter.gd"

var selected_slot_ids: Array[StringName] = []
var handle_part: Callable

var anchor: RoommateValueSetter:
	get: return _resolve_value_setter(&"anchor")
var direction: RoommateValueSetter:
	get: return _resolve_value_setter(&"direction")
var offset: RoommateValueSetter:
	get: return _resolve_value_setter(&"relative_position")
var rotation: RoommateValueSetter:
	get: return _resolve_value_setter(&"rotation")
var scale: RoommateValueSetter:
	get: return _resolve_value_setter(&"scale")

var collision_offset: RoommateValueSetter:
	get: return _resolve_value_setter(&"collision_relative_position")
var collision_rotation: RoommateValueSetter:
	get: return _resolve_value_setter(&"collision_rotation")
var collision_scale: RoommateValueSetter:
	get: return _resolve_value_setter(&"collision_scale")

var mesh: RoommateValueSetter:
	get: return _resolve_value_setter(&"mesh")
var collision_mesh: RoommateValueSetter:
	get: return _resolve_value_setter(&"collision_mesh")

var _surface_overrides := {}


func apply(block: RoommateBlock) -> void:
	for slot_id in block.slots:
		if not slot_id in selected_slot_ids:
			continue
		var current_part := block.slots.get(slot_id) as RoommatePart
		if not current_part:
			continue
		_apply_to_object(current_part)
		
		for surface_id in _surface_overrides:
			var override_setter := _surface_overrides[surface_id] as RoommateSurfaceOverrideSetter
			var current_override := current_part.resolve_surface_override(surface_id)
			override_setter.apply(current_override)
		
		if handle_part:
			handle_part.call(current_part)


func override_surface(surface_id: int) -> RoommateSurfaceOverrideSetter:
	if _surface_overrides.has(surface_id):
		return _surface_overrides[surface_id] as RoommateSurfaceOverrideSetter
	var new_override := RoommateSurfaceOverrideSetter.new()
	_surface_overrides[surface_id] = new_override
	return new_override
