# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePart
extends RefCounted

var anchor := Vector3.ZERO

var relative_position := Vector3.ZERO
var rotation := Vector3.ZERO
var scale := Vector3.ONE

var mesh: Mesh
var collision_mesh: Mesh
