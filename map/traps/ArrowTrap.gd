extends Node2D

var TrapArrow = preload("res://map/traps/TrapArrow.tscn")

export var dir = Vector2(-1, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func execute_trap():
	for pos in get_children():
		var arrow = TrapArrow.instance()
		var dir2 = dir.rotated(rotation)
		arrow.dir = dir2
		arrow.position = position + pos.position.rotated(rotation)
		get_parent().add_child(arrow)
		arrow.fire()
