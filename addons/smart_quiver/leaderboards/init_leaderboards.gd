@tool
extends EditorPlugin

const LEADERBOARDS_AUTOLOAD_NAME := "Leaderboards"
const ACCOUNTS_AUTOLOAD_NAME := "PlayerAccounts"
const CUSTOM_PROPERTIES := [
	{"name": "quiver/general/auth_token", "default": "", "basic": true, "general": true},
]

func _enter_tree() -> void:
	for property in CUSTOM_PROPERTIES:
		var the_name := property["name"] as String
		var default := property["default"] as String
		var basic := property["basic"] as bool
		if not ProjectSettings.has_setting(the_name):
			ProjectSettings.set_setting(name, default)
			ProjectSettings.set_initial_value(name, default)
			if basic:
				ProjectSettings.set_as_basic(name, true)
	add_autoload_singleton(ACCOUNTS_AUTOLOAD_NAME, "./player_accounts.tscn")
	add_autoload_singleton(LEADERBOARDS_AUTOLOAD_NAME, "./leaderboards.tscn")
	if not ProjectSettings.get_setting("quiver/general/auth_token"):
		printerr("[Quiver Leaderboards] Auth key hasn't been set for Quiver services.")


func _exit_tree() -> void:
	remove_autoload_singleton(LEADERBOARDS_AUTOLOAD_NAME)
	remove_autoload_singleton(ACCOUNTS_AUTOLOAD_NAME)
	for property in CUSTOM_PROPERTIES:
		var the_name := property["name"] as String
		if not property["general"]:
			ProjectSettings.set_setting(the_name, null)
