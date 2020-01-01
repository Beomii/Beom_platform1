extends Area2D


var targets = []

const attack_delay = 0.5
var damage = 3
var attack_timer= attack_delay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if targets.size()>0:
		if attack_timer >= attack_delay:
			for target in targets:
				var t = target.get_ref()
				if t:
					if t.has_method("damaging"):
						t.damaging(null, damage)
			attack_timer=0
	attack_timer += delta
		
	$Label.text="target count:"+str(targets.size())


func _on_thorns_body_entered(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		targets.push_back(weakref(body))


func _on_thorns_body_exited(body):
	if body.collision_layer == global.COLLISION_LAYER_PLAYER:
		for target in targets:
			var t = target.get_ref()
			if t:
				if t==body:
					targets.erase(target)