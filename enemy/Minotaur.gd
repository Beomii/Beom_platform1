extends "res://Movable.gd"

const STATE_IDLE = 0
const STATE_MOVE_TO_TARGET = 1
const STATE_ATTACK1 = 2
const STATE_ATTACK2 = 3

var Coin = preload("res://items/Coin.tscn")

export var detect_range = 150
export var attack1_range = 50
export var attack2_range = 50
export var attack1_cooltime = 5
export var attack2_cooltime = 3
export var gold = 10

export var damage = 3

var attack1_timer = 0
var attack2_timer = 0

var state = STATE_IDLE

var target = null


# Called when the node enters the scene tree for the first time.
func _ready():
	attack1_timer = attack1_cooltime
	attack2_timer = attack2_cooltime
	
	speed = 100
	
	$detector/CollisionShape2D.shape.radius = detect_range
	$hp_bar.value=hp
	$hp_bar.max_value=max_hp

func _draw():
	Drawing.draw_circle_arc(self, Vector2(0,0), detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))
	Drawing.draw_circle_arc(self, Vector2(0,0), attack1_range, 0, 360, Color(0.0, 1.0, 0.0, 0.3))
	Drawing.draw_circle_arc(self, Vector2(0,0), attack2_range, 0, 360, Color(0.0, 0.0, 1.0, 0.3))
	
func _process_force(force, delta):
	var t = null
	if target:
		 t= target.get_ref()
			if t:
				var dist = position.distance_to(t.position)
				if state != STATE_ATTACK1:
					if state != STATE_ATTACK2:
						if dist < attack1_range:
							if attack1_timer >= attack1_cooltime:
								state=STATE_ATTACK1
								
								if t.position.x > position.x:
									$Sprite.scale.x = abs($Sprite.scale.x)
								else:
									$Sprite.scale.x = -1*abs($Sprite.scale.x)
								$AnimationPlayer.play("attack_1")						
								attack1_timer=0
				if state != STATE_ATTACK2:
					if dist <attack2_range:
						if state != STATE_ATTACK1:
							if attack2_timer >= attack2_cooltime:
								
								state= STATE_ATTACK2
								if t.position.x > position.x:
									$Sprite.scale.x = abs($Sprite.scale.x)
								else:
									$Sprite.scale.x = -1*abs($Sprite.scale.x)
								$AnimationPlayer.play("attack_2")
								
								attack2_timer = 0
				if state != STATE_ATTACK1 and state != STATE_ATTACK2:
					if dist > attack1_range and dist >attack2_range and dist < detect_range:
						state = STATE_MOVE_TO_TARGET
					if dist > detect_range:
						state = STATE_IDLE
			else:
				state = STATE_IDLE
	else:
		state = STATE_IDLE
	match(state):
		STATE_IDLE:
			$AnimationPlayer.play("idle")
			updateLabel("idle")		
		STATE_MOVE_TO_TARGET:
			if t:
				if t.position.x > position.x:
					if velocity.x >= -10 and velocity.x < speed:
						force.x += walk_force
						$Sprite.scale.x = abs($Sprite.scale.x)
						stop = false
						$AnimationPlayer.play("run")
				elif t.position.x < position.x:
					if velocity.x <= 10 and velocity.x > -speed:
						force.x -= walk_force
						$Sprite.scale.x = -1*abs($Sprite.scale.x)
						stop = false
						$AnimationPlayer.play("run")
				if $Sprite/RayCast2D.is_colliding():
					velocity.y -= 100
			updateLabel("move to target")		
		STATE_ATTACK1:
			updateLabel("attack1")		
		STATE_ATTACK2:
			updateLabel("attack2")		
	attack1_timer += delta
	attack2_timer += delta
	return force
func updateLabel(text):
	$Label.text = text	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _post_process(velocity, delta):
	if state == STATE_MOVE_TO_TARGET and velocity.x == 0:
		$AnimationPlayer.play("idle")

func _on_hitbox_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if body.has_method("damaging"):
			body.damaging(self, damage)


func _on_attack2_hitbox_body_entered(body):	
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if body.has_method("damaging"):
			body.damaging(self, damage)
			
			#knockback test
			body.velocity.x += -1*sign((position - body.position).x)* 300


func _on_detector_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		target = weakref(body)
		state = STATE_MOVE_TO_TARGET


func _on_detector_body_exited(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if target:
			var t = target.get_ref()
			if t:
				if t==body:
					target = null


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack_1":
		$Sprite/hitbox.monitoring=false
		state = STATE_IDLE
		print("attack1 finished")
	if anim_name == "attack_2":
		$Sprite/attack2_hitbox.monitoring=false
		state = STATE_IDLE
		print("attack2 finished")


func _on_Minotaur_die(unit):
	var coin = Coin.instance()
	coin.position = position
	coin.gold = gold
	get_parent().add_child(coin)
