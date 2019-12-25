extends "res://projectile/Projectile.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_EnemyMagic_body_entered(body):
	if body.has_method("damaging"):
		body.damaging(shooter, damage)
		queue_free()


func _on_EnemyMagic_area_entered(area):
	queue_free()


func _on_Magic_body_entered(body):
	#print("body entered:"+str(body.collision_layer))
	match body.collision_layer:
		global.COLLISION_LAYER_MAPTILE:
			queue_free()
		global.COLLISION_LAYER_ENEMY:
			if body.has_method("damaging"):
				body.damaging(shooter, damage)
				queue_free()


func _on_Magic_area_entered(area):
	queue_free()
