extends CanvasLayer

signal cooking_done

enum Phase { SELECT_RECIPE, CHOP, EAT_RESULT, WASH, COOK }

var current_phase = Phase.SELECT_RECIPE
var selected_recipe: Dictionary = {}

# Queue of minigame tasks to complete: [{ingredient, type}]
var task_queue: Array = []
var current_task: Dictionary = {}

# Shared tap progress (wash + chop)
var tap_count := 0
const TAPS_NEEDED := 5

# Flip mechanic state
var flip_zone_min := 0.35   # fraction of bar where green zone starts
var flip_zone_max := 0.65
var flip_marker_pos := 0.0  # 0.0 – 1.0, moves over time
var flip_direction := 1.0
const FLIP_SPEED := 0.6     # how fast the marker moves (fraction per second)
var flip_done := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_show_recipe_select()



# ── Phase 1: Recipe Selection ─────────────────────────────────────────

func _show_recipe_select() -> void:

	
	current_phase = Phase.SELECT_RECIPE
	$RecipePanel.visible = true
	$MinigamePanel.visible = false
	$ResultPanel.visible = false
	$CookPanel.visible = false
	
	# Clear old buttons
	for child in $RecipePanel/VBoxContainer/recipe_list.get_children():
		child.queue_free()
	
	var any_available = false
	for recipe in global.RECIPES:
		if _can_cook(recipe):
			any_available = true
			var btn = Button.new()
			btn.text = "%s\n%s" % [recipe["name"], recipe["description"]]
			btn.focus_mode = Control.FOCUS_NONE 
			btn.pressed.connect(func(): _select_recipe(recipe))
			$RecipePanel/VBoxContainer/recipe_list.add_child(btn)
	
	if not any_available:
		var lbl = Label.new()
		lbl.text = "Not enough ingredients yet!\nKeep fighting!"
		$RecipePanel/VBoxContainer/recipe_list.add_child(lbl)
	
	$RecipePanel/VBoxContainer/skip.visible = true
	
	global.current_count=0
	


func _can_cook(recipe: Dictionary) -> bool:
	for ingredient in recipe["needs"]:
		if global.ingredients.get(ingredient, 0) < recipe["needs"][ingredient]:
			return false
	return true

func _select_recipe(recipe: Dictionary) -> void:
	selected_recipe = recipe
	task_queue = _build_queue(recipe)
	_next_task()


func _build_queue(recipe: Dictionary) -> Array:
	var queue = []
	for ing_name in recipe["needs"]:
		var ing_type = global.get_ingredient_type(ing_name)
		match ing_type:
			"vegetable":
				queue.append({"ingredient": ing_name, "type": "wash"})
				queue.append({"ingredient": ing_name,"type": "chop"})
			"meat":
				queue.append({"ingredient": ing_name, "type": "cook"})
	return queue
func _on_skip_button_pressed() -> void:
	cooking_done.emit()
	queue_free()

func _next_task() -> void:
	if task_queue.is_empty():
		_show_eat_result()
		return
	current_task = task_queue.pop_front()
	match current_task["type"]:
		"wash": _start_wash()
		"chop": _start_chop()
		"cook": _start_cook()

# ── Phase 2: Cutting Minigame ─────────────────────────────────────────

func _start_wash() -> void:
	current_phase = Phase.WASH
	tap_count = 0
	
	$RecipePanel.visible = false
	$WashPanel.visible = true
	$MinigamePanel.visible = false
	$CookPanel.visible = false
	$ResultPanel.visible = false
	
	$WashPanel/VBoxContainer/Instruction.text = \
	"Wash the %s!\nPress [Space] or tap rapidly!"% current_task["ingredient"]
	$WashPanel/VBoxContainer/ProgressBar.max_value = TAPS_NEEDED
	$WashPanel/VBoxContainer/ProgressBar.value = 0
	$WashPanel/AnimatedSprite2D.play("default")

func _on_wash_pressed() -> void:
	if current_phase != Phase.WASH:
		return
	tap_count +=1
	$WashPanel/VBoxContainer/ProgressBar.value = tap_count
	if tap_count >= TAPS_NEEDED:
		$WashPanel/VBoxContainer/Instruction.text = "All clean!"
		await get_tree().create_timer(0.8).timeout
		_next_task()


