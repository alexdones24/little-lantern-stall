extends Node2D

# Shows one food child and plays its eating animation if available.
func show_food(food_index: int) -> void:
	for child in get_children():
		child.visible = false

		if child is AnimatedSprite2D:
			child.stop()

	if food_index >= 0 and food_index < get_child_count():
		var selected_food = get_child(food_index)
		selected_food.visible = true

		if selected_food is AnimatedSprite2D:
			selected_food.play("eat")
