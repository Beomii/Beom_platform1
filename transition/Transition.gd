extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func change(to_scene_path, delay = 0, duraition=0):	
	yield(get_tree().create_timer(delay),"timeout")
	$AnimationPlayer.play("transition")
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree().create_timer(duraition), "timeout")
	get_tree().change_scene(to_scene_path)
	$AnimationPlayer.play("next_scene")
	yield($AnimationPlayer, "animation_finished")