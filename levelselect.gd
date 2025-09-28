extends Control
@onready var level1 = $VBoxContainer/Button
@onready var level2 = $VBoxContainer/Button2
@onready var level3 = $VBoxContainer/Button3
@onready var level4 = $VBoxContainer/Button4
@onready var level5 = $VBoxContainer/Button5
@onready var level6 = $VBoxContainer/Button7
@onready var back = $VBoxContainer/Button6
func _ready():
	var save_file = FileAccess.open("user://savegame.dat", FileAccess.READ)
	if save_file:
		var data = save_file.get_as_text()
		save_file.close()
		Levels.unlocked_levels=int(data)
	level1.pressed.connect(level1start)
	level2.pressed.connect(level2start)
	level3.pressed.connect(level3start)
	level4.pressed.connect(level4start)
	level5.pressed.connect(level5start)
	level6.pressed.connect(level6start)
	back.pressed.connect(back_to_menu)
		
func _process(delta):
	level2.text = "LVL 0x2" if Levels.unlocked_levels >= 1 else "LVL 0x2 INOPERABLE"
	level3.text = "LVL 0x3" if Levels.unlocked_levels >= 2 else "LVL 0x3 INOPERABLE"
	level4.text = "LVL 0x4" if Levels.unlocked_levels >= 3 else "LVL 0x4 INOPERABLE"
	level5.text = "LVL 0x5" if Levels.unlocked_levels >= 4 else "LVL 0x5 INOPERABLE"
	level6.text = "LVL 0x6" if Levels.unlocked_levels >= 5 else "LVL 0x6 INOPERABLE"
	if Levels.unlocked_levels>=6:
		level6.text="LVL 0x6\nSYSTEMS FULLY OPERATIONAL"
	
func level1start():
	Levels.current_level=0
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func level2start():
	Levels.current_level=1
	if Levels.unlocked_levels<1:
		return
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func level3start():
	Levels.current_level=2
	if Levels.unlocked_levels<2:
		return
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func level4start():
	Levels.current_level=3
	if Levels.unlocked_levels<3:
		return
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func level5start():
	Levels.current_level=4
	if Levels.unlocked_levels<4:
		return
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func level6start():
	Levels.current_level=5
	if Levels.unlocked_levels<5:
		return
	get_tree().change_scene_to_file("res://scenes/inputscrn.tscn")
func back_to_menu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
