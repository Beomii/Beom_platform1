extends KinematicBody2D

const STATE_IDLE = 0
const STATE_WALK = 1
const STATE_ATTACK = 2

var state = STATE_IDLE

const GRAVITY =1200
var velocity =Vector2()

var DamageMessage = preload("res://ui/DamageMessage.tscn")

var hp = 100
var max_hp = 100
export var gold = 0
export var damage = 20

export var detect_range = 500
export var attack_range = 50
export var speed = 3000

var target =null

func _ready():
	$detector/CollisionShape2D.shape.radius = detect_range
	updateHp()
	change_state()
	
func _draw():
	#draw_circle(Vector2(0,0), detect_range, Color(1.0, 1.0, 1.0, 0.3))
	Drawing.draw_circle_arc(self, Vector2(0,0), detect_range, 0, 360, Color.red)
	Drawing.draw_circle_arc(self, Vector2(0,0), attack_range, 0, 360, Color.green)
	
func updateHp():
	$hp_bar.max_value = max_hp
	#$hp_bar.value = hp
	$hp_tween.interpolate_property($hp_bar, "value", $hp_bar.value, hp, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$hp_tween.start()
	
func damaging(unit, damage):
	hp -= damage
	var dmgMsg = DamageMessage.instance()
	dmgMsg.setDamage(damage)
	add_child(dmgMsg)
	if hp < 0:
		queue_free()
		emit_signal("enemy_die")
		if unit.collision_layer == 1:
			unit.gold = unit.gold + gold
	else:
		updateHp()
	
func change_state():
	match(state):
		STATE_IDLE:
			$idle.visible=true
			$walk.visible=false
			$attack.visible = false
			$AnimationPlayer.play("skeleton_idle")
		STATE_WALK:
			$idle.visible=false
			$walk.visible=true
			$attack.visible = false
			$AnimationPlayer.play("skeleton_walk")
		STATE_ATTACK:
			$idle.visible=false
			$walk.visible=false
			$attack.visible = true
			$AnimationPlayer.play("skeleton_attack")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	var heading = Vector2(0, 0)
	if target:
		var t = target.get_ref()
		if t:
			var dist = position.distance_to(t.position)
			if dist < attack_range:
				state = STATE_ATTACK
				if t.position.x < position.x:					
					$attack.scale.x = -1* abs($attack.scale.x)
				else:
					$attack.scale.x = abs($attack.scale.x)
				change_state()
			elif dist < detect_range:
				state = STATE_WALK
				if t.position.x < position.x:
					heading.x = -1
					$walk.scale.x = -1* abs($walk.scale.x)
				else:
					heading.x = 1
					$walk.scale.x = abs($walk.scale.x)
				change_state()
			else:
				heading.x = 0
				
	match(state):
		STATE_WALK:
			velocity.x = heading.x * speed * delta
				
	velocity.y += GRAVITY* delta
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_hitbox_body_entered(body):
	if body.collision_layer == 1:
		if body.has_method("damaging"):
			body.damaging(self, damage)


func _on_detector_body_entered(body):
	print("detected:"+str(body))
	if body.collision_layer == 1:
		target = weakref(body)


func _on_detector_body_exited(body):
	if body.collision_layer == 1:
		if target:
			var t = target.get_ref()
			if t:
				if body == t:
					target = null
			
