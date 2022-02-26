extends Node
class_name GameState

onready var player_1 : Player = $Charas/Player
onready var player_2 : Player = $Charas/Player2
onready var input_mng : InputMng = $InputMng

#func _ready():
#	input_mng.set_update(true)
#
#func _physics_process(_delta):
#	player_1.retrieve_history(input_mng.get_history(), input_mng.get_curr_his())
#	player_2.receive_inputs(_read_inputs(1))

func _read_inputs(p: int=0) -> int:
	var h_dir_raw : int # Var for horizontal direction
	var light : bool # Var for light button
	var heavy : bool # Var for heavy button
	if p == 0: # Set buttons for player 1
		h_dir_raw = int(Input.get_axis("p1_left", "p1_right"))
		light = Input.is_action_pressed("p1_light")
		heavy = Input.is_action_pressed("p1_heavy")
	else: # Set buttons for player 2
		h_dir_raw = int(Input.get_axis("p2_left", "p2_right"))
		light = Input.is_action_pressed("p2_light")
		heavy = Input.is_action_pressed("p2_heavy")

	var input_state : int = 0b0 # Var to return the binary input
	if h_dir_raw != 0: # Binary h_dir
		var h_dir : int = 0b0
		if h_dir_raw > 0: h_dir = (1<<0)
		elif h_dir_raw < 0: h_dir = (1<<1)
		input_state |= h_dir
	
	var buttons : int = 0b0
	if light: buttons |= (1<<4) # Light in Binary
	if heavy: buttons |= (1<<5) # Heavy in Binary
	input_state |= buttons
	return input_state
