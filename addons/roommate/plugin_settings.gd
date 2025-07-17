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
	"mesh_container_name": &"RoommateMeshContainer",
	"scenes_group": &"roommate_generated_scenes",
	"scenes_fallback_parent_name": &"RoommateSceneFallbackContainer",
	"bake_nav_on_thread": true,
}

const GENERATE_SHORTCUT := "generate_root_nodes_shortcut"

const GENERATE_SHORTCUT_RESOURCE := preload("./defaults/default_generate_shortcut.tres")


static func init_settings(editor_settings: EditorSettings) -> void:
	var shortcut_path := SETTINGS_PATH_TEMPLATE % GENERATE_SHORTCUT
	var shortcut := GENERATE_SHORTCUT_RESOURCE.duplicate()
	var create_shortcut := not editor_settings.has_setting(shortcut_path)
	if create_shortcut:
		editor_settings.set_setting(shortcut_path, shortcut)
	editor_settings.set_initial_value(shortcut_path, shortcut, false)
	
	for setting_name in SETTING_DEFAULTS:
		var setting_path := SETTINGS_PATH_TEMPLATE % setting_name as String
		var default_value: Variant = SETTING_DEFAULTS[setting_name]
		if ProjectSettings.has_setting(setting_path):
			continue
		ProjectSettings.set_setting(setting_path, default_value)
		ProjectSettings.set_initial_value(setting_path, default_value)


static func get_generate_shortcut(editor_settings: EditorSettings) -> InputEventKey:
	var path := SETTINGS_PATH_TEMPLATE % GENERATE_SHORTCUT
	if not editor_settings.has_setting(path):
		push_error("Editor setting %s doesnt exist." % path)
		return null
	var shortcut := editor_settings.get_setting(path) as InputEventKey
	if not shortcut:
		push_error("Wrong type of editor setting %s. InputEventKey expected." % path)
		return null
	return shortcut


static func get_mesh_container_name() -> StringName:
	return get_or_default("mesh_container_name") as StringName


static func get_scenes_group() -> StringName:
	return get_or_default("scenes_group") as StringName


static func get_scenes_fallback_parent_name() -> StringName:
	return get_or_default("scenes_fallback_parent_name") as StringName


static func get_bake_nav_on_thread() -> bool:
	return get_or_default("bake_nav_on_thread") as bool


static func get_or_default(name: String) -> Variant:
	var path := SETTINGS_PATH_TEMPLATE % name
	var default_value: Variant = SETTING_DEFAULTS[name]
	if not ProjectSettings.has_setting(path):
		push_error("Project setting %s doesnt exists." % path)
		return default_value
	var value := ProjectSettings.get_setting_with_override(path)
	if typeof(value) != typeof(default_value):
		push_error("Wrong type of project setting %s. Type %d expected." % [path, typeof(default_value)])
		return default_value
	return ProjectSettings.get_setting_with_override(path)
