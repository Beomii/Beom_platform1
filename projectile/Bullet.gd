extends "res://projectile/Projectile.gd"

var ExplosionEffect = preload("res://effects/Explosion1.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	is_range=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Bullet_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		var eff = ExplosionEffect.instance()
		eff.position = position
		body.get_parent().add_child(eff)
		
		if body.has_method("damaging"):
			body.damaging(null, damage)
		
		queue_free()
	elif body.collision_layer == global.COLLISION_LAYER_MAPTILE:
		var eff = ExplosionEffect.instance()
		eff.position = position
		body.get_parent().add_child(eff)
		queue_free()


func _on_Bullet_area_entered(area):
	if area.collision_layer == global.COLLISION_LAYER_MAPTILE:
		var eff = ExplosionEffect.instance()
		eff.position = position
		area.get_parent().add_child(eff)
		queue_free()
