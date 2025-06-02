# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateValueSetter
extends RefCounted

var _property_name: StringName
var _override_value: Variant
var _accumulated_value: Variant
var _override_requested := false
var _accumulation_requested := false


func _init(init_property_name: StringName) -> void:
	_property_name = init_property_name


func apply(target: Object) -> void:
	if _override_requested:
		target.set(_property_name, _override_value)
	if _accumulation_requested:
		var current_value := target.get(_property_name)
		target.set(_property_name, current_value + _accumulated_value)


func override(value: Variant) -> void:
	_override_requested = true
	_override_value = value


func accumulate(value: Variant) -> void:
	_accumulation_requested = true
	_accumulated_value = value
