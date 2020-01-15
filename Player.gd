extends KinematicBody2D

signal player_die()
signal hp_updated(unit)
signal gold_updated(unit)
signal breath_updated(unit)

const GRAVITY = 1500
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
export var WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_MAX_AIRBORNE_TIME = 0.2
const WATER_SPEED_FACTOR = 0.2

const JUMP_SPEED = 560
var on_air_time = 100
var velocity = Vector2()
var jumping = false
var prev_jump_pressed = false

#unit properties
export var max_hp = 100
export var hp = 100
export var gold = 0	setget set_gold
export var damage = 30

var DamageMessage = preload("res://ui/DamageMessage.tscn")
var HealMessage = preload("res://ui/HealMessage.tscn")
var HealEffect = preload("res://effects/HealEffect.tscn")
var Magic  = preload("res://projectile/Magic.tscn")

var attack_delay = 3
var attack_timer = attack_delay
var heading = Vector2(1,0)

var attack_melee = false
var attack_melee_cooltime = 1
var attack_melee_cooltimer = attack_melee_cooltime
var attack_melee_duration = 0.5
var attack_melee_timer = 0

var is_in_water = false
const MAX_BREATH = 100
const BREATH_REDUCE_AMOUNT = 10
const BREATH_RESTORE_AMOUNT = 10
const LOW_BREATH_REDUCE_HP = 5
var breath = MAX_BREATH
var breath_timer_delay = 1
var breath_timer = 0

func _ready():
	emit_signal("hp_updated", self)
	emit_signal("gold_updated", self)

func set_gold(_gold):
	gold = _gold
	emit_signal("gold_updated", self)

func _physics_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	var walk_max_speed = WALK_MAX_SPEED
	if is_in_water:
		walk_max_speed = WALK_MAX_SPEED*WATER_SPEED_FACTOR
	
	var stop = true
	if !attack_melee:
		if walk_left:
			if velocity.x <= WALK_MIN_SPEED and velocity.x > -walk_max_speed:
				if is_in_water:
					force.x -= WALK_FORCE * WATER_SPEED_FACTOR
				else:
					force.x -= WALK_FORCE
				stop =false
				
		elif walk_right:
			if velocity.x >= -WALK_MIN_SPEED and velocity.x < walk_max_speed:
				if is_in_water:
					force.x += WALK_FORCE * WATER_SPEED_FACTOR
				else:
					force.x += WALK_FORCE
				stop = false			
			
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if vlen<0:
			vlen =0
		velocity.x = vlen*vsign
	
	
	if is_on_floor():
		on_air_time = 0
		
	if jumping and velocity.y >0:
		jumping = false
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		velocity.y = -JUMP_SPEED
		jumping = true
	
	if jumping:
		$AnimationPlayer.play("player_jump")
		
	on_air_time += delta	
	prev_jump_pressed = jump
	
	velocity += force*delta
	
	if !attack_melee:
		if velocity.x<0:
			heading.x = -1
			if is_on_floor():
				$AnimationPlayer.play("player_run")
			$Sprite.scale.x = -1*abs($Sprite.scale.x)
		elif velocity.x>0:
			heading.x = 1
			if is_on_floor():
				$AnimationPlayer.play("player_run")
			$Sprite.scale.x = abs($Sprite.scale.x)
		else:	
			if is_on_floor():
				if !jumping and !attack_melee:
					$AnimationPlayer.play("player_idle")
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	attack_timer += delta
	if attack_melee:
		attack_melee_timer+=delta
	attack_melee_cooltimer += delta
		
	if attack_melee_timer >= attack_melee_duration:
		attack_melee = false
		$AnimationPlayer.play("player_idle")
		attack_melee_timer=0
	
	breath_timer += delta
		
	if breath_timer >= breath_timer_delay:
		if is_in_water:	
			breath -= BREATH_REDUCE_AMOUNT
			emit_signal("breath_updated", self)
			if breath<=0:
				damaging(null, LOW_BREATH_REDUCE_HP)
				breath = 0
		else:
			breath += BREATH_RESTORE_AMOUNT
			if breath>MAX_BREATH:
				breath = MAX_BREATH
			emit_signal("breath_updated", self)
		breath_timer =0	
	
	if position.y >= global.MAP_BOTTOM_Y:
		emit_signal("player_die")
		queue_free()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.scancode == KEY_P:
				if attack_timer >= attack_delay:
					attack()
					attack_timer = 0
				else:
					print("attack cooltime!")
			elif event.scancode == KEY_K:
				if attack_melee_cooltimer >= attack_melee_cooltime:
					if !attack_melee:
						$AnimationPlayer.play("player_attack")
						attack_melee = true
						attack_melee_cooltimer= 0
						attack_melee_timer = 0	
				else:
					print(attack_melee_cooltimer)
					
				
func attack():
	var magic = Magic.instance()
	magic.position = position
	get_parent().add_child(magic)
	magic.shoot(self, heading+position)
	
func save_data():
	var player_data = {
		"hp":hp,
		"max_hp":max_hp,
		"gold":gold
		}
	return player_data
	
func load_data(data):
	hp = data.hp
	max_hp = data.max_hp
	gold = data.gold
	updateHp()
	
func updateHp():
	var percent = int(float(hp) / float(max_hp) * 100.0)
	$HPBar/Tween.interpolate_property($HPBar, "value", $HPBar.value, percent, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$HPBar/Tween.start()
	
func healing(heal_point):
	hp += heal_point
	if hp > max_hp:
		hp = max_hp
	var healEffect = HealEffect.instance()
	healEffect.position= Vector2(0, 25)
	add_child(healEffect)
	var healMsg = HealMessage.instance()
	healMsg.rect_position = Vector2(0, -30)
	healMsg.setHealPoint(heal_point)
	add_child(healMsg)
	updateHp()
	emit_signal("hp_updated", self)
	
func damaging(unit, damage):
	hp -= damage
	var dmgMsg = DamageMessage.instance()
	dmgMsg.setDamage(damage)
	add_child(dmgMsg)
	if hp <= 0:
		queue_free()
		emit_signal("player_die")
	else:
		updateHp()
		emit_signal("hp_updated", self)
		


func _on_AnimationPlayer_animation_finished(anim_name):
	pass
	#if anim_name == "player_attack":
	#	attack_melee = false
	#	$AnimationPlayer.play("player_idle")


func _on_hitbox_body_entered(body):
	if body.has_method("damaging"):
		body.damaging(self, damage)
