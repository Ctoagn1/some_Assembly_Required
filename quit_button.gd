extends Button

func _ready():
	self.pressed.connect(_quit_game)
	
func _quit_game():
	get_tree().quit()
	
