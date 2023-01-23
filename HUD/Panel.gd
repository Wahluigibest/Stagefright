extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_SkeletalPlayer_Ceiling_Label_change(Value):
	$CeilingLabel.text = Value

func _on_SkeletalPlayer_Direction_Label_change(Value):
	$DirectionLabel.text = Value

func _on_SkeletalPlayer_Floor_label_change(Value):
	$FloorLabel.text = Value

func _on_SkeletalPlayer_Position_Info(X, Y):
	$PositionLabel.text = (str("X: ", X , " Y: ", Y))

func _on_SkeletalPlayer_Velocity_label_change(Value):
	$VelocityLabel.text = Value

func _on_SkeletalPlayer_Wall_Label_change(Value):
	$WallLabel.text = Value

func _on_SkeletalPlayer_death_awww():
	visible = false

func _on_Death_Screen_Unpause_tree():
	visible = true 

func _on_SkeletalPlayer_Animation_label_change(Value):
		$AnimationLabel.text = Value
