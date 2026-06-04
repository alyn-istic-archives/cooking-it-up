extends Node

var player_atk_rn = false
var current_wave: int
var next_wave: bool

var ingredients: Dictionary = {}

const COOK_TRIG_COUNT = 3
var current_count = 0

var bonus_health: int = 0
var bonus_atk: int = 0

var ING_POOL = [
	{"name": "Lettuce", "rarity": "common"},
	{"name": "Tomato", "rarity": "common"},
	{"name": "Ham", "rarity": "rare"},
	{"name": "Bread", "rarity": "rare"},
]

const RECIPES = [
	{
	"name":"Salad",
	"needs": {"Lettuce":1, "Tomato":1},
	"buff":{"max_health":0, "attack":5},
	"description": "+5 health", "chops_required": 2
	},
	{
	"name":"Sandwich",
	"needs": {"Lettuce":1, "Tomato":1, "Ham": 1, "Bread": 2},
	"buff":{"max_health":5, "attack":10},
	"description": "+5 health, +10 attack", "chops_required": 3
	}
]

func add_ingredient(ingredient_name: String)-> void:
	if ingredients.has(ingredient_name):
		ingredients[ingredient_name]+=1
		current_count+=1
	else:
		ingredients[ingredient_name]=1
		current_count +=1

func total_ingredients() -> int:
	var total = 0
	for key in ingredients:
		total += ingredients[key]
	return total

func roll_gacha() -> Dictionary:
   	# Weighted rarity roll
	var roll = randf()
	var rarity: String
	if roll < 0.55:
		rarity = "common"
	elif roll < 0.80:
		rarity = "rare"
	else:
		rarity = "legendary"
		
	var pool: Array = []
	
	for ingredient in ING_POOL:
		if ingredient["rarity"] == rarity:
			pool.append(ingredient)
	if pool.is_empty():
		pool = ING_POOL 
	return pool[randi() % pool.size()]
	
func apply_dish_buff(recipe: Dictionary) -> void:
	var buff = recipe["buff"]
	bonus_health += buff["max_health"]
	bonus_atk += buff["attack"]
