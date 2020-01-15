extends Node2D

export var duration = 2
var timer = 0
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer+=delta
	if timer>= duration:
		queue_free()
