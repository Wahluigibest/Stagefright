extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




#This is very bad code here since you would only need a variable to refer to the label to change.. but I don't know how do that. 
#So this will have to do.
func _on_SkeletalPlayer_Dev_Hud_change(label_change, _Value):
	print(label_change)


func _on_SkeletalPlayer_Animation_label_change(Value):
	$AnimationLabel.text = Value


func _on_SkeletalPlayer_Velocity_label_change(Value):
	$VelocityLabel.text = Value


func _on_SkeletalPlayer_Floor_label_change(Value):
	$FloorLabel.text = Value


func _on_SkeletalPlayer_Wall_Label_change(Value):
	$WallLabel.text = Value


func _on_SkeletalPlayer_Ceiling_Label_change(Value):
	$CeilingLabel.text = Value


func _on_SkeletalPlayer_Direction_Label_change(Value):
	$DirectionLabel.text = Value


func _on_SkeletalPlayer_Position_Info(X, Y):
	$PositionLabel.text = (str("X: ", X , " Y: ", Y))

