extends Node2D

@export var enemy_scene: PackedScene

var current_wave: int

var start_nodes: int
var current_nodes: int
var wave_over


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_wave = 0
	global.current_wave = current_wave
	start_nodes = get_child_count()
	current_nodes = get_child_count()
	position_next_wave()
	
func position_next_wave():
	if current_nodes == start_nodes:
		if current_wave != 0:
			global.next_wave = true
		$SceneTransitionAnimation/animation_player.play("between_wave")
		current_wave +=1
		global.current_wave = current_wave
		await get_tree().create_timer(0.5)
		print(current_wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
