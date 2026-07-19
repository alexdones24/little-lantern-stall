extends CharacterBody2D

signal reached_stop_point
signal finished_leaving

@onready var sprite = $AnimatedSprite2D

var move_speed: float = 65.0
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var is_walking: bool = false
var is_leaving: bool = false


func _ready() -> void:
	sprite.play("idle")


func _physics_process(_delta: float) -> void:
	if not is_walking or path_points.is_empty():
		return

	var target_position = path_points[current_path_index]
	var direction = target_position - global_position

	if direction.length() > 2.0:
		velocity = direction.normalized() * move_speed
		move_and_slide()
	else:
		global_position = target_position
		velocity = Vector2.ZERO
		current_path_index += 1

		if current_path_index >= path_points.size():
			is_walking = false

			if is_leaving:
				finished_leaving.emit()
				queue_free()
			else:
				sprite.play("idle_right")
				reached_stop_point.emit()


# Starts walking through all points in order when entering the scene.
func walk_path(points: Array[Vector2]) -> void:
	if points.is_empty():
		return

	path_points = points
	current_path_index = 0
	is_walking = true
	is_leaving = false
	sprite.play("walk_left")


# Starts walking through all points in order when leaving the scene.
func leave_path(points: Array[Vector2]) -> void:
	if points.is_empty():
		finished_leaving.emit()
		queue_free()
		return

	path_points = points
	current_path_index = 0
	is_walking = true
	is_leaving = true
	sprite.play("walk_right")


# Plays the party animation after a correct answer.
func play_party_animation() -> void:
	sprite.play("party")
