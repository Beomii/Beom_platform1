extends Area2D

export var heal_point = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HealPack_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if body.has_method("healing"):
			body.healing(heal_point)
			queue_free()
