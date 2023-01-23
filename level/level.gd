extends Node2D

func _on_SkeletalPlayer_death_awww():
	get_tree().paused = true



func _on_Death_Screen_Unpause_tree():
	get_tree().paused = false
