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
			ProjectSettings.set_setting(the_name, default)
			ProjectSettings.set_initial_value(the_name, default)
			if basic:
				ProjectSettings.set_as_basic(the_name, true)

	SmartQuiver.load_secrets()
	if not SmartQuiver.auth_token or SmartQuiver.auth_token.is_empty():
		var auth_token = ProjectSettings.get_setting("quiver/general/auth_token")
		
		if not auth_token or auth_token.is_empty():
			printerr("[Quiver Leaderboards] Auth key hasn't been set for Quiver services.")
			push_error("[Quiver Leaderboards] Auth key hasn't been set for Quiver services.")

	add_autoload_singleton(ACCOUNTS_AUTOLOAD_NAME, "./accounts/player_accounts.tscn")
	add_autoload_singleton(LEADERBOARDS_AUTOLOAD_NAME, "./leaderboards/leaderboards.tscn")
	var cfg := ConfigFile.new()

func _exit_tree() -> void:
	remove_autoload_singleton(LEADERBOARDS_AUTOLOAD_NAME)
	remove_autoload_singleton(ACCOUNTS_AUTOLOAD_NAME)
	for property in CUSTOM_PROPERTIES:
		var the_name := property["name"] as String
		if not property["general"]:
			ProjectSettings.set_setting(the_name, null)
