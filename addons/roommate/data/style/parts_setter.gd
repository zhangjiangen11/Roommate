# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePartsSetter
extends RoommateObjectSetter

var selected_slot_ids: Array[StringName] = []
var handle_part: Callable

var anchor: RoommateVector3ValueSetter:
	get: return resolve_value_setter(&"anchor", preload("./value_setters/vector3_value_setter.gd"))
var direction: RoommateTransform3DValueSetter:
	get: return resolve_value_setter(&"direction", preload("./value_setters/transform3d_value_setter.gd"))

var transform: RoommateTransform3DValueSetter:
	get: return resolve_value_setter(&"transform", preload("./value_setters/transform3d_value_setter.gd"))
var collision_transform: RoommateTransform3DValueSetter:
	get: return resolve_value_setter(&"collision_transform", preload("./value_setters/transform3d_value_setter.gd"))

var mesh: RoommateMeshValueSetter:
	get: return resolve_value_setter(&"mesh", preload("./value_setters/mesh_value_setter.gd"))
var collision_mesh: RoommateMeshValueSetter:
	get: return resolve_value_setter(&"collision_mesh", preload("./value_setters/mesh_value_setter.gd"))

var _surface_overrides := {}


func apply(block: RoommateBlock) -> void:
	for slot_id in block.slots:
		if not slot_id in selected_slot_ids:
			continue
		var current_part := block.slots.get(slot_id) as RoommatePart
		if not current_part:
			continue
		
		for property_name in _value_setters:
			var setter := _value_setters[property_name] as RoommateValueSetter
			setter.apply(current_part)
		for surface_id in _surface_overrides:
			var override_setter := _surface_overrides[surface_id] as RoommateSurfaceOverrideSetter
			var current_override := current_part.resolve_surface_override(surface_id)
			override_setter.apply(current_override)
		
		if handle_part.is_valid():
			handle_part.call(current_part)


func override_surface(surface_id: int) -> RoommateSurfaceOverrideSetter:
	if _surface_overrides.has(surface_id):
		return _surface_overrides[surface_id] as RoommateSurfaceOverrideSetter
	var new_override := RoommateSurfaceOverrideSetter.new()
	_surface_overrides[surface_id] = new_override
	return new_override
