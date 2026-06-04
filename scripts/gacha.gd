extends CanvasLayer

signal ingredient_won(ingredient:Dictionary)

var result: Dictionary
var can_dismiss  = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	result = global.roll_gacha()
	_roll_animation()# Replace with function body.

func _roll_animation()-> void:
	#$Panel/ResultLabel.text = "rolling..."
	#$Panel/ResultLabel.visible = true
	#$Panel/ItemNameLabel.visible = false
	#$Panel/RarityLabel.visible = false
	#$Panel/ContinueButton.visible = false
#
	#$Animation.player.play("roll_spin")
	#await get_tree().create_timer(1.8).timeout
	#_result()
	
	#func _play_roll_animation() -> void:
	$Panel/ResultLabel.text = "Rolling..."
	$Panel/ItemNameLabel.visible = false
	$Panel/RarityLabel.visible = false
	$Panel/ContinueButton.visible = false
	# Fake spinning text
	for i in range(8):
		var fake = global.INGREDIENT_POOL[randi() % global.INGREDIENT_POOL.size()]
		$Panel/ItemNameLabel.text = fake["name"]
		$Panel/ItemNameLabel.visible = true
		await get_tree().create_timer(0.18).timeout
	_result()
	
func _result() -> void:
	$AnimationPlayer.play("reveal")
	
	$Panel/ResultLabel.text = "You got:"
	$Panel/ItemNameLabel.text = result["name"]
	$Panel/ItemNameLabel.visible = true
	
	var rarity = result["rarity"]
	$Panel/RarityLabel.text = rarity.to_upper()
	$Panel/RarityLabel.visible = true
	
	match rarity:
		"common":    $Panel/RarityLabel.add_theme_color_override("font_color", Color.WHITE)
		"rare":      $Panel/RarityLabel.add_theme_color_override("font_color", Color.CYAN)
	await get_tree().create_timer(0.5).timeout
	$Panel/ContinueButton.visible = true
	can_dismiss = true
	
	
func continue_button_press() -> void:
	if not can_dismiss:
		return
	ingredient_won.emit(result)
	queue_free()
	
func _input(event: InputEvent)-> void:
	if can_dismiss and event.is_action_pressed("ui_accept"):
		continue_button_press()
		# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta: float) -> void:
	pass
