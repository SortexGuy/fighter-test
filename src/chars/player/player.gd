extends KinematicBody2D
class_name Player

const UNIT_SIZE : int = 16

onready var coll_shape : CollisionShape2D = $CollShape2D
onready var coll_shape_hb : CollisionShape2D = $HitBox/CollShape2D
onready var moves : Dictionary = {
	"5-light": {
		dmg = 16,
		pushback = 6*UNIT_SIZE
	},
	"5-heavy": {
		dmg = 32,
		pushback = 8*UNIT_SIZE
	}
}

export var speed : float = 9*UNIT_SIZE
export var jump_force : float = -12*UNIT_SIZE
export var gravity : float = 6*UNIT_SIZE

var buttons : Array = [false, false]
var _vel : Vector2 = Vector2.ZERO
var _lock_dir : bool = false

func _ready():
	set_as_toplevel(true)

func _process(_delta):
	$HitBox/CollShape2D.material.set("shader_param/Disabled",
		$HitBox/CollShape2D.disabled)

func _get_local_input() -> Dictionary:
	var h_input : int = int(Input.get_axis("p1_left", "p1_right"))
#	if _h_input > 0: _movement_byte |= (1<<0)
#	elif _h_input < 0: _movement_byte |= (1<<1)
	var input : Dictionary = {}
	if h_input != 0:
		input["h_input"] = h_input
	
	return input

func _network_process(input: Dictionary):
	_vel.x = input.get("h_input", 0) * speed
	_vel.y += gravity
	_vel = move_and_slide(_vel, Vector2.UP)

func _save_state() -> Dictionary:
	return {g_pos = position}

func _load_state(state: Dictionary) -> void:
	position = state['g_pos']

func handle_hit():
	print(self.name + " was hit.")

func _on_HitBox_body_entered(body: CollisionObject2D):
	if body.has_method("handle_hit") and not body == self: handle_hit()
