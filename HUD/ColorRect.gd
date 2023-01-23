extends ColorRect


# Declare member variables here. Examples:
signal Unpause_tree()
# Called when the node enters the scene tree for the first time.
#func _ready():



func _on_SkeletalPlayer_death_awww():
	visible = true
	var tween := Tween.new()
	add_child(tween)
	 
	# Modulate from original color to alpha transparency over 3 seconds.
	#The final value is number of seconds for the screen to fade
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3)
	tween.set_active(true)
	tween.start() 
	
	# Wait until tween ends, if necessary.
	yield(tween, "tween_completed")
	tween.queue_free()
	print("done!")
	emit_signal("Unpause_tree")

