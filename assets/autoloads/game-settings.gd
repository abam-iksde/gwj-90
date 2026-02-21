class_name GameSettings
extends Object


static var MOUSE_SENSITIVITY := 0.2

static var ON_FOOT_FOV := 90.0
static var PLOW_FOV := 90.0


const _SETTINGS_PATH = 'user://settings.txt'

static func load_settings():
	var config_file := ConfigFile.new()
	config_file.load(_SETTINGS_PATH)
	MOUSE_SENSITIVITY = config_file.get_value('settings', 'mouse_sensitivity', MOUSE_SENSITIVITY)
	ON_FOOT_FOV = config_file.get_value('settings', 'fpp_fov', ON_FOOT_FOV)
	PLOW_FOV = config_file.get_value('settings', 'tpp_fov', PLOW_FOV)


static func save_settings():
	var config_file := ConfigFile.new()
	config_file.set_value('settings', 'mouse_sensitivity', MOUSE_SENSITIVITY)
	config_file.set_value('settings', 'fpp_fov', ON_FOOT_FOV)
	config_file.set_value('settings', 'tpp_fov', PLOW_FOV)
	config_file.save(_SETTINGS_PATH)
