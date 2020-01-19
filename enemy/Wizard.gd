extends "res://Movable.gd"

var EnemyMagic = preload("res://projectile/EnemyMagic.tscn")

const STATE_IDLE=0
const STATE_MAGIC_CAST = 1

var state = STATE_IDLE

export var detect_range = 200
var target = null setget set_target, get_target

export var cast_cooltime = 1
var cast_timer=cast_cooltime
var casting_duration=1
var casting_timer=0
var casting_pos=Vector2()

export var damage = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	$detector/CollisionShape2D.shape.radius = detect_range
	$hp_bar.value = hp
	$hp_bar.max_value=max_hp

func set_target(_t):
	target = weakref(_t)
	
func get_target():
	if target:
		return target.get_ref()
	return null
	
func _draw():
	Drawing.draw_circle_arc(self, Vector2(0,0), detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))

func _process_force(force, delta):
	var t = get_target()
	if t:
		var dist= position.distance_to(t.position)
		if dist<detect_range:
			state=STATE_MAGIC_CAST
	match(state):
		STATE_IDLE:
			$AnimationPlayer.play("idle")
		STATE_MAGIC_CAST:
			if t:
				if t.position.x > position.x:
					$Sprite.flip_h = true
				else:
					$Sprite.flip_h = false
				if cast_timer >= cast_cooltime:
					$AnimationPlayer.play("cast")
					casting_pos=t.position
			casting_timer += delta		
			
			if casting_timer>= casting_duration:
				cast_magic()
				casting_timer=0
				state = STATE_IDLE
			
	cast_timer += delta
	return force


func _on_detector_body_entered(body):
	if body.collision_layer==global.COLLISION_LAYER_PLAYER:
		set_target(body)


func _on_detector_body_exited(body):
	if body.collision_layer==global.COLLISION_LAYER_PLAYER:
		var t = get_target()
		if t:
			if t==body:
				target=null

func cast_magic():
	var magic = EnemyMagic.instance()
	magic.collision_mask = global.COLLISION_LAYER_PLAYER + global.COLLISION_LAYER_MAPTILE
	var pos=Vector2(60, 0).rotated((casting_pos-position).angle())
	magic.position = position + pos
	magic.damage=damage
	get_parent().add_child(magic)
	magic.fire_range=detect_range
	magic.is_range=false
	magic.shoot(self, casting_pos)

func _on_AnimationPlayer_animation_finished(anim_name):
	pass
		
