extends CanvasLayer

signal ingredient_won(ingredient:Dictionary)

var result: Dictionary
var can_dismiss  = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("going to roll gacha")
	result = global.roll_gacha()
	print("rolled gacha...")
	_roll_animation()# Replace with function body.

func _roll_animation()-> void:

	
	#func _play_roll_animation() -> void:
	$Panel/VBoxContainer/ResultLabel.text = "Rolling..."
	$Panel/VBoxContainer/ItemNameLabel.visible = false
	$Panel/VBoxContainer/RarityLabel.visible = false
	$Panel/VBoxContainer/ContinueButton.visible = false
	$Panel/VBoxContainer/Sprite.visible = false
	# Fake spinning text
	for i in range(8):
		var fake = global.ING_POOL[randi() % global.ING_POOL.size()]
		$Panel/VBoxContainer/ItemNameLabel.text = fake["name"]
		$Panel/VBoxContainer/ItemNameLabel.visible = true
		await get_tree().create_timer(0.18).timeout
	_result()
	
func _result() -> void:
	
	$Panel/VBoxContainer/ResultLabel.text = "You got:"
	$Panel/VBoxContainer/ItemNameLabel.text = result["name"]
	$Panel/VBoxContainer/ItemNameLabel.visible = true
	
	var rarity = result["rarity"]
	$Panel/VBoxContainer/RarityLabel.text = rarity.to_upper()
	$Panel/VBoxContainer/RarityLabel.visible = true
	
	$Panel/VBoxContainer/Sprite.visible = true
	$Panel/VBoxContainer/Sprite.play(result["name"])
	
	match rarity:
		"common":    $Panel/VBoxContainer/RarityLabel.add_theme_color_override("font_color", Color.WHITE)
		"rare":      $Panel/VBoxContainer/RarityLabel.add_theme_color_override("font_color", Color.CYAN)
	await get_tree().create_timer(0.5).timeout
	$Panel/VBoxContainer/ContinueButton.visible = true
	can_dismiss = true

	
func _input(event: InputEvent)-> void:
	if can_dismiss and event.is_action_pressed("continue") and $Panel/VBoxContainer/ContinueButton.visible == true:
		_on_continue_button_pressed()
		# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta: float) -> void:
	pass


func _on_continue_button_pressed() -> void:
	if can_dismiss:
		$Panel/VBoxContainer/ItemNameLabel.visible = false
		$Panel/VBoxContainer/RarityLabel.visible = false
		$Panel/VBoxContainer/ContinueButton.visible = false
		$Panel/VBoxContainer/ContinueButton.visible = false
		$Panel/VBoxContainer/Sprite.visible = false
		$Panel.visible = false
		signalBus.gacha_end.emit(result)
		return#
