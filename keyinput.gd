extends Node
var registers={"EAX":0, "EBX":0, "ECX":0, "EDX":0, "FLAGS":{"Z":false, "C":false}, "IP":0}
@onready var code_input = $VBoxContainer/HBoxContainer2/CodeInput
@onready var reg_output = $VBoxContainer/HBoxContainer/RegOutput
@onready var output_box = $VBoxContainer/HBoxContainer2/VBoxContainer/OutputBox
@onready var speed_button = $VBoxContainer/HBoxContainer/SpeedButton
@onready var title_box = $VBoxContainer/Title
@onready var instruction_box = $VBoxContainer/HBoxContainer2/InstructionBox
@onready var manual = $PopupPanel/TextureRect/RichTextLabel
@onready var popupmanual = $PopupPanel
@onready var exit_button = $VBoxContainer/HBoxContainer/ExitButton
@onready var handsprite = $AnimatedSprite2D
@onready var out_beep = $OutBeep
@onready var bad_beep = $BadBeep
@onready var paper_sound = $PaperSound
@onready var good_beep = $GoodBeep
@onready var help_button = $VBoxContainer/HBoxContainer/HelpButton
@onready var level1 = $Level1
@onready var level2 = $Level2
@onready var level3 = $Level3
@onready var level4 = $Level4
@onready var level5 = $Level5

var label_map={}
var memory = []
var memory_size=1024
var input_stack = []
var output_stack = []
var lines = []
var delay_val=10
var expected_output_stack = []
var halt=true
func _ready():
	var run_button = $VBoxContainer/HBoxContainer/RunButton
	load_level(Levels.current_level)
	if Levels.current_level<1:
		level1.play()
	elif Levels.current_level<2:
		level2.play()
	elif Levels.current_level<3:
		level3.play()
	elif Levels.current_level<4:
		level4.play()
	else:
		level5.play()

	run_button.pressed.connect(_on_RunButton_pressed)
	exit_button.pressed.connect(_on_ExitButton_pressed)
	speed_button.pressed.connect(_on_SpeedButton_pressed)
	help_button.pressed.connect(_on_HelpButton_pressed)
	code_input.text_changed.connect(_hand_animation)
func _hand_animation():
	handsprite.frame = randi()%9+1
	await get_tree().create_timer(.1).timeout
	handsprite.frame = 0
	
func _on_ExitButton_pressed():
	get_tree().change_scene_to_file("res://scenes/levelselect.tscn")

func _on_HelpButton_pressed():
	paper_sound.play()
	popupmanual.show()

func highlight_line(line_index: int):
	if(registers["IP"]>=lines.size()):
		return
	var new_lines = lines.duplicate()
	new_lines[registers["IP"]]=">>" + lines[registers["IP"]]
	code_input.text=String("\n").join(new_lines)
	
func _on_SpeedButton_pressed():
	if delay_val==10:
		delay_val=5
		speed_button.text="FST"
	elif delay_val==5:
		delay_val=1
		speed_button.text="VFST"
	elif delay_val==1:
		delay_val=60
		speed_button.text="VSLW"
	elif delay_val==60:
		delay_val=30
		speed_button.text="SLW"
	else:
		delay_val=10
		speed_button.text="MED"
		
