extends "res://Movable.gd"

const STATE_IDLE = 0
const STATE_MOVE_TO_TARGET = 1
const STATE_ATTACK1 = 2
const STATE_ATTACK2 = 3
const STATE_RUSHING = 4

var Coin = preload("res://items/Coin.tscn")

export var detect_range = 350
export var attack1_range = 40
export var attack2_range = 40
export var attack1_cooltime = 3
export var attack2_cooltime = 5
export var gold = 10

export var damage = 3

var attack1_timer = 0
var attack2_timer = 0

var state = STATE_IDLE

var target = null

#돌진 스킬
#목표 지점에 도달하거나 타겟에 부딧히면 종료
var rush_cooltime = 10
var rush_timer = rush_cooltime
var rush_pos = Vector2()
export var rush_distance = 200
export var rush_speed = 600
export var rush_damage = 20

export var attack2_knockback = false
export var rush_knockback=true


# Called when the node enters the scene tree for the first time.
func _ready():
	attack1_timer = attack1_cooltime
	attack2_timer = attack2_cooltime
	
	speed = 80
	
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
				if state!= STATE_RUSHING:
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
				if state != STATE_ATTACK1 and state != STATE_ATTACK2 and state != STATE_RUSHING:
					if dist > attack1_range and dist >attack2_range and dist < detect_range:					
						state = STATE_MOVE_TO_TARGET
						
					if dist > detect_range:
						state = STATE_IDLE
				
				if dist <= rush_distance:
					if rush_timer >= rush_cooltime:
						rush_pos = Vector2(t.position.x, t.position.y)
						state = STATE_RUSHING
						rush_timer = 0
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
					if is_on_floor():
						velocity.y = -500
			updateLabel("move to target")
			
			if $Sprite/RayCast2D.is_colliding():
				if is_on_floor():
					if state != STATE_ATTACK1 and state != STATE_ATTACK2:
						velocity.y = -500
						state= STATE_MOVE_TO_TARGET		
		STATE_ATTACK1:
			updateLabel("attack1")		
		STATE_ATTACK2:
			updateLabel("attack2")
		STATE_RUSHING:
			if t:
				var rush_dist_x = position.distance_to(Vector2(rush_pos.x, position.y))
				var dir = (rush_pos- position).normalized()
				if rush_dist_x < 10:
					state = STATE_IDLE
				else:
					if dir.x >0:
						$Sprite.scale.x = abs($Sprite.scale.x)
					elif dir.x <0:
						$Sprite.scale.x = -1*abs($Sprite.scale.x)
					move_and_slide(Vector2(dir.x*rush_speed, 0), Vector2(0, -1))
					updateLabel("Rush")
					$AnimationPlayer.play("run")
				
	
	attack1_timer += delta
	attack2_timer += delta
	rush_timer+= delta

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
			
			#knockback
			if attack2_knockback:
				body.velocity.x += -1*sign((position - body.position).x)* 300
				#body.velocity = body.move_and_slide(body.velocity, Vector2(0, -1))
				#body.valocity=Vector2(0,0)


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
	if anim_name == "attack_2":
		$Sprite/attack2_hitbox.monitoring=false
		state = STATE_IDLE


func _on_Minotaur_die(unit):
	var coin = Coin.instance()
	coin.position = position
	coin.gold = gold
	get_parent().add_child(coin)


func _on_rush_hitbox_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if state == STATE_RUSHING:
			if body.has_method("damaging"):
				body.damaging(self, rush_damage)
				#knockback
				if rush_knockback:
					body.velocity.x += -1*sign((position - body.position).x)* 300
					#body.velocity = body.move_and_slide(body.velocity, Vector2(0, -1))
					#body.velocity=Vector2(0,0)
					state = STATE_IDLE

func damaging(unit, damage):
	.damaging(unit, damage)
	
	$Sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
	$DamageTween.interpolate_property($Sprite, "modulate", $Sprite.modulate, Color(1.0, 1.0, 1.0, 1.0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$DamageTween.start()