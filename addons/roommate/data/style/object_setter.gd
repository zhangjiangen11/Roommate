# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateObjectSetter
extends RefCounted

var _value_setters := {}


func _apply_to_object(target: Object) -> void:
	for property_name in _value_setters:
		var value_setter := _value_setters[property_name] as RoommateValueSetter
		value_setter.apply(target)


func _resolve_value_setter(property_name: StringName) -> RoommateValueSetter:
	if _value_setters.has(property_name):
		return _value_setters[property_name] as RoommateValueSetter
	var new_setter := RoommateValueSetter.new(property_name)
	_value_setters[property_name] = new_setter
	return new_setter
