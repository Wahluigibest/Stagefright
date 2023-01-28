extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_SkeletalPlayer_death_awww():
	visible = false

func _on_Death_Screen_Unpause_tree():
	visible = true 

func _on_SkeletalPlayer_Label_change(Name, Value):
	if Name == "AnimationLabel":
		 $AnimationLabel.text = Value
	if Name == "CeilingLabel":
		$CeilingLabel.text = Value
	if Name == "DirectionLabel":
		$DirectionLabel.text = Value
	if Name == "FloorLabel":
		$FloorLabel.text = Value
	if Name == "VelocityLabel":
		$VelocityLabel.text = Value
	if Name == "WallLabel":
		$WallLabel.text = Value
	if Name == "JumpLabel":
		$JumpLabel.text = ("Allowed Jumps: " + Value)


func _on_SkeletalPlayer_Position_Info(X, Y):
	$PositionLabel.text = ("X: " + str(round(X)) + " Y: " + str(round(Y)))
