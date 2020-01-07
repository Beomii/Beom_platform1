extends Panel

var player=null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		var _player = player.get_ref()
		if _player:
			var attack_cool_percent = 100 - float(_player.attack_melee_timer)/float(_player.attack_melee_duration)*100.0
			if attack_cool_percent < 100:
				$SkillButton1.value = attack_cool_percent
				if _player.attack_melee_timer < _player.attack_melee_duration:
					$SkillButton1/Label.text = str(int(_player.attack_melee_duration - _player.attack_melee_timer))
			else:
				$SkillButton1.value = 0
				$SkillButton1/Label.text="Ready"
			var attack2_cool_percent = 100 - float(_player.attack_timer)/float(_player.attack_delay)*100.0
			if attack2_cool_percent < 100:
				$SkillButton2.value = attack2_cool_percent
				if _player.attack_timer <= _player.attack_delay:
					$SkillButton2/Label.text = str(int(_player.attack_delay - _player.attack_timer))
			else:
				$SkillButton2.value = 0
				$SkillButton2/Label.text="Ready"
func set_player_obj(_player):
	player=weakref(_player)