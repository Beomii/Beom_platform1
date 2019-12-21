extends Area2D

var shooter = null
var damage = 20
var speed= 200
var velocity = Vector2()
var direction = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction:
		velocity = direction*speed
		position += velocity*delta

func shoot(_shooter, target_pos):
	self.shooter = _shooter
	rotation = target_pos.angle_to_point(position)
	direction = (target_pos - position).normalized()

func _on_EnemyMagic_body_entered(body):
	if body.has_method("damaging"):
		body.damaging(shooter, damage)
		queue_free()


func _on_EnemyMagic_area_entered(area):
	queue_free()


func _on_Magic_body_entered(body):
	#print("body entered:"+str(body.collision_layer))
	match body.collision_layer:
		2:
			queue_free()
		8:
			if body.has_method("damaging"):
				body.damaging(shooter, damage)
				queue_free()


func _on_Magic_area_entered(area):
	queue_free()
