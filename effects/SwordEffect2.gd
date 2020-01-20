extends Area2D

var speed = 300
var duration = 0.5
var timer = 0
var damage = 10

var dir= Vector2(0,0) setget set_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("effect")


func _process(delta):
	position += dir*speed*delta
	timer+= delta
	if timer>=duration:
		queue_free()
	
func set_direction(_dir):
	if _dir.x>0:
		$Sprite.flip_h=true
	else:
		$Sprite.flip_h=false
	dir = _dir


func _on_SwordEffect2_body_entered(body):
	if body.collision_layer==global.COLLISION_LAYER_ENEMY:
		if body.has_method("damaging"):
			body.damaging(null, damage)
			#queue_free()
	elif body.collision_layer==global.COLLISION_LAYER_MAPTILE:
		pass
		#queue_free()
		
