extends Area2D

signal execute_portal(portal)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MapPortal_body_entered(body):
	if body.collision_layer == 1:
		emit_signal("execute_portal", self)
