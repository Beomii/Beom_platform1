extends Node
const GRAVITY = 1000

const COLLISION_LAYER_PLAYER = 1
const COLLISION_LAYER_MAPTILE = 2
const COLLISION_LAYER_ENEMY = 8

const MAP_BOTTOM_Y = 800
var player_data= {
		"hp":100,
		"max_hp":100,
		"gold":0
		}

"""
var transition_path
var transition_delay
var transition_duration
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

"""
func transition(to_scene_path, delay=0, duration=0):
	transition_path = to_scene_path
	transition_delay=delay
	transition_duration=duration
	get_tree().change_scene("res://transition/Transition.tscn")
"""