func _on_RunButton_pressed():
	if not halt:
		halt=true
		return
	registers={"EAX":0, "EBX":0, "ECX":0, "EDX":0, "FLAGS":{"Z":false, "C":false}, "IP":0}
	load_level(Levels.current_level)
	var code=code_input.text
	code=code.to_upper()
	halt=false
	label_map = {}
	memory.resize(memory_size)
	for i in range(memory_size):
		memory[i]=0
	output_stack=[]
	lines=code.split("\n", false)
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.ends_with(":"):
			label_map[line.substr(0, line.length()-1)]=i
	while not halt:
		if registers["IP"]>=lines.size():
			console_error("IP out of bounds: "+str(registers["IP"]))
			halt=true
		if output_stack.size()>=expected_output_stack.size():
			if output_stack == expected_output_stack:
				succeed()
				halt=true
			else:
				output_box.text+="\n OUTPUT NOT WITHIN ACCEPTABLE PARAMETERS"
				await get_tree().create_timer(1).timeout
				handsprite.frame = 10
				await get_tree().create_timer(0.1).timeout
				handsprite.frame=11
				$slam.play()
				await get_tree().create_timer(1).timeout
				halt=true
		if halt:
			code_input.text=String("\n").join(lines)
			return
		var line=lines[registers["IP"]]
		line = line.strip_edges().to_upper()
		if line == "" or line.begins_with(";"):
			registers["IP"]+=1
			if registers["IP"]==lines.size():
				registers["IP"]=0
			continue
		var cmd = parse_line(line)
		highlight_line(registers["IP"])
		var reg_vals ="EAX = " + str(registers["EAX"]) + "    EBX = " + str(registers["EBX"]) + "    ECX = " + str(registers["ECX"]) + "    EDX = " + str(registers["EDX"]) + "    IP = " + str(registers["IP"]) + "    FLAGS = "
		if registers["FLAGS"]["Z"]:
			reg_vals+= "ZF "
		if registers["FLAGS"]["C"]:
			reg_vals+="CF"
		reg_output.text = reg_vals
		await get_tree().create_timer(delay_val/60.0).timeout
		registers["IP"]+=1
		if registers["IP"]==lines.size():
			registers["IP"]=0
		execute(cmd)
		output_box.text = "OUTPUT:\n" + str(output_stack)
	code_input.text=String("\n").join(lines)
func parse_line(line: String) -> Dictionary:
	var parts = line.split(" ", false, 1)
	var cmd = parts[0]
	var args = []
	if parts.size()>1:
		args = parts[1].split(",", false)
		for i in range(args.size()):
			args[i] = args[i].strip_edges().to_upper()
	return {"op": cmd, "args":args}

func load_level(index: int)-> void:
	if index<0 or index >= Levels.levels.size():
		console_error("Level out of range")
		halt=true
		return
	var current_level = Levels.levels[index]
	title_box.text=current_level.name.to_upper()
	instruction_box.text=current_level.description.to_upper()
	input_stack = current_level.input.duplicate()
	manual.text = current_level.manual
	expected_output_stack = current_level.expected_output.duplicate()
	
	output_box.text="OUTPUT:\n"

