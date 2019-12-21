extends KinematicBody2D

signal player_die()

const GRAVITY = 1500
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1000
const JUMP_MAX_AIRBORNE_TIME = 0.2

const JUMP_SPEED = 800
var on_air_time = 100
var velocity = Vector2()
var jumping = false
var prev_jump_pressed = false

export var max_hp = 100
export var hp = 100

var DamageMessage = preload("res://ui/DamageMessage.tscn")
var Magic  = preload("res://projectile/Magic.tscn")

var attack_delay = 1
var attack_timer = 0
var heading = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	var stop = true
	if walk_left:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			$body.flip_h = true
			stop =false
			$body.animation = "run"
			heading.x = -1
	elif walk_right:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			$body.flip_h = false
			stop = false
			$body.animation = "run"
			heading.x = 1
	else:
		$body.animation = "idle"
			
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
		$body.animation = "jump"
		
	on_air_time += delta	
	prev_jump_pressed = jump
	
	velocity += force*delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	attack_timer += delta

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_P:
			if attack_timer >= attack_delay:
				attack()
				attack_timer = 0
			else:
				print("attack cooltime!")
				
func attack():
	var magic = Magic.instance()
	magic.position = position
	get_parent().add_child(magic)
	magic.shoot(self, heading+position)
	
func save_data():
	var player_data = {
		"hp":hp,
		"max_hp":max_hp
		}
	return player_data
	
func load_data(data):
	hp = data.hp
	max_hp = data.max_hp
	updateHp()
	
func updateHp():
	var percent = int(float(hp) / float(max_hp) * 100.0)
	$HPBar/Tween.interpolate_property($HPBar, "value", $HPBar.value, percent, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$HPBar/Tween.start()
	
func damaging(unit, damage):
	hp -= damage
	var dmgMsg = DamageMessage.instance()
	dmgMsg.setDamage(damage)
	add_child(dmgMsg)
	if hp < 0:
		queue_free()
		emit_signal("player_die")
	else:
		updateHp()
		
