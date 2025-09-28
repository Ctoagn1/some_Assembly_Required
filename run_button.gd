extends Button

func _ready():
	self.pressed.connect(_start_game)

func _start_game():
	get_tree().change_scene_to_file("res://scenes/levelselect.tscn")
