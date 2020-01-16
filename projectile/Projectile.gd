extends Area2D

signal out_of_range

var shooter = null
var damage = 20
export var speed= 200
var velocity = Vector2()
var direction = Vector2()

var fire_range = 100
var start_pos =Vector2()
var distance = 0
var is_range = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction:
		velocity = direction*speed
		position += velocity*delta
		distance = start_pos.distance_to(position)
		if is_range and distance >= fire_range:
			emit_signal("out_of_range")
			queue_free()
		
func shoot(_shooter, target_pos):
	self.shooter = _shooter
	start_pos = position
	rotation = target_pos.angle_to_point(position)
	direction = (target_pos - position).normalized()