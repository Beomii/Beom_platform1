extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_property(self, "rect_position", rect_position, rect_position + Vector2(0,-30), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	$Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func setHealPoint(heal_point):
	$Label.text="+"+str(heal_point)

func _on_Tween_tween_all_completed():
	queue_free()
