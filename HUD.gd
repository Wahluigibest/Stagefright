extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
	#$Panel/DevMenu/FloorLabel.text = "bruhhh" 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





func _on_SkeletalPlayer_Dev_Hud_change(label_change, Value):
	print(label_change)
