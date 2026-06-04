extends CanvasLayer

signal cooking_done

enum Phase { SELECT_RECIPE, MINIGAME, EAT_RESULT }

var current_phase = Phase.SELECT_RECIPE
var selected_recipe: Dictionary = {}
var chop_count = 0
var chops_needed = 5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_show_recipe_select()

# ── Phase 1: Recipe Selection ─────────────────────────────────────────

func _show_recipe_select() -> void:
	current_phase = Phase.SELECT_RECIPE
	$RecipePanel.visible = true
	$MinigamePanel.visible = false
	$ResultPanel.visible = false
	
	# Clear old buttons
	for child in $RecipePanel/RecipeList.get_children():
		child.queue_free()
	
	var any_available = false
	for recipe in global.RECIPES:
		if _can_cook(recipe):
			any_available = true
			var btn = Button.new()
			btn.text = "%s\n%s" % [recipe["name"], recipe["description"]]
			btn.pressed.connect(func(): _select_recipe(recipe))
			$RecipePanel/RecipeList.add_child(btn)
	
	if not any_available:
		var lbl = Label.new()
		lbl.text = "Not enough ingredients yet!\nKeep fighting!"
		$RecipePanel/RecipeList.add_child(lbl)
	
	$RecipePanel/SkipButton.visible = true

func _can_cook(recipe: Dictionary) -> bool:
	for ingredient in recipe["needs"]:
		var needed = recipe["needs"][ingredient]
		var have = global.ingredients.get(ingredient, 0)
		if have < needed:
			return false
	return true

func _select_recipe(recipe: Dictionary) -> void:
	selected_recipe = recipe
	_start_minigame()

func _on_skip_button_pressed() -> void:
	cooking_done.emit()
	queue_free()

# ── Phase 2: Cutting Minigame ─────────────────────────────────────────

func _start_minigame() -> void:
	current_phase = Phase.MINIGAME
	chop_count = 0
	$RecipePanel.visible = false
	$MinigamePanel.visible = true
	$ResultPanel.visible = false
	
	$MinigamePanel/InstructionLabel.text = "Chop the ingredient!\nPress [Space] or tap rapidly!"
	$MinigamePanel/ProgressBar.max_value = chops_needed
	$MinigamePanel/ProgressBar.value = 0
	$MinigamePanel/ChopButton.visible = true
	
	# Animate the ingredient sprite bobbing
	$MinigamePanel/IngredientSprite.visible = true
	$MinigamePanel/AnimationPlayer.play("ingredient_idle")


func _input(event: InputEvent) -> void:
	if current_phase == Phase.MINIGAME:
		if event.is_action_just_pressed("ui_accept"):
			_on_chop_pressed()

func _finish_minigame() -> void:
	$MinigamePanel/AnimationPlayer.play("cooking_complete")
	$MinigamePanel/InstructionLabel.text = "✓ Dish ready!"
	$MinigamePanel/ChopButton.visible = false
	await get_tree().create_timer(1.2).timeout
	_show_eat_result()

# ── Phase 3: Eat & get buff ───────────────────────────────────────────

func _show_eat_result() -> void:
	current_phase = Phase.EAT_RESULT
	$MinigamePanel.visible = false
	$ResultPanel.visible = true
	
	$ResultPanel/DishNameLabel.text = selected_recipe["name"]
	$ResultPanel/BuffLabel.text = "Buff gained:\n" + selected_recipe["description"]
	
	# Consume ingredients
	for ingredient in selected_recipe["needs"]:
		global.ingredients[ingredient] -= selected_recipe["needs"][ingredient]
		if global.ingredients[ingredient] <= 0:
			global.ingredients.erase(ingredient)

func _on_eat_button_pressed() -> void:
	# Apply permanent buff
	global.apply_dish_buff(selected_recipe)
	
	# Also apply to the live player node if it exists
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p.has_method("apply_buffs"):
			p.apply_buffs()
	
	cooking_done.emit()
	queue_free()


func _on_chop_pressed() -> void:
	if current_phase != Phase.MINIGAME:
		return
	chop_count += 1
	$MinigamePanel/ProgressBar.value = chop_count
	$MinigamePanel/AnimationPlayer.play("chop_flash")
	
	# Screenshake / sound can be triggered here
	
	if chop_count >= chops_needed:
		_finish_minigame()
