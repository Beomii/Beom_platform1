extends Area2D

var gold = 10

func _ready():
	$AnimationPlayer.play("coin")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Coin_body_entered(body):
	if body.collision_layer ==  global.COLLISION_LAYER_PLAYER:
		body.gold += gold
		queue_free()
