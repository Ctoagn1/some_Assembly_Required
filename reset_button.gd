extends Button
func _ready():
	self.pressed.connect(_reset_game)

func _reset_game():
		var save_file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
		save_file.store_string("0")
		save_file.close
		Levels.unlocked_levels=0
