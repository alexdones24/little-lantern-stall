extends Node2D

# ===========================================================================
# Scene resources
# ===========================================================================
var coin_scene = preload("res://scene/coin.tscn")
var food_scene = preload("res://scene/food.tscn")
var susnpc_scene = preload("res://scene/susnpc.tscn")

var click_sfx = preload("res://assets/music/denielcz-immersivecontrol-button-click-sound-463065.mp3")
var popup_sfx = preload("res://assets/music/universfield-bubble-pop-06-351337.mp3")

var playlist = [
	preload("res://assets/music/lofi by pickentcode/Autumn Colors.mp3"),
	preload("res://assets/music/lofi by pickentcode/Beloved Land.mp3"),
	preload("res://assets/music/lofi by pickentcode/Easy Beginning.mp3"),
	preload("res://assets/music/lofi by pickentcode/End of Things.mp3"),
	preload("res://assets/music/lofi by pickentcode/Japanese-SciFI trap loop.mp3"),
	preload("res://assets/music/lofi by pickentcode/Low Under the Stars.mp3"),
	preload("res://assets/music/lofi by pickentcode/Nice Home.mp3"),
	preload("res://assets/music/lofi by pickentcode/Olden New World.mp3"),
	preload("res://assets/music/lofi by pickentcode/Out of Skies.mp3"),
	preload("res://assets/music/lofi by pickentcode/Spread Tomorrow.mp3"),
	preload("res://assets/music/lofi by pickentcode/Young Spring.mp3")
]

var customer_scenes = [
	preload("res://scene/customer1.tscn"),
	preload("res://scene/customer2.tscn"),
	preload("res://scene/customer3.tscn"),
	preload("res://scene/customer4.tscn")
]

# ===========================================================================
# Main scene references
# ===========================================================================
@onready var stall_upgrade = $stall/StallUpgrade
@onready var drops = $drops
@onready var customer_start = $CustomerStart
@onready var customer_timer = $CustomerTimer
@onready var sus_npc_spawn_timer = $susNpcSpawnTimer
@onready var popup_scam_timer = $PopupScamTimer

@onready var pillars_and_lanterns = $"Pillars and Lanters"
@onready var shrine = $Shrine
@onready var starry_night = $StarryNight

@onready var ambient_player = $Ambient_Player
@onready var ocean_player = $Ocean_Player
@onready var grill_player = $Grill_Player
@onready var sfx_player = $SFX_Player

# ===========================================================================
# Chair / customer references
# ===========================================================================
@onready var chair_sit_points = [
	$stall/Chair1SitPoint,
	$stall/Chair2SitPoint,
	$stall/Chair3SitPoint,
	$stall/Chair4SitPoint
]

@onready var chair_food_points = [
	$stall/FoodPoint,
	$stall/FoodPoint2,
	$stall/FoodPoint3,
	$stall/FoodPoint4
]

@onready var customer_layers = [
	$CustomerLayers/CustomerLayer1,
	$CustomerLayers/CustomerLayer2,
	$CustomerLayers/CustomerLayer3,
	$CustomerLayers/CustomerLayer4
]

# ===========================================================================
# Sus NPC references
# ===========================================================================
@onready var sus_npc_start = $susnpc/sequence/susnpcStart
@onready var sus_npc_path_1 = $susnpc/sequence/susnpcPath
@onready var sus_npc_path_2 = $susnpc/sequence/susnpcPath2
@onready var sus_npc_path_3 = $susnpc/sequence/susnpcPath3
@onready var sus_npc_stop = $susnpc/sequence/susnpcStop

@onready var sus_npc_ui = $susnpc/ui
@onready var sus_speech_bubble = $susnpc/ui/speechBubble
@onready var sus_question_label = $susnpc/ui/speechBubble/question
@onready var sus_button_a = $susnpc/ui/speechBubble/buttonA
@onready var sus_button_b = $susnpc/ui/speechBubble/buttonB
@onready var sus_response_timer = $susnpc/ui/speechBubble/responseTimer

# ===========================================================================
# Popup scam references
# ===========================================================================
@onready var popup_ui = $popup_ui
@onready var fake_popup = $popup_ui/fakePopup
@onready var popup_title_label = $popup_ui/fakePopup/titleLabel
@onready var popup_message_label = $popup_ui/fakePopup/messageLabel
@onready var popup_button_a = $popup_ui/fakePopup/buttonA
@onready var popup_button_b = $popup_ui/fakePopup/buttonB
@onready var popup_response_timer = $popup_ui/fakePopup/popupResponseTimer

