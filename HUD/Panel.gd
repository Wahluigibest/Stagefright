extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_SkeletalPlayer_death_awww():
	visible = false

func _on_Death_Screen_Unpause_tree():
	visible = true 

func _on_SkeletalPlayer_Label_change(Name, Value):
	#Normal Player Labels
	if Name == "AnimationLabel":
		$PlayerValues/AnimationLabel.text = Value
	if Name == "CeilingLabel":
		$PlayerValues/CeilingLabel.text = Value
	if Name == "DirectionLabel":
		$PlayerValues/DirectionLabel.text = Value
	if Name == "FloorLabel":
		$PlayerValues/FloorLabel.text = Value
	if Name == "VelocityLabel":
		$PlayerValues/VelocityLabel.text = Value
	if Name == "WallLabel":
		$PlayerValues/WallLabel.text = Value
	if Name == "JumpLabel":
		$PlayerValues/JumpLabel.text = ("Allowed Jumps: " + Value)
	
	#Floor Labels
	if Name == "FullFloor":
		$FloorValues/FullFloor.text = ("Full Floor? " + str(Value))
	if Name == "Bounce":
		$FloorValues/Bounce.text = ("Bounce? " + str(Value))
	if Name == "Ice":
		$FloorValues/Ice.text = ("Ice? " + str(Value))
	if Name == "Lava":
		$FloorValues/Lava.text = ("Lava? " + str(Value))
	if Name == "Temp":
		$FloorValues/Temp.text = ("Temp? " + str(Value))

func _on_SkeletalPlayer_Position_Info(X, Y):
	$PlayerValues/PositionLabel.text = ("X: " + str(round(X)) + " Y: " + str(round(Y)))
