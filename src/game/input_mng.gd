extends Node
class_name InputMng

const HIS_MAX_SIZE : int = 24

onready var curr_his : Dictionary = {
	inputs = 0b000000,
	frame = 0
} setget , get_curr_his
var history : Dictionary = {} setget , get_history

var _update : bool = false setget set_update
var _history_counter : int = history.size()

func _physics_process(_delta):
	if not _update: return
	var _inputs = _retrieve_inputs()
	
	if _inputs != curr_his.inputs:
		history[_history_counter] = curr_his
#		curr_his.clear()
		curr_his = {
			inputs = _inputs,
			frame = 0
		}
		_history_counter += 1
	else:
		curr_his.frame += 1
	
	if history.size() > HIS_MAX_SIZE:
# warning-ignore:return_value_discarded
		history.erase(history.keys()[0])

func _retrieve_inputs() -> int:
	var h_dir_raw : int # Var for horizontal direction
	var light : bool # Var for light button
	var heavy : bool # Var for heavy button
	h_dir_raw = int(Input.get_axis("p1_left", "p1_right"))
	light = Input.is_action_pressed("p1_light")
	heavy = Input.is_action_pressed("p1_heavy")

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

func set_update(v : bool) -> void:
	_update = v

func get_curr_his() -> Dictionary: return curr_his

func get_history() -> Dictionary: return history
