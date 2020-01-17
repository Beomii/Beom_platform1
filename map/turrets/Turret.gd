extends Area2D

export var detect_range = 300
var scaled_detect_range=detect_range
export var damage= 10
export (String) var turret_name
var target = null

var Bullet = preload("res://projectile/Bullet.tscn")
var DamageMessage = preload("res://ui/DamageMessage.tscn")

export var attack_cooltime = 0.8
var attack_timer = attack_cooltime

export var max_hp = 300
var hp = max_hp

func _ready():
	scaled_detect_range=detect_range
	if scale.x>0:
		scaled_detect_range = detect_range/scale.x
		$detector/CollisionShape2D.shape.radius = scaled_detect_range
	else:
		$detector/CollisionShape2D.shape.radius = detect_range
	#$Label.text=turret_name
	$hp_bar.max_value = max_hp
	$hp_bar.value= hp

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
					
					var turret_fire_position = Vector2($turret_head/fire_position.position.x*scale.x, 
													$turret_head/fire_position.position.y*scale.y)
					var fire_pos = turret_fire_position.rotated($turret_head.rotation)
					if t.position.x > position.x:					
						fire_pos = Vector2(turret_fire_position.x*-1,turret_fire_position.y).rotated($turret_head.rotation)
					
					bullet.position = position + fire_pos
					get_parent().add_child(bullet)
					bullet.damage= damage
					bullet.shoot(self, t.position)
					attack_timer=0
				
	attack_timer+=delta

func _draw():
	Drawing.draw_circle_arc(self, Vector2(0,0), scaled_detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))
	
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

func damaging(unit, _damage):
	hp -= _damage
	$hp_bar.value = hp
	var dmgMsg = DamageMessage.instance()
	dmgMsg.setDamage(_damage)
	add_child(dmgMsg)
	if hp <= 0:
		queue_free()
	