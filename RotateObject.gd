extends Node2D

var timer = 0
#한바퀴 돌때 걸리는 시간
export var duration = 3
export var h_radius = 50
export var v_radius = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if duration >0:
		var parent = get_parent()
		var rad_angle = timer * PI * 2 / duration
		var degree = rad2deg(rad_angle)
		if degree > 180 and degree < 360:
			z_index = parent.z_index -1
		else:
			z_index = parent.z_index +1
		position = Vector2(cos(rad_angle)*h_radius, sin(rad_angle)*v_radius)
		
		timer += delta
		if timer >= duration:
			timer=0
		$Label.text= str(int(degree)) + "/"+ str(timer)
