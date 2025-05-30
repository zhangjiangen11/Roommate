# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBlock
extends RefCounted

const SLOT_DIRECTIONS = {
	&"sid_up": Vector3i.UP,
	&"sid_down": Vector3i.DOWN,
	&"sid_left": Vector3i.LEFT,
	&"sid_right": Vector3i.RIGHT,
	&"sid_forward": Vector3i.FORWARD,
	&"sid_back": Vector3i.BACK,
}

@export var block_type_id: StringName
@export var block_position: Vector3i
@export var slots := {}
