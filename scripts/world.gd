extends Node2D

@export var enemy_scene: PackedScene
@export var gacha_scene: PackedScene
@export var cooking_scene: PackedScene



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

func _connect_enemy_signal() -> void:
	for child in get_children():
		if child.has_signal("enemy_died"):
			print("found enemy dead")
			child.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died() -> void:
	print("dead enemy method")
	get_tree().paused = true
	
	var gacha = gacha_scene.instantiate()
	gacha.ingredient_awarded.connect(_on_gacha_end)
	add_child(gacha)
	
func _on_gacha_end(ingredient:Dictionary) ->void:
	global.add_ingredient(ingredient["name"])
	get_tree().paused = false
	print(ingredient["name"])
	
	if global.total_ingredients() >= global.COOKING_TRIGGER_COUNT:
		await get_tree().create_timer(0.3).timeout
		get_tree().paused = true
		var cooking = cooking_scene.instantiate()
		cooking.cooking_done.connect(_on_cooking_end)
		add_child(cooking)
func _on_cooking_end() -> void:
	get_tree().paused = false
	
func position_next_wave():
	if current_nodes == start_nodes:
		if current_wave != 0:
			global.next_wave = true
		$SceneTransitionAnimation/animation_player.play("between_wave")
		current_wave +=1
		global.current_wave = current_wave
		get_tree().create_timer(0.5)
		print(current_wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
