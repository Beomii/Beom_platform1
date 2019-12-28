extends Node

const GRAVITY = 1000

const COLLISION_LAYER_PLAYER = 1
const COLLISION_LAYER_MAPTILE = 2
const COLLISION_LAYER_ENEMY = 8

const MAP_BOTTOM_Y = 800
var player_data=null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