# ===========================================================================
# Effect panel references
# ===========================================================================
@onready var effect_panel = $effectPanel
@onready var effect_label = $effectPanel/effectLabel
@onready var effect_timer_label = $effectPanel/effectTimerLabel
@onready var effect_timer = $effectPanel/effectTimer

# ===========================================================================
# Food skewers on grill reference
# ===========================================================================
@onready var grill_foods = [
	$food/Food,
	$food/Food2,
	$food/Food3,
	$food/Food4,
	$food/Food5,
	$food/Food6,
	$food/Food7,
	$food/Food8,
	$food/Food9,
	$food/Food10
]

# ===========================================================================
# Customer system
# ===========================================================================
var max_customers := 4
var active_customers: Array = []
var chair_occupied = [false, false, false, false]
var active_foods = [null, null, null, null]

# ===========================================================================
# Rewards / penalties
# ===========================================================================
var base_coin_value := 100
var coin_multiplier := 1

var base_spawn_min_time := 1.0
var base_spawn_max_time := 2.5
var spawn_time_multiplier := 1.0

# ===========================================================================
# Music
# ===========================================================================
var current_track := 0

# ===========================================================================
# Sus NPC system
# ===========================================================================
var sus_spawn_min_time := 15.0
var sus_spawn_max_time := 30.0
var sus_spawn_min_time_reduced := 30.0
var sus_spawn_max_time_reduced := 50.0

var active_sus_npc: Node = null
var sus_question_active := false
var current_correct_answer := ""

var sus_questions = [
	{"question": "A stranger asks for your stall code. Your move?", "a": "Sure, friend!", "b": "Stranger Danger!", "correct": "B"},
	{"question": "You get a message saying you won free coins. Do you trust it?", "a": "Lez go!", "b": "Report!", "correct": "B"},
	{"question": "Quick! What’s your birthday and name?", "a": "Say it!", "b": "Bombastic side eye", "correct": "B"},
	{"question": "Someone rushes you for private info. Safe or sketchy?", "a": "Hell nah!", "b": "Sure!", "correct": "A"},
	{"question": "A pop-up screams 'You have 10 viruses!' Your reaction?", "a": "Click it and panic", "b": "Close it, it’s fake drama", "correct": "B"},
	{"question": "A customer shows a payment screenshot but you didn’t receive it. Next step?", "a": "Trust it, looks real enough", "b": "Check your account first", "correct": "B"},
	{"question": "A ‘supplier’ sends a random new payment link. What’s the play?", "a": "Pay quickly for the discount", "b": "Verify with your usual contact", "correct": "B"},
	{"question": "Your friend wants full access to your POS system. Best choice?", "a": "Give limited access only", "b": "Full access, they’re your friend", "correct": "A"},
	{"question": "A customer is rushing you while paying cash. How do you handle it?", "a": "Slow down and count carefully", "b": "Rush and hope for the best", "correct": "A"},
	{"question": "Someone in uniform asks to go behind your stall. What’s your response?", "a": "Let them in, looks official", "b": "Ask for ID and verify first", "correct": "B"},
	{"question": "You get an email from your bank with a weird link. What’s the safest move?", "a": "Ignore it and go to the official website directly", "b": "Click it quickly before it expires", "correct": "A"},
	{"question": "A coworker asks for your password to 'help you out.' Your response?", "a": "Share it, teamwork!", "b": "Refuse politely, passwords are private", "correct": "B"},
	{"question": "You use a strong, unique password for each account. Smart or not?", "a": "Yes, hacker-proof-ish", "b": "No, too much effort", "correct": "A"},
	{"question": "You enable two-factor authentication. Worth it?", "a": "Yes, extra security layer", "b": "No, too annoying", "correct": "A"},
	{"question": "You receive an unexpected attachment. What’s the smart move?", "a": "Open it instantly", "b": "Verify before opening", "correct": "B"}
]

# ================================================== mix up the questions answers
# Popup scam system
# ===========================================================================
var popup_active := false
var popup_correct_answer := ""

var popup_spawn_min_time := 15.0
var popup_spawn_max_time := 30.0
var popup_spawn_min_time_reduced := 30.0
var popup_spawn_max_time_reduced := 60.0

