extends Node2D

export var detect_range = 300
export var damage= 10
export (String) var turret_name
var target = null

var Bullet = preload("res://projectile/Bullet.tscn")

var attack_cooltime = 1
var attack_timer = attack_cooltime

func _ready():
	$detector/CollisionShape2D.shape.radius = detect_range
	#$Label.text=turret_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		var t= target.get_ref()
		if t:
			if t.position.x > position.x:
				$turret_head.scale.x = -1*abs($turret_head.scale.x)
				$turret_head.rotation= (t.position - position).angle()
			else:
				$turret_head.scale.x = abs($turret_head.scale.x)
				$turret_head.rotation= (position - t.position).angle()
			
			if attack_timer >= attack_cooltime:
				var dist = position.distance_to(t.position)
				if dist <= detect_range:
					var bullet = Bullet.instance()
					
					var fire_pos = $turret_head/fire_position.position.rotated($turret_head.rotation)
					if t.position.x > position.x:					
						fire_pos = Vector2($turret_head/fire_position.position.x*-1,$turret_head/fire_position.position.y).rotated($turret_head.rotation)
					
					bullet.position = position + fire_pos
					get_parent().add_child(bullet)
					bullet.damage= damage
					bullet.shoot(self, t.position)
					attack_timer=0
				
	attack_timer+=delta

func _draw():
	Drawing.draw_circle_arc(self, Vector2(0,0), detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))
	
func _on_detector_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		target = weakref(body)


func _on_detector_body_exited(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if target:
			var t= target.get_ref()
			if t:
				if t==body:					
					target=null
