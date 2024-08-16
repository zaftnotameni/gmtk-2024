class_name SmartQuiver extends RefCounted

static var auth_token : String
static var default_leaderboard_id : String
static var quiver_secrets : QuiverSecrets

static func load_secrets():
	SmartQuiver.quiver_secrets = QuiverSecrets.from_file()
	SmartQuiver.auth_token = quiver_secrets.auth_token
	SmartQuiver.default_leaderboard_id = quiver_secrets.default_leaderboard_id

