extends Panel

var player=null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		var _player = player.get_ref()
		if _player:
			var attack_cool_percent = 100 - float(_player.attack_melee_cooltimer)/float(_player.attack_melee_cooltime)*100.0
			if attack_cool_percent < 100:
				$SkillButton1.value = attack_cool_percent
				if _player.attack_melee_cooltimer < _player.attack_melee_cooltime:
					$SkillButton1/Label.text = str(int(_player.attack_melee_cooltime - _player.attack_melee_cooltimer))
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