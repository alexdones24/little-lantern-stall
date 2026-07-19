extends Label

func _ready() -> void:
	text = "¥" + str(Bank.money)
	Bank.money_changed.connect(update_money)

# Updates the money text when the player's money changes.
func update_money(new_amount: int) -> void:
	text = "¥" + str(new_amount)
