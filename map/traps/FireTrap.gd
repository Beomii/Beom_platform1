extends Area2D

const STATE_IDLE = 0
const STATE_FIRE = 1

export var delay = 2
export var duration = 3
export var damage_cooltime = 0.5
export var damage = 5

var timer = 0
var damage_timer=damage_cooltime
var state = STATE_IDLE
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(state):
		STATE_IDLE:
			if timer >= delay:
				$Sprite.visible = true
				$AnimationPlayer.play("fire")
				state = STATE_FIRE
				timer=0
		STATE_FIRE:
			if timer >= duration:
				$AnimationPlayer.stop(true)
				$Sprite.visible=false
				state = STATE_IDLE
				timer=0
			if target:
				if damage_timer >= damage_cooltime:
					var t = target.get_ref()
					if t:
						if t.has_method("damaging"):
							t.damaging(self, damage)
					damage_timer=0
	timer += delta
	damage_timer += delta


func _on_FireTrap_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		target = weakref(body)
			


func _on_FireTrap_body_exited(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		if target:
			var t = target.get_ref()
			if t==body:
				target=null