var popup_questions = [
	{
		"title": "Virus Alert!",
		"message": "Your stall has 38 viruses! Click now to clean them.",
		"a": "Close popup",
		"b": "Clean now",
		"correct": "A"
	},
	{
		"title": "Prize Winner!",
		"message": "You won free premium stall upgrades. Claim now?",
		"a": "Claim prize",
		"b": "Ignore it",
		"correct": "B"
	},
	{
		"title": "Security Warning",
		"message": "Your payment system is locked. Verify your password now.",
		"a": "Enter password",
		"b": "Close and verify safely",
		"correct": "B"
	},
	{
		"title": "Free Coins!",
		"message": "Click here to get 5000 free coins instantly.",
		"a": "No thanks",
		"b": "Take coins",
		"correct": "A"
	},
	{
		"title": "Urgent Update",
		"message": "Install this unknown update file immediately.",
		"a": "Install it",
		"b": "Ignore and verify first",
		"correct": "B"
	}
]

# ===========================================================================
# Shared effect state
# ===========================================================================
var effect_active := false
var current_effect_type := ""


func _ready() -> void:
	randomize()

	# Signals
	UpgradeManager.upgrades_changed.connect(_on_upgrades_changed)

	sus_button_a.pressed.connect(_on_sus_button_a_pressed)
	sus_button_b.pressed.connect(_on_sus_button_b_pressed)
	sus_response_timer.timeout.connect(_on_sus_response_timeout)

	popup_button_a.pressed.connect(_on_popup_button_a_pressed)
	popup_button_b.pressed.connect(_on_popup_button_b_pressed)
	popup_response_timer.timeout.connect(_on_popup_response_timeout)

	customer_timer.timeout.connect(_on_customer_timer_timeout)
	sus_npc_spawn_timer.timeout.connect(_on_sus_npc_spawn_timer_timeout)
	popup_scam_timer.timeout.connect(_on_popup_scam_timer_timeout)
	effect_timer.timeout.connect(_on_effect_timer_timeout)
	ambient_player.finished.connect(_on_ambient_player_finished)

	# Initial UI state
	sus_npc_ui.visible = false
	sus_speech_bubble.visible = false
	popup_ui.visible = false
	effect_panel.visible = false

	# Initial systems
	update_visual_upgrades()
	start_customer_timer()
	check_start_sus_npc_system()
	check_start_popup_scam_system()

	# Music / ambience
	current_track = randi() % playlist.size()
	play_next_track()
	ocean_player.play()
	grill_player.play()
	
	# Skewers on the grill
	update_visual_upgrades()
	update_grill_foods()
	start_customer_timer()
	check_start_popup_scam_system()
	check_start_sus_npc_system()


func _process(_delta: float) -> void:
	if effect_active and not effect_timer.is_stopped():
		effect_timer_label.text = str(int(ceil(effect_timer.time_left))) + "s"

	# Tiny random grill variation
	grill_player.volume_db = -22 + randf_range(-1.5, 1.5)


# ===========================================================================
# Audio helpers
# ===========================================================================
func play_click_sound() -> void:
	sfx_player.stream = click_sfx
	sfx_player.play()


func play_popup_sound() -> void:
	sfx_player.stream = popup_sfx
	sfx_player.play()


func play_next_track() -> void:
	if playlist.is_empty():
		return

	ambient_player.stream = playlist[current_track]
	ambient_player.play()

	current_track += 1
	if current_track >= playlist.size():
		current_track = 0


func _on_ambient_player_finished() -> void:
	play_next_track()


# ===========================================================================
# Upgrade / visuals
# ===========================================================================
func _on_upgrades_changed() -> void:
	update_visual_upgrades()
	update_grill_foods()
	check_start_popup_scam_system()
	check_start_sus_npc_system()


func update_visual_upgrades() -> void:
	stall_upgrade.visible = UpgradeManager.stall_upgraded
	pillars_and_lanterns.visible = UpgradeManager.lanterns_unlocked
	shrine.visible = UpgradeManager.shrine_unlocked
	starry_night.visible = UpgradeManager.starry_night_unlocked
	
	
# ===========================================================================
# Food Skewers Visuals
# ===========================================================================
func update_grill_foods() -> void:
	var visible_count := 2

	match UpgradeManager.unlocked_chairs:
		1:
			visible_count = 2
		2:
			visible_count = 5
		3:
			visible_count = 7
		4:
			visible_count = 10

	for i in range(grill_foods.size()):
		grill_foods[i].visible = i < visible_count


# ===========================================================================
# Customer flow
# ===========================================================================
func start_customer_timer() -> void:
	var min_time = base_spawn_min_time * spawn_time_multiplier
	var max_time = base_spawn_max_time * spawn_time_multiplier
	customer_timer.wait_time = randf_range(min_time, max_time)
	customer_timer.start()


func _on_customer_timer_timeout() -> void:
	try_spawn_customer()
	start_customer_timer()


