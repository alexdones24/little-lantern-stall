extends Node

signal upgrades_changed

var unlocked_chairs: int = 1
var current_upgrade_index: int = 0

var stall_upgraded: bool = false
var lanterns_unlocked: bool = false
var shrine_unlocked: bool = false
var starry_night_unlocked: bool = false

var upgrades = [
	{
		"id": "chair_2",
		"name": "Chair 2",
		"cost": 400,
		"desc": "Unlock 2nd chair - increase customer"
	},
	{
		"id": "stall_upgrade",
		"name": "Stall",
		"cost": 800,
		"desc": "Upgrade your stall appearance"
	},
	{
		"id": "chair_3",
		"name": "Chair 3",
		"cost": 1500,
		"desc": "Unlock 3rd chair - increase customer"
	},
	{
		"id": "lanterns",
		"name": "Lanterns",
		"cost": 2500,
		"desc": "Decorate the stall with lanterns and pillars"
	},
	{
		"id": "chair_4",
		"name": "Chair 4",
		"cost": 4000,
		"desc": "Unlock 4th chair - increase customer"
	},
	{
		"id": "starry_night",
		"name": "Starry Night",
		"cost": 6000,
		"desc": "Unlock starry night scenery"
	},
	{
		"id": "shrine",
		"name": "Shrine",
		"cost": 10000,
		"desc": "Unlock Shrine protection - reduce Sus NPC spawn"
	}
]


# Returns the current upgrade the player can buy.
func get_current_upgrade() -> Dictionary:
	if current_upgrade_index >= upgrades.size():
		return {}
	return upgrades[current_upgrade_index]


# Checks if the player can afford the current upgrade.
func can_buy_current_upgrade() -> bool:
	var upgrade = get_current_upgrade()

	if upgrade.is_empty():
		return false

	return Bank.money >= upgrade["cost"]


# Buys the current upgrade if possible.
func buy_current_upgrade() -> bool:
	var upgrade = get_current_upgrade()

	if upgrade.is_empty():
		return false

	var cost = upgrade["cost"]

	if not Bank.spend_money(cost):
		return false

	apply_upgrade(upgrade["id"])
	current_upgrade_index += 1
	upgrades_changed.emit()
	return true


# Applies the purchased upgrade effect.
func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"stall_upgrade":
			stall_upgraded = true
		"chair_2":
			unlocked_chairs = 2
		"lanterns":
			lanterns_unlocked = true
		"chair_3":
			unlocked_chairs = 3
		"chair_4":
			unlocked_chairs = 4
		"starry_night":
			starry_night_unlocked = true
		"shrine":
			shrine_unlocked = true
