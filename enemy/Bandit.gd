extends "res://Movable.gd"

const STATE_IDLE=0
const STATE_MOVE_TO_TARGET = 1
const STATE_ATTACK = 2

export var damage = 10
export var detect_range = 150
export var attack_range = 80

var target = null
var state = STATE_IDLE

const ATTACK_COOLTIME = 3
var attack_timer = ATTACK_COOLTIME

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 100
	$detector/CollisionShape2D.shape.radius = detect_range
	$hp_bar.value=hp
	$hp_bar.max_value=max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process_force(force, delta):
	var t = null
	if target:
		 t= target.get_ref()
			if t:
				var dist = position.distance_to(t.position)
				if dist < attack_range:
					state = STATE_ATTACK
				elif dist < detect_range:
					var dist_x = abs(t.position.x - position.x)
					if dist_x > attack_range:
						state = STATE_MOVE_TO_TARGET
			else:
				state=STATE_IDLE
	else:
		state=STATE_IDLE
	match(state):
		STATE_IDLE:
			$AnimationPlayer.play("bandit_idle")
		STATE_ATTACK:
			if attack_timer >= ATTACK_COOLTIME:
				if t.position.x > position.x:
					$Sprite.scale.x = -1*abs($Sprite.scale.x)
				else:
					$Sprite.scale.x = abs($Sprite.scale.x)
				$AnimationPlayer.play("bandit_attack")
				attack_timer =0
		STATE_MOVE_TO_TARGET:
			if t:
				if t.position.x > position.x:
					if velocity.x >= -10 and velocity.x < speed:
						force.x += walk_force
						$Sprite.scale.x = -1*abs($Sprite.scale.x)
						stop = false
						$AnimationPlayer.play("bandit_run")
				elif t.position.x < position.x:
					if velocity.x <= 10 and velocity.x > -speed:
						force.x -= walk_force
						$Sprite.scale.x = abs($Sprite.scale.x)
						stop = false
						$AnimationPlayer.play("bandit_run")
			if $Sprite/RayCast2D.is_colliding():
				velocity.y -= 100
	attack_timer+=delta
	return force
func _post_process(velocity, delta):
	if state == STATE_MOVE_TO_TARGET and velocity.x == 0:
		$AnimationPlayer.play("bandit_idle")

func _draw():
	Drawing.draw_circle_arc(self, Vector2(0,0), detect_range, 0, 360, Color(1.0, 0.0, 0.0, 0.3))
	Drawing.draw_circle_arc(self, Vector2(0,0), attack_range, 0, 360, Color(0.0, 1.0, 0.0, 0.3))


func _on_hitbox_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if body.has_method("damaging"):
			body.damaging(self, damage)


func _on_detector_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		target = weakref(body)
		state = STATE_MOVE_TO_TARGET


func _on_detector_body_exited(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		var t = target.get_ref()
		if t:
			if t==body:
				target = null


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "bandit_attack":
		$AnimationPlayer.play("bandit_idle")