func try_spawn_customer() -> void:
	if active_customers.size() >= max_customers:
		return

	var chair_index = get_random_free_chair_index()
	if chair_index == -1:
		return

	var customer_parent = customer_layers[chair_index]
	if customer_parent == null:
		return

	chair_occupied[chair_index] = true

	var customer = customer_scenes.pick_random().instantiate()
	customer_parent.add_child(customer)
	active_customers.append(customer)

	customer.global_position = customer_start.global_position
	customer.food_started.connect(_on_customer_food_started)
	customer.finished_eating.connect(_on_customer_finished_eating)
	customer.customer_left.connect(_on_customer_left)

	customer.start_customer(
		chair_sit_points[chair_index].global_position,
		customer_start.global_position,
		chair_index
	)


func get_random_free_chair_index() -> int:
	var free_indices = []

	for i in range(UpgradeManager.unlocked_chairs):
		if not chair_occupied[i]:
			free_indices.append(i)

	if free_indices.is_empty():
		return -1

	return free_indices.pick_random()


func spawn_food_at_chair(chair_index: int) -> void:
	remove_food_at_chair(chair_index)

	var food = food_scene.instantiate()
	food.global_position = chair_food_points[chair_index].global_position
	drops.add_child(food)
	food.show_food(randi() % food.get_child_count())

	active_foods[chair_index] = food


func remove_food_at_chair(chair_index: int) -> void:
	if active_foods[chair_index] != null:
		active_foods[chair_index].queue_free()
		active_foods[chair_index] = null


func spawn_coin_at_position(pos: Vector2) -> void:
	var coin = coin_scene.instantiate()
	coin.global_position = pos + Vector2(0, -8)
	drops.add_child(coin)
	coin.setup(base_coin_value * coin_multiplier)


func _on_customer_food_started(chair_index: int) -> void:
	spawn_food_at_chair(chair_index)


func _on_customer_finished_eating(_drop_position: Vector2, chair_index: int) -> void:
	remove_food_at_chair(chair_index)
	spawn_coin_at_position(chair_food_points[chair_index].global_position)


func _on_customer_left(chair_index: int, customer_node: Node) -> void:
	if chair_index >= 0 and chair_index < chair_occupied.size():
		chair_occupied[chair_index] = false

	remove_food_at_chair(chair_index)
	active_customers.erase(customer_node)


# ===========================================================================
# Shared effect system UI
# ===========================================================================
func apply_coin_buff(duration: float) -> void:
	coin_multiplier = 2
	effect_active = true
	current_effect_type = "coin_buff"

	effect_label.text = "2x Coins Drop ="
	effect_panel.visible = true
	effect_timer.wait_time = duration
	effect_timer.start()


func apply_spawn_debuff(duration: float) -> void:
	spawn_time_multiplier = 2.5
	effect_active = true
	current_effect_type = "spawn_debuff"

	effect_label.text = "Slow Customers ="
	effect_panel.visible = true

	customer_timer.stop()
	start_customer_timer()

	effect_timer.wait_time = duration
	effect_timer.start()


func _on_effect_timer_timeout() -> void:
	reset_effect()


func reset_effect() -> void:
	coin_multiplier = 1
	spawn_time_multiplier = 1.0
	effect_active = false
	current_effect_type = ""

	effect_panel.visible = false

	customer_timer.stop()
	start_customer_timer()


# ===========================================================================
# Popup scam system
# Unlocks at upgrade 2
# ===========================================================================
func check_start_popup_scam_system() -> void:
	if UpgradeManager.current_upgrade_index >= 2 and popup_scam_timer.is_stopped():
		start_popup_scam_timer()


func start_popup_scam_timer() -> void:
	if UpgradeManager.current_upgrade_index < 2:
		return

	var min_time: float
	var max_time: float

	if UpgradeManager.shrine_unlocked:
		min_time = popup_spawn_min_time_reduced
		max_time = popup_spawn_max_time_reduced
	else:
		min_time = popup_spawn_min_time
		max_time = popup_spawn_max_time

	popup_scam_timer.wait_time = randf_range(min_time, max_time)
	popup_scam_timer.start()


func _on_popup_scam_timer_timeout() -> void:
	if popup_active or sus_question_active or active_sus_npc != null or effect_active:
		start_popup_scam_timer()
		return

	show_fake_popup()
	start_popup_scam_timer()


func show_fake_popup() -> void:
	play_popup_sound()
	await get_tree().create_timer(0.3).timeout

	var popup_data = popup_questions.pick_random()

	popup_title_label.text = popup_data["title"]
	popup_message_label.text = popup_data["message"]
	popup_button_a.text = popup_data["a"]
	popup_button_b.text = popup_data["b"]
	popup_correct_answer = popup_data["correct"]

	popup_active = true
	popup_ui.visible = true
	fake_popup.visible = true
	popup_response_timer.start(8.0)


