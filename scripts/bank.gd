extends Node

signal money_changed(new_amount)

var money: int = 2000000

# Adds money and updates the UI.
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

# Tries to spend money.
# Returns true if purchase succeeds, false if not enough money.
func spend_money(amount: int) -> bool:
	if money < amount:
		return false

	money -= amount
	money_changed.emit(money)
	return true
