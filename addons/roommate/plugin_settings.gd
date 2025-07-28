# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

const SETTINGS_PATH_TEMPLATE := "plugins/roommate/%s"

const SETTING_DEFAULTS := {
	&"stid_area_block_range_step": 0.5,
	&"stid_mesh_container_name": &"RoommateMeshContainer",
	&"stid_scenes_group": &"roommate_generated_scenes",
	&"stid_scenes_fallback_parent_name": &"RoommateSceneFallbackContainer",
	&"stid_bake_nav_on_thread": true,
	&"stid_area_resize_snap": 1.0,
	&"stid_area_snap_margin": 0.0,
}

const SHORTCUT_DEFAULTS := {
	&"stid_generate_root_nodes_shortcut": preload("./defaults/default_generate_shortcut.tres"),
	&"stid_snap_roots_areas_shortcut": preload("./defaults/default_snap_areas_shortcut.tres"),
	&"stid_clear_scenes_shortcut": preload("./defaults/default_clear_scenes_shortcut.tres"),
}


static func init_settings(editor_settings: EditorSettings) -> void:
	for setting_id in SHORTCUT_DEFAULTS:
		var shortcut_path := _get_path(setting_id)
		var default_shortcut := SHORTCUT_DEFAULTS[setting_id].duplicate() as InputEventKey
		var create_shortcut := not editor_settings.has_setting(shortcut_path)
		if create_shortcut:
			editor_settings.set_setting(shortcut_path, default_shortcut)
		editor_settings.set_initial_value(shortcut_path, default_shortcut, false)
	
	for setting_id in SETTING_DEFAULTS:
		var setting_path := _get_path(setting_id)
		var default_value: Variant = SETTING_DEFAULTS[setting_id]
		if ProjectSettings.has_setting(setting_path):
			continue
		ProjectSettings.set_setting(setting_path, default_value)
		ProjectSettings.set_initial_value(setting_path, default_value)


static func get_shortcut(setting_id: StringName, 
		editor_settings: EditorSettings) -> InputEventKey:
	var path := _get_path(setting_id)
	if not editor_settings.has_setting(path):
		push_error("ROOMMATE: Editor setting %s doesn't exist." % path)
		return null
	var shortcut := editor_settings.get_setting(path) as InputEventKey
	if not shortcut:
		push_error("ROOMMATE: Wrong type of editor setting %s. InputEventKey expected." % path)
		return null
	return shortcut


static func get_bool(setting_id: StringName) -> bool:
	return get_or_default(setting_id) as bool


static func get_float(setting_id: StringName) -> float:
	return get_or_default(setting_id) as float


static func get_string(setting_id: StringName) -> StringName:
	return get_or_default(setting_id) as StringName


static func get_or_default(setting_id: StringName) -> Variant:
	var path := _get_path(setting_id)
	var default_value: Variant = SETTING_DEFAULTS[setting_id]
	if not ProjectSettings.has_setting(path):
		push_error("ROOMMATE: Project setting %s doesn't exists." % path)
		return default_value
	var value := ProjectSettings.get_setting_with_override(path)
	if typeof(value) != typeof(default_value):
		push_error("ROOMMATE: Wrong type of project setting %s. Type %d expected." % [path, typeof(default_value)])
		return default_value
	return ProjectSettings.get_setting_with_override(path)


static func _get_path(settind_id: StringName) -> String:
	if not settind_id.begins_with("stid_"):
		push_error("ROOMMATE: Setting Id must start with stid_ prefix. Received '%s'." % settind_id)
	return SETTINGS_PATH_TEMPLATE % settind_id.trim_prefix("stid_")