func _start_chop() -> void:
	current_phase = Phase.COOK
	
	$RecipePanel.visible = false
	$MinigamePanel.visible = true
	$CookPanel.visible = false
	$ResultPanel.visible = false
	
	$MinigamePanel/VBoxContainer/Instruction.text = \
	"Chop the ingredient! Press [Space] or tap" % current_task["ingredient"]
	$MinigamePanel/VBoxContainer/ProgressBar.max_value = TAPS_NEEDED
	$MinigamePanel/VBoxContainer/ProgressBar.value = 0
	$MinigamePanel/VBoxContainer/CHOP.visible = true
	
	# Animate the ingredient sprite bobbing
	$MinigamePanel/AnimatedSprite2D.visible = true
	$MinigamePanel/AnimatedSprite2D.play("default")

			

func _finish_minigame() -> void:
	#$MinigamePanel/AnimationPlayer.play("cooking_complete")
	$MinigamePanel/VBoxContainer/Instruction.text = "✓ Dish ready!"
	$MinigamePanel/VBoxContainer/CHOP.visible = false
	await get_tree().create_timer(1.2).timeout
	_show_eat_result()

# ── Phase 3: Eat & get buff ───────────────────────────────────────────

func _on_chop_pressed() -> void:
	if current_phase != Phase.CHOP:
		return
	tap_count += 1
	$MinigamePanel/VBoxContainer/ProgressBar.value = tap_count
	if tap_count>= TAPS_NEEDED:
		$MinigamePanel/VBoxContainer/Instruction.text = "All chopped!"
		$MinigamePanel/VBoxContainer/CHOP.visible = false
		await get_tree().create_timer(0.8).timeout
		_next_task()
	
	# Screenshake / sound can be triggered here

func _start_cook() -> void:
	current_phase = Phase.COOK
	flip_done = false
	flip_marker_pos = 0.0
	flip_direction = 1.0
	
	$WashPanel.visible = false
	$MinigamePanel.visible = false
	$CookPanel.visible = true
	$ResultPanel.visible = false
	
	$CookPanel/VBoxContainer/Instruction.text = \
	"cook the %s !\n Flip it in the middle!" % current_task["ingredient"]
	$CookPanel/VBoxContainer.FLIP.visible = true
	$CookPanel/AnimatedSprite2D.play("default")
	
func _process (delta: float)-> void:
	if current_phase != Phase.COOK or flip_done:
		return
	flip_marker_pos += flip_direction * FLIP_SPEED * delta
	if flip_marker_pos >= 1.0:
		flip_marker_pos = 1.0
		flip_direction = -1.0
	elif flip_marker_pos <=0.0:
		flip_marker_pos = 0.0
		flip_direction = 1.0
	$CookPanel/VBoxContainer/FlipBar.value = flip_marker_pos*100
	
	var in_zone = flip_marker_pos >= flip_zone_min and flip_marker_pos <= flip_zone_max
	$CookPanel/VBoxContainer/ZoneIindicator.modulate = Color.GREEN if in_zone else Color.RED
	

func _on_flip_pressed() -> void:
	if current_phase != Phase.COOK or flip_done:
		return
	flip_done = true
	$CookPanel/VBoxContainer/FLIP.visible = false
	
	var in_zone = flip_marker_pos >= flip_zone_min and flip_marker_pos <= flip_zone_max
	if in_zone:
		$CookPanel/VBoxContainer/Instruction.text = "Nice Flip!"
	else:
		$CookPanel/VBoxContainer/Instruction.text = "It's...edible."
	
	await get_tree().create_timer(1.0).timeout
	
	_next_task()


func _show_eat_result() -> void:
	current_phase = Phase.EAT_RESULT
	$MinigamePanel.visible = false
	$ResultPanel.visible = true
	$WashPanel.visible = false
	$CookPanel.visible = false
	
	$ResultPanel/dish.visible = true
	$ResultPanel/dish.play("default")
	
	$ResultPanel/VBoxContainer/DishNameLabel.text = selected_recipe["name"]
	$ResultPanel/VBoxContainer/BuffLabel.text = "Buff gained:\n" + selected_recipe["description"]
	
	# Consume ingredients
	for ingredient in selected_recipe["needs"]:
		global.ingredients[ingredient] -= selected_recipe["needs"][ingredient]
		if global.ingredients[ingredient] <= 0:
			global.ingredients.erase(ingredient)



func _on_eat_pressed() -> void:
	global.apply_dish_buff(selected_recipe)
	
	# Also apply to the live player node if it exists
	var players = get_tree().get_nodes_in_group("player")
	global.update_player_buff()
	for p in players:
		if p.has_method("apply_buffs"):
			p.apply_buffs()
	
	signalBus.cooking_done.emit()
	queue_free()
