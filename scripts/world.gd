extends Node2D

@export var enemy_scene: PackedScene
@export var gacha_scene: PackedScene
@export var cooking_scene: PackedScene
@export var player_scene: PackedScene



var current_wave: int

var start_nodes: int
var current_nodes: int
var wave_over
var enemy_present= 1

var cooking_open:= false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_wave = 0
	global.current_wave = current_wave
	start_nodes = get_child_count()
	current_nodes = get_child_count()
	position_next_wave()
	$SceneTransitionAnimation/animation_player.play("scene_change")
	
	signalBus.enemy_died.connect(_on_enemy_died)
	$enemy_respawn.start()
	signalBus.gacha_end.connect(_on_gacha_end)
	signalBus.cooking_done.connect(_on_cooking_end)

	
func _on_enemy_died() -> void:
	get_tree().paused = true
	
	var gacha = gacha_scene.instantiate()
	gacha.ingredient_won.connect(_on_gacha_end)
	add_child(gacha)
	
	enemy_present = 0
	
	
func _on_gacha_end(ingredient:Dictionary) ->void:
	global.add_ingredient(ingredient["name"])
	get_tree().paused = false
	print(ingredient["name"])
	
	
func _on_cooking_end() -> void:
	cooking_open = false
	get_tree().paused = false
	
func position_next_wave():
	if current_nodes == start_nodes:
		if current_wave != 0:
			global.next_wave = true
		$SceneTransitionAnimation/animation_player.play("scene_change")
		current_wave +=1
		global.current_wave = current_wave
		get_tree().create_timer(0.5)
		print(current_wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("recipe") and not cooking_open:
		cooking_open = true
		await get_tree().create_timer(0.3).timeout
		get_tree().paused = true
		var cooking = cooking_scene.instantiate()
		cooking.cooking_done.connect(_on_cooking_end)
		add_child(cooking)
	pass


func _on_enemy_respawn_timeout() -> void:
	if (get_tree().paused==false and enemy_present == 0):
		var e_scene = enemy_scene.instantiate()
		e_scene.enemy_died.connect(_on_enemy_died)
		add_child(e_scene)
		enemy_present = 1
		e_scene.global_position= Vector2( 50, 150)
	
