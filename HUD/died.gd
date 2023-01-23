extends RichTextLabel


# Declare member variables here. Examples:
var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
#func _ready():
	

func do_this():
	var tween := Tween.new()
	add_child_below_node($ColorRect, tween)
	 
	# Modulate from original color to alpha transparency over 2 seconds.
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2)
	tween.set_active(true)
	tween.start() 
	
	# Wait until tween ends, if necessary.
	yield(tween, "tween_completed")
	tween.queue_free()
	print("done!")



func _on_SkeletalPlayer_death_awww():
	visible = true
	timer.connect("timeout",self,"do_this")
	timer.wait_time = 3
	timer.one_shot = true
	add_child(timer)
	timer.start()
