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
var _custom_accumulation: Callable
var _override_requested := false
var _accumulation_requested := false
var _accumulation_inverse := false


func _init(init_property_name: StringName) -> void:
	_property_name = init_property_name


func apply(target: Object) -> void:
	if _override_requested:
		target.set(_property_name, _override_value)
		
	if not _accumulation_requested:
		return
	var current_value: Variant = target.get(_property_name)
	if _custom_accumulation.is_valid():
		target.set(_property_name, _custom_accumulation.call(current_value))
		return
	var types := [typeof(current_value), typeof(_accumulated_value)]
	var first: Variant = current_value
	var second: Variant = _accumulated_value
	if _accumulation_inverse:
		first = _accumulated_value
		second = current_value
	
	match types:
		[TYPE_INT, TYPE_INT], [TYPE_FLOAT, TYPE_FLOAT], [TYPE_VECTOR3, TYPE_VECTOR3]:
			target.set(_property_name, first + second)
		[TYPE_TRANSFORM3D, TYPE_TRANSFORM3D], [TYPE_TRANSFORM2D, TYPE_TRANSFORM2D]:
			target.set(_property_name, first * second)
		_:
			push_error("value setter cant accumulatate with types %s" % types)


func override(value: Variant) -> void:
	_override_requested = true
	_override_value = value


func accumulate(value: Variant, inverse := false) -> void:
	_accumulation_requested = true
	_accumulation_inverse = inverse
	_accumulated_value = value


func accumulate_custom(custom: Callable) -> void:
	_accumulation_requested = true
	_custom_accumulation = custom
