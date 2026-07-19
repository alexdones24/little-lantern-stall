extends Node2D

@onready var chairs = [
	$chair/Chair1,
	$chair/Chair2,
	$chair/Chair3,
	$chair/Chair4
]

func _ready() -> void:
	UpgradeManager.upgrades_changed.connect(update_unlocks)
	update_unlocks()

# Shows chairs based on how many are unlocked.
func update_unlocks() -> void:
	for i in range(chairs.size()):
		chairs[i].visible = i < UpgradeManager.unlocked_chairs