func execute(cmd: Dictionary):
	if cmd.op.ends_with(":"):
		return
	match cmd.op:
		"MOV":
			if cmd.args.size()<2:
				console_error("Missing args for MOV")
				halt=true
				return
			if cmd.args[0].begins_with("[") and cmd.args[0].ends_with("]") and not cmd.args[1].begins_with("["):
				var mem_val=cmd.args[0].substr(1, cmd.args[0].length()-2)
				if not (mem_val.is_valid_int() or registers.has(mem_val)):
					console_error("Invalid memory index: "+ mem_val)
					halt=true
					return
				var memory_index
				if registers.has(mem_val):
					memory_index = get_value(mem_val)
				else:
					memory_index=int(mem_val)
				if memory_index>=memory_size or memory_index<0:
					console_error("Invalid memory index: "+str(memory_index))
					halt=true
					return
				memory[memory_index]=get_value(cmd.args[1])
			elif cmd.args[1].begins_with("[") and cmd.args[1].ends_with("]") and not cmd.args[0].begins_with("["):
				var mem_val=cmd.args[1].substr(1, cmd.args[1].length()-2)
				if not (mem_val.is_valid_int() or registers.has(mem_val)):
					console_error("Invalid memory index: "+ mem_val)
					halt=true
					return
				var memory_index
				if registers.has(mem_val):
					memory_index = get_value(mem_val)
				else:
					memory_index=int(mem_val)
				if memory_index>=memory_size or memory_index<0:
					console_error("Invalid memory index: "+str(memory_index))
					halt=true
					return
				set_value(cmd.args[0], memory[memory_index])
			elif cmd.args[1].begins_with("[") and cmd.args[1].ends_with("]") and cmd.args[0].begins_with("[") and cmd.args[0].ends_with("]"):
				console_error("Cannot move one memory address to another. Move to register first.")
				halt=true
				return
			else:
				set_value(cmd.args[0], get_value(cmd.args[1]))
		"ADD":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])+get_value(cmd.args[1]))
		"SUB":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])-get_value(cmd.args[1]))
		"SHL":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])<<get_value(cmd.args[1]))
		"SHR":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])>>get_value(cmd.args[1]))
		"AND":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])&get_value(cmd.args[1]))
		"OR":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])|get_value(cmd.args[1]))
		"XOR":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])^get_value(cmd.args[1]))
		"IN":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if input_stack.size()>0:
				set_value(cmd.args[0], input_stack.pop_front())
			else:
				set_value(cmd.args[0], 0)
		"OUT":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if delay_val>=10:
				out_beep.play()
			output_stack.push_back(get_value(cmd.args[0]))
		"INC":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])+1)
		"DEC":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			set_value(cmd.args[0], get_value(cmd.args[0])-1)
		"JMP":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if label_map.has(cmd.args[0]):
				registers["IP"]=label_map[cmd.args[0]]
			else:
				console_error("Label not found:" + cmd.args[0])
				halt=true
				return
		"CMP":
			if cmd.args.size()<2:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			var cmp_val = get_value(cmd.args[0])-get_value(cmd.args[1])
			if cmp_val>0xFFFFFFFF or cmp_val<0:
				registers["FLAGS"]["C"]=true
			else:
				registers["FLAGS"]["C"]=false
			if cmp_val==0:
				registers["FLAGS"]["Z"]=true
			else:
				registers["FLAGS"]["Z"]=false
		"JZ":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if registers["FLAGS"]["Z"]==true:
				if label_map.has(cmd.args[0]):
					registers["IP"]=label_map[cmd.args[0]]
				else:
					console_error("Label not found:" + cmd.args[0])
					halt=true
					return
		"JNZ":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if registers["FLAGS"]["Z"]==false:
				if label_map.has(cmd.args[0]):
					registers["IP"]=label_map[cmd.args[0]]
				else:
					console_error("Label not found:" + cmd.args[0])
					halt=true
					return
		"JC":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if registers["FLAGS"]["C"]==true:
				if label_map.has(cmd.args[0]):
					registers["IP"]=label_map[cmd.args[0]]
				else:
					console_error("Label not found:" + cmd.args[0])
					halt=true
					return
		"JNC":
			if cmd.args.size()<1:
				console_error("Missing args for"+cmd.op)
				halt=true
				return
			if registers["FLAGS"]["C"]==false:
				if label_map.has(cmd.args[0]):
					registers["IP"]=label_map[cmd.args[0]]
				else:
					console_error("Label not found:" + cmd.args[0])
					halt=true
					return
		_:
			console_error("Opcode not recognized: " + cmd.op)
			halt=true
			return
		
			
			
				
func get_value(arg: String) -> int:
	if registers.has(arg) and not arg=="FLAGS":
		return registers[arg]
	var val = int(arg) if arg.is_valid_int() else null
	if val == null:	
		console_error("Invalid number: "+ str(arg))
		halt=true
		return 0
	return val

func set_value(dest: String, val: int) -> int:
	if registers.has(dest) and not dest=="FLAGS":
		if val>0xFFFFFFFF or val<0:
			registers["FLAGS"]["C"]=true
			val&=0xFFFFFFFF
		else:
			registers["FLAGS"]["C"]=false
		if val==0:
			registers["FLAGS"]["Z"]=true;
		else:
			registers["FLAGS"]["Z"]=false;
		registers[dest]=val
		
	else:
		console_error("Invalid register: " + dest)
		halt=true
		return  1
	return 0
func succeed()->void:
	if Levels.current_level >= Levels.unlocked_levels:
		Levels.unlocked_levels+=1
		var save_file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
		save_file.store_string(str(Levels.unlocked_levels))
		save_file.close
	title_box.text="ALL SYSTEMS OPERATIONAL"
	output_box.text="ALL SYSTEMS OPERATIONAL"
	await get_tree().create_timer(0.5).timeout
	good_beep.play()
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/levelselect.tscn")
	
func console_error(msg: String):
	bad_beep.play()
	reg_output.text="LINE NUM "+str(registers["IP"]+1)+": "+msg.to_upper()
	await get_tree().create_timer(1).timeout
	handsprite.frame = 10
	await get_tree().create_timer(0.1).timeout
	handsprite.frame=11
	$slam.play()
	await get_tree().create_timer(1).timeout
	
