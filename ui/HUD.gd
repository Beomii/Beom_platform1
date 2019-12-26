extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updatePlayerHP(hp, max_hp):
	$player_hp_bar.max_value = max_hp
	#$player_hp_bar.value = hp
	$Tween.interpolate_property($player_hp_bar, "value", $player_hp_bar.value, hp, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()
	#$player_hp_bar.update()
	$player_hp_label.text = str(hp) + "/"+ str(max_hp)
	
func updateGold(gold):
	$player_gold_label.text= str(gold)
	
func updatePlayerBreath(breath, max_breath):
	$breath_bar.max_value = max_breath
	$breath_bar.value = breath