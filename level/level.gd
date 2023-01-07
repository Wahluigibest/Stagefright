extends Node2D

const LIMIT_LEFT = -315
const LIMIT_TOP = -250
const LIMIT_RIGHT = 955
const LIMIT_BOTTOM = 690

func _ready():
	for child in get_children():
		if child is Player:
			var camera = child.get_node(@"Camera2D")
			camera.limit_left = LIMIT_LEFT
			camera.limit_top = LIMIT_TOP
			camera.limit_right = LIMIT_RIGHT
			camera.limit_bottom = LIMIT_BOTTOM


func _on_SkeletalPlayer_Health_Info(HP):
	if HP > 0 or HP == 0:
		get_tree().get_root().set_disable_input(true)