func _on_popup_button_a_pressed() -> void:
	play_click_sound()
	handle_popup_answer("A")


func _on_popup_button_b_pressed() -> void:
	play_click_sound()
	handle_popup_answer("B")


func handle_popup_answer(player_answer: String) -> void:
	if not popup_active:
		return

	popup_active = false
	popup_response_timer.stop()
	popup_ui.visible = false

	var effect_duration = randf_range(30.0, 60.0)

	if player_answer == popup_correct_answer:
		apply_coin_buff(effect_duration)
	else:
		apply_spawn_debuff(effect_duration)


func _on_popup_response_timeout() -> void:
	if not popup_active:
		return

	popup_active = false
	popup_ui.visible = false


# ===========================================================================
# Sus NPC system
# Unlocks at upgrade 3
# ===========================================================================
func check_start_sus_npc_system() -> void:
	if UpgradeManager.current_upgrade_index >= 3 and sus_npc_spawn_timer.is_stopped():
		start_sus_npc_spawn_timer()


func start_sus_npc_spawn_timer() -> void:
	var min_time: float
	var max_time: float

	if UpgradeManager.shrine_unlocked:
		min_time = sus_spawn_min_time_reduced
		max_time = sus_spawn_max_time_reduced
	else:
		min_time = sus_spawn_min_time
		max_time = sus_spawn_max_time

	sus_npc_spawn_timer.wait_time = randf_range(min_time, max_time)
	sus_npc_spawn_timer.start()


func _on_sus_npc_spawn_timer_timeout() -> void:
	if UpgradeManager.current_upgrade_index < 3:
		return

	if active_sus_npc == null and not effect_active:
		spawn_sus_npc()

	start_sus_npc_spawn_timer()


func spawn_sus_npc() -> void:
	if active_sus_npc != null:
		return

	var sus_npc = susnpc_scene.instantiate()
	add_child(sus_npc)
	sus_npc.global_position = sus_npc_start.global_position

	var walk_points: Array[Vector2] = [
		sus_npc_path_1.global_position,
		sus_npc_path_2.global_position,
		sus_npc_path_3.global_position,
		sus_npc_stop.global_position
	]

	sus_npc.walk_path(walk_points)
	sus_npc.reached_stop_point.connect(_on_sus_npc_reached_stop)
	sus_npc.finished_leaving.connect(_on_sus_npc_finished_leaving)

	active_sus_npc = sus_npc


func _on_sus_npc_reached_stop() -> void:
	show_sus_question()


func show_sus_question() -> void:
	if active_sus_npc == null:
		return

	var question_data = sus_questions.pick_random()

	sus_question_label.text = question_data["question"]
	sus_button_a.text = question_data["a"]
	sus_button_b.text = question_data["b"]
	current_correct_answer = question_data["correct"]

	sus_question_active = true
	sus_npc_ui.visible = true
	sus_speech_bubble.visible = true
	sus_question_label.visible = true
	sus_button_a.visible = true
	sus_button_b.visible = true

	sus_response_timer.start()


func _on_sus_button_a_pressed() -> void:
	play_click_sound()
	handle_sus_answer("A")


func _on_sus_button_b_pressed() -> void:
	play_click_sound()
	handle_sus_answer("B")


func handle_sus_answer(player_answer: String) -> void:
	if not sus_question_active:
		return

	sus_question_active = false
	sus_response_timer.stop()
	sus_speech_bubble.visible = false

	var effect_duration = randf_range(60.0, 120.0)

	if player_answer == current_correct_answer:
		if active_sus_npc != null:
			active_sus_npc.play_party_animation()
			await get_tree().create_timer(1.5).timeout
		apply_coin_buff(effect_duration)
	else:
		apply_spawn_debuff(effect_duration)

	make_sus_npc_leave()


func _on_sus_response_timeout() -> void:
	if not sus_question_active:
		return

	sus_question_active = false
	sus_speech_bubble.visible = false
	make_sus_npc_leave()


func make_sus_npc_leave() -> void:
	if active_sus_npc == null:
		return

	var leave_points: Array[Vector2] = [
		sus_npc_path_3.global_position,
		sus_npc_path_2.global_position,
		sus_npc_path_1.global_position,
		sus_npc_start.global_position
	]

	active_sus_npc.leave_path(leave_points)


func _on_sus_npc_finished_leaving() -> void:
	active_sus_npc = null
	sus_npc_ui.visible = false
	sus_speech_bubble.visible = false
