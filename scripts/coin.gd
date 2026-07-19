extends Area2D

@onready var popup_text = $PopupText
@onready var click_player = $Click_Player

var coin_value: int = 100


func _ready() -> void:
	input_pickable = true
	popup_text.visible = false
	popup_text.modulate.a = 0.0


func _input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click"):
		collect_money()


# Sets how much this coin is worth.
func setup(value: int) -> void:
	coin_value = value


# Gives money to the player and plays the collection animation.
func collect_money() -> void:
	click_player.play()
	Bank.add_money(coin_value)
	input_pickable = false

	popup_text.visible = true
	popup_text.text = "+%d yen" % coin_value
	popup_text.position = Vector2(-20, -20)
	popup_text.modulate.a = 1.0

	var coin_tween = create_tween()
	coin_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	coin_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	coin_tween.tween_property(self, "position:y", position.y - 25, 0.3) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	coin_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)

	var text_tween = create_tween()
	text_tween.tween_property(popup_text, "position:y", popup_text.position.y - 20, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	text_tween.parallel().tween_property(popup_text, "modulate:a", 0.0, 0.6)

	coin_tween.finished.connect(queue_free)
