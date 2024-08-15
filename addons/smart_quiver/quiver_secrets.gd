class_name QuiverSecrets extends Resource

const QUIVER_SECRETS_FILE := 'res://quiver__secrets.tres'

@export var auth_token : String
@export var default_leaderboard_id : String

static func from_file() -> QuiverSecrets:
	if ResourceLoader.exists(QUIVER_SECRETS_FILE): return load(QUIVER_SECRETS_FILE)
	else:
		push_error('missing %s' % QUIVER_SECRETS_FILE)
		return QuiverSecrets.new()

func save() -> QuiverSecrets:
	ResourceSaver.save(self, QUIVER_SECRETS_FILE)
	return self
