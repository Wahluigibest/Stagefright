extends TextureProgress


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_SkeletalPlayer_Health_Info(HP):
	value = HP


func _on_SkeletalPlayer_death_awww():
	visible = false


func _on_Death_Screen_Unpause_tree():
	visible = true
