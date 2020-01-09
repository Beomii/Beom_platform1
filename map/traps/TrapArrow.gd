extends "res://projectile/Projectile.gd"
export var dir = Vector2(-1, 0)
func _ready():
	is_range = false
	damage = 1

func fire():
	$Sprite.frame = 0
	start_pos = position
	var target_pos = position + dir
	rotation = position.angle_to_point(target_pos)
	direction = (target_pos - position).normalized()

func _on_TrapArrow_body_entered(body):
	if distance >16:
		if body.collision_layer == global.COLLISION_LAYER_PLAYER:
			if body.has_method("damaging"):
				body.damaging(null, damage)
				queue_free()
		elif body.collision_layer == global.COLLISION_LAYER_MAPTILE:
			queue_free()


func _on_TrapArrow_area_entered(area):
	if area.collision_layer == global.COLLISION_LAYER_MAPTILE:
		queue_free()
