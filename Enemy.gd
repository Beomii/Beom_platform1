extends KinematicBody2D

signal enemy_die()

const GRAVITY = 1500
#const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300

const STATE_IDLE = 0
const STATE_MOVE_TO_TARGET = 1
const STATE_ATTACK_PLAYER = 2

var state = STATE_IDLE

export var walk_force = 30
var velocity = Vector2()
export var detect_range = 300
export var attack_range = 100

var target = null

var DamageMessage = preload("res://ui/DamageMessage.tscn")
var EnemyMagic = preload("res://projectile/EnemyMagic.tscn")
const attack_delay = 2
var attack_timer = attack_delay

const max_hp = 100
var hp = max_hp
export var gold =0

func _ready():
	$detector/CollisionShape2D.shape.radius = detect_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	#draw_circle(Vector2(0,0), detect_range, Color(0.0, 1.0, 0.0, 0.2))
	Drawing.draw_circle_arc(self, Vector2(0, 0), detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))
	Drawing.draw_circle_arc(self, Vector2(0, 0), attack_range, 0, 360, Color(0.0, 1.0, 0.0, 0.3))

func _physics_process(delta):
	var force = Vector2(0, GRAVITY)
	
	var t= null
	if target:
		t = target.get_ref()
	if t:
		var dist = position.distance_to(t.position)
		if dist <attack_range:
			state=STATE_ATTACK_PLAYER
		elif dist < detect_range:
			state = STATE_MOVE_TO_TARGET
	
	var stop = true
	match(state):
		STATE_IDLE:
			pass
		STATE_ATTACK_PLAYER:
			if attack_timer >= attack_delay:
				attack(t.position)
				attack_timer = 0
		STATE_MOVE_TO_TARGET:
			if t:
				if t.position.x > position.x:
					if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
						force.x += walk_force
						stop =false
				elif t.position.x < position.x:
					if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
						force.x -= walk_force
						stop =false
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if vlen<0:
			vlen =0
		velocity.x = vlen*vsign
	velocity += force*delta
	velocity = move_and_slide(velocity, Vector2(0,-1))
	
	attack_timer += delta
	
	if position.y >= global.MAP_BOTTOM_Y:
		emit_signal("enemy_die")
		queue_free()
	
func _on_detector_body_entered(body):
	if body != self:
		target = weakref(body)
		state= STATE_MOVE_TO_TARGET
		print("move to target")


func _on_detector_body_exited(body):
	if target:
		var t = target.get_ref()
		if body == t:
			state= STATE_IDLE
			target = null

func attack(pos):
	var magic = EnemyMagic.instance()
	magic.collision_mask = global.COLLISION_LAYER_PLAYER + global.COLLISION_LAYER_MAPTILE
	magic.position = position
	get_parent().add_child(magic)
	magic.fire_range=attack_range
	magic.is_range=false
	magic.shoot(self, pos)
	pass

func _on_Area2D_body_entered(body):
	queue_free()
	emit_signal("enemy_die")
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		body.gold = body.gold + gold


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
		emit_signal("enemy_die")
		if unit.collision_layer == global.COLLISION_LAYER_PLAYER:
			unit.gold = unit.gold + gold
	else:
		updateHp()