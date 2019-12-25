extends "res://projectile/Projectile.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("ball")

func _on_EnemyMagic_body_entered(body):
	if body.has_method("damaging"):
		body.damaging(shooter, damage)
		queue_free()


func _on_EnemyMagic_area_entered(area):
	queue_free()
