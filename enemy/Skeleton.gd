extends KinematicBody2D

const STATE_IDLE = 0
const STATE_WALK = 1
const STATE_ATTACK = 2

var state = STATE_IDLE

const GRAVITY =1200
var velocity =Vector2()

func _ready():
	change_state()
	
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
	"""
	if Input.is_action_pressed("move_left"):
		velocity.x = -50
		state = STATE_WALK
		$walk.scale.x = -1
		change_state()
	elif Input.is_action_pressed("move_right"):
		velocity.x = 50
		state = STATE_WALK
		$walk.scale.x = 1
		change_state()
	else:
		velocity.x = 0
		if state == STATE_WALK:
			state = STATE_IDLE
			change_state()
	"""
	
	velocity.y += GRAVITY* delta
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_hitbox_body_entered(body):
	print("hit box body entered:"+str(body))
	
func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_K:
			state=STATE_ATTACK
			change_state()
