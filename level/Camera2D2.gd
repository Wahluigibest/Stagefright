extends Camera2D

const LOOK_AHEAD_FACTOR = 0.1
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 0.5

var facing = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var prev_camera_pos = get_camera_position()
onready var tween = $ShiftTween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_check_facing()
	prev_camera_pos = get_camera_position()

func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	if new_facing !=0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * facing * LOOK_AHEAD_FACTOR
		
		tween.interpolate_property(self, "position:x", position.x, target_offset, SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE)
		tween.start()


func _on_SkeletalPlayer_grounded_updated(is_grounded):
	drag_margin_v_enabled = !is_grounded
