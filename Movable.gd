extends KinematicBody2D

signal die(unit)
var DamageMessage = preload("res://ui/DamageMessage.tscn")

var velocity =Vector2()

export var speed = 300
export var walk_force = 700
export var stop_force = 1500

export var max_hp = 100
export var hp = 100

var stop = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process_force(force, delta):
	pass

func _post_process(velocity, delta):
	pass
	
func _physics_process(delta):
	var force = Vector2(0, global.GRAVITY)
	stop = true
	
	force = _process_force(force, delta)
	
	if stop:
		var vsign = sign(velocity.x)	#방향값
		var vlen = abs(velocity.x)
		vlen -= stop_force*delta
		if vlen <0:
			vlen = 0
		velocity.x = vlen * vsign
	
	velocity += force*delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	_post_process(velocity, delta)

func damaging(unit, damage):
	hp -= damage
	var dmgMsg = DamageMessage.instance()
	dmgMsg.setDamage(damage)
	add_child(dmgMsg)
	if hp < 0:
		queue_free()
		emit_signal("die", self)
	else:
		updateHp()

func updateHp():
	var percent = int(float(hp) / float(max_hp) * 100.0)
	$hp_bar/Tween.interpolate_property($hp_bar, "value", $hp_bar.value, percent, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$hp_bar/Tween.start()
	
	