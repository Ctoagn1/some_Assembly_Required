extends RichTextLabel
var lines = [
	{"mode": "instant", "text":">USERNAME:"},
	{"mode":"typed", "text":"ih8myj0b"},
	{"mode": "instant", "text":""},
	{"mode": "instant", "text":">PASSWORD:"},
	{"mode":"typed", "text":"**********"},
	{"mode": "instant", "text":""},
	{"mode": "instant", "text":">Welcome EMPLOYEE_427"},
	{"mode": "instant", "text":""},
	{"mode": "instant", "text":"INITIALIZING BOOT"},
	{"mode":"typed2", "text":"LOADING........"},
	{"mode": "instant", "text":""},
	{"mode": "error", "text":"ERROR CODE 0x00010F2C SYSTEM FILES CORRUPTED OR MISSING",},
	{"mode": "instant", "text":""},
	{"mode": "instant", "text":">Attempt manual repair? (y/n)"},
	{"mode":"typed", "text":"y"},
	
]
var typing_speed = .1
var load_speed = .9
@onready var terminal=self
@onready var papersound = $"../PaperSound"
#OPENING_PAPER
var paper_start_pos = Vector2(641,1150)
var paper_end_pos = Vector2(641, 442)
var paper_was_shown = false
var cutscene_triggered = false
# ----> After paper is shown, if the player clicks anywhere, hide the paper and then trigger the game's opening sequence.
@onready var animatedpaper = $"../fadingpaper/AnimationPlayer2"
@onready var show_paper = $"../ShowPaper"
@onready var Paper = $"../Paper"
@onready var whitepaper = $"../fadingpaper"
@onready var typinghands = $"../AnimatedSprite2D"
@onready var slam =$Slam
func _ready():
	terminal.clear()
	animatedpaper.play("opacity")
	# start_cutscene()
	## REVEAL PAPER BUTTON
	show_paper.pressed.connect(_on_ShowPaper_pressed)
	Paper.position = paper_start_pos
#func on_paper_read():
	#start_cutscene()
#func _ready():
	#terminal.clear()
	#start_cutscene()

func start_cutscene():
	$Startup.play()
	run_lines()

func run_lines() -> void:
	# Run sequentially using coroutines
	await get_tree().process_frame
	for line in lines:
		match line.mode:
			"instant":
				terminal.add_text(line.text + "\n")
				await get_tree().create_timer(load_speed).timeout

			"typed":
				await type_line(line.text)
				await get_tree().create_timer(load_speed).timeout
			"typed2":
				await type_line2(line.text)
				await get_tree().create_timer(load_speed).timeout
			"error":
				$ErrBeep.play()
				terminal.add_text(line.text+"\n")
				await get_tree().create_timer(1).timeout
				typinghands.frame = 10
				await get_tree().create_timer(0.1).timeout
				typinghands.frame=11
				slam.play()
				await get_tree().create_timer(1).timeout
				await get_tree().create_timer(load_speed).timeout
				
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
func type_line(text: String) -> void:
	var current = ""
	for c in text:
		current += c
		terminal.add_text(c)
		typinghands.frame = randi()%9+1
		await get_tree().create_timer(typing_speed).timeout
		typinghands.frame=0
	terminal.add_text("\n")
func type_line2(text: String) -> void:
	var current = ""
	for c in text:
		current += c
		terminal.add_text(c)
		await get_tree().create_timer(typing_speed).timeout
	terminal.add_text("\n")

func _on_ShowPaper_pressed():
	if not paper_was_shown:
		print("ShowPaper Button fired.")
		typinghands.hide()
		papersound.play()
		var slidePaper = create_tween()
		slidePaper.tween_property(Paper, "position", paper_end_pos, 0.5)
		paper_was_shown = true
		whitepaper.queue_free()
		show_paper.queue_free()
		await get_tree().create_timer(1).timeout
		
func _input(event):
	if paper_was_shown and event is InputEventMouseButton and event.pressed:
		paper_was_shown = false
		create_tween().tween_property(Paper, "position", paper_start_pos, 0.5)
		if cutscene_triggered == false:
			cutscene_triggered = true
			typinghands.show()
			start_cutscene()
		else:
			pass
