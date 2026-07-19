extends CharacterBody2D

signal food_started(chair_index: int)
signal finished_eating(drop_position: Vector2, chair_index: int)
signal customer_left(chair_index: int, customer_node: Node)

@onready var sprite = $Sprite
@onready var emote_label = $EmoteLabel

var speed: float = 65.0
var target_position: Vector2 = Vector2.ZERO
var walking: bool = false

var seat_position: Vector2 = Vector2.ZERO
var exit_position: Vector2 = Vector2.ZERO
var chair_index: int = -1
var state: String = "idle"

var emotes = ["(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧", "ಠ_ʖಠ", "(˶˃⤙˂˶)", "≧◡≦", "╥﹏╥"]


func _ready() -> void:
	sprite.play("idle")
	emote_label.visible = false


func _physics_process(_delta: float) -> void:
	if not walking:
		return

	var direction = target_position - global_position

	if direction.length() > 2.0:
		velocity = direction.normalized() * speed
		move_and_slide()
	else:
		global_position = target_position
		velocity = Vector2.ZERO
		walking = false

		if state == "going_to_seat":
			arrive_at_seat()
		elif state == "going_to_exit":
			leave_stall()


# Starts the customer flow using the given seat and exit positions.
func start_customer(seat_pos: Vector2, start_pos: Vector2, new_chair_index: int) -> void:
	seat_position = seat_pos
	exit_position = start_pos
	chair_index = new_chair_index
	begin_customer_flow()


# Waits briefly, then walks to the seat.
func begin_customer_flow() -> void:
	state = "waiting_before_walk"
	sprite.play("idle")

	await get_tree().create_timer(randf_range(1.0, 2.0)).timeout

	target_position = seat_position
	state = "going_to_seat"
	sprite.play("walk_left")
	walking = true


# Begins the eating phase, then leaves after eating.
func arrive_at_seat() -> void:
	state = "eating"
	sprite.play("sit")
	food_started.emit(chair_index)
	show_random_emote()

	await get_tree().create_timer(randf_range(5.0, 10.0)).timeout

	finished_eating.emit(seat_position, chair_index)

	target_position = exit_position
	state = "going_to_exit"
	sprite.play("walk_right")
	walking = true


func show_random_emote() -> void:
	emote_label.text = emotes.pick_random()
	emote_label.visible = true

	await get_tree().create_timer(randf_range(1.0, 2.0)).timeout

	if state == "eating":
		emote_label.visible = false


# Notifies the game that this customer is leaving, then removes itself.
func leave_stall() -> void:
	customer_left.emit(chair_index, self)
	queue_free()
