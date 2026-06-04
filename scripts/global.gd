extends Node2D

var player_atk_rn = false
var current_wave: int
var next_wave: bool

var ingredients: Dictionary = {}

const COOK_TRIG_COUNT = 5

var bonus_health: int = 0
var bonus_atk: int = 0

const ING_POOL = [
	{"name": "Lettuce", "rarity:": "common", "color": Color(0.6,0.3,0.1)},
	{"name": "Tomato", "rarity:": "common", "color": Color(0.6,0.3,0.1)},
	{"name": "Ham", "rarity:": "rare", "color": Color(0.6,0.3,0.1)},
	{"name": "Bread", "rarity:": "rare", "color": Color(0.6,0.3,0.1)},
]

const RECIPES = [
	{
	"name":"Salad",
	"needs": {"Lettuce":2, "Tomato":2},
	"buff":{"max_health":0, "attack":5},
	"description": "+5 health"
	},
	{
	"name":"Sandwich",
	"needs": {"Lettuce":1, "Tomato":1, "Ham": 1, "Bread": 2},
	"buff":{"max_health":5, "attack":10},
	"description": "+5 health, +10 attack"
	}
]

func add_ingredient(ingredient_name: String)-> void:
	if ingredients.has(ingredient_name):
		ingredients[ingredient_name]+=1
	else:
		ingredients[ingredient_name]=1

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
		
	var pool = ING_POOL.filter(func(i): return i["rarity"] == rarity)
	if pool.is_empty():
		pool = ING_POOL  # fallback
	return pool[randi() % pool.size()]
	
func apply_dish_buff(recipe: Dictionary) -> void:
	var buff = recipe["buff"]
	bonus_health += buff["max_health"]
	bonus_atk += buff["attack"]
