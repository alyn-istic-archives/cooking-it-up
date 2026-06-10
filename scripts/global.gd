extends Node

var player_atk_rn = false
var current_wave: int
var next_wave: bool

var ingredients: Dictionary = {}


var max_health: int = 100
var bonus_health: int = 0
var max_atk: int = 20
var bonus_atk: int = 0

var ING_POOL = [
	{"name": "Lettuce", "rarity": "common", "type": "vegetable"},
	{"name": "Tomato", "rarity": "common", "type": "vegetable"},
	{"name": "Meat", "rarity": "rare", "type": "meat"},
	{"name": "Bread", "rarity": "rare", "type": "other"},
]

const RECIPES = [
	{
	"name":"Salad",
	"needs": {"Lettuce":1, "Tomato":1},
	"buff":{"max_health":0, "attack":5},
	"description": "+5 attack"
	},
	{
	"name":"Sandwich",
	"needs": {"Lettuce":1, "Tomato":1, "Meat": 1},
	"buff":{"max_health":5, "attack":10},
	"description": "+5 health, +10 attack"
	}
]

func add_ingredient(ingredient_name: String)-> void:
	if ingredients.has(ingredient_name):
		ingredients[ingredient_name]+=1

	else:
		ingredients[ingredient_name]=1


func get_ingredient_type(ing_name: String) -> String:
	for ing in ING_POOL:
		if ing["name"] == ing_name:
			return ing.get("type", "other")
	return "other"

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

func update_player_buff():
	max_atk += bonus_atk
	max_health += bonus_health
	print("max attack:", max_atk)
	print("max health:", max_health)
func apply_dish_buff(recipe: Dictionary) -> void:
	var buff = recipe["buff"]
	bonus_health = buff["max_health"]
	bonus_atk = buff["attack"]
