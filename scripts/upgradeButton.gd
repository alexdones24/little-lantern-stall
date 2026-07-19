extends TextureButton

@onready var upgrade_label = $Upgrade
@onready var upgrade_hint = $UpgradeHint
@onready var click_player = $Click_Player


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	UpgradeManager.upgrades_changed.connect(update_text)
	Bank.money_changed.connect(_on_money_changed)

	upgrade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	upgrade_hint.visible = false
	update_text()


func update_text() -> void:
	var upgrade = UpgradeManager.get_current_upgrade()

	if upgrade.is_empty():
		upgrade_label.text = "Sold Out"
		upgrade_hint.visible = false
		disabled = true
		return

	upgrade_label.text = "%s = ¥%d" % [upgrade["name"], upgrade["cost"]]
	disabled = Bank.money < upgrade["cost"]


func _on_pressed() -> void:
	click_player.play()

	var bought = UpgradeManager.buy_current_upgrade()

	if bought:
		print("Upgrade bought")
	else:
		print("Not enough money")


func _on_money_changed(_new_amount: int) -> void:
	update_text()


func _on_mouse_entered() -> void:
	var upgrade = UpgradeManager.get_current_upgrade()

	if upgrade.is_empty():
		return

	upgrade_hint.text = upgrade["desc"]
	upgrade_hint.visible = true


func _on_mouse_exited() -> void:
	upgrade_hint.visible = false
