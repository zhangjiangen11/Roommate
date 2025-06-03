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


func resolve_value_setter(property_name: StringName, setter_script: Script) -> RoommateValueSetter:
	if _value_setters.has(property_name):
		var existing_setter := _value_setters[property_name] as RoommateValueSetter
		if not setter_script.instance_has(existing_setter):
			push_error("setter %s doesnt have exprected type" % property_name)
		return existing_setter
	var new_setter := setter_script.new() as RoommateValueSetter
	new_setter.property_name = property_name
	_value_setters[property_name] = new_setter
	return new_setter
