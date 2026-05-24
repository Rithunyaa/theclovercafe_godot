extends Node2D

var customer_images = [
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep1.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep2.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep3.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep4.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep5.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep6.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep7.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep8.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep9.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep10.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep11.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep12.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep13.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep14.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep15.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep16.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep17.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep18.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep19.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep20.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep21.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep22.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep23.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep24.png"),
	preload("res://assets/images/CafeScene/customers/CreepitchiPack_ODDBLOT/CreepitchiPack_ODDBLOT/Creep25.png"),
]

var customer_scene = preload("res://customer.tscn")
var order_bubble_scene = preload("res://order_bubble.tscn")
var patience_bar_scene = preload("res://patience_bar.tscn")
var customers = []
var spawn_timer = 0.0
var spawn_interval = 5.0
var stop_x = 1000
var customer_gap = 280
var menu_items = {"black_coffee": preload("res://assets/images/CafeScene/order_items/Naj's Baked Good Assets/Naj's Baked Good Assets/Coffee To Go.png")}
var machine_brewing = false
var machine_ready = false
var holding_cup = false
var cup_follows_mouse = false
var coins = 0
var customers_served = 0
var customers_angry = 0
var game_time = 180.0
var game_over = false

func _ready():
	spawn_customer()
	$coin_label.text = "Coins: 0"
	$end_popup.visible = false
	$fade_rect.color.a = 1.0
	await get_tree().process_frame
	var tween = create_tween()
	tween.tween_property($fade_rect, "color:a", 0.0, 1.5)
	$end_popup/retry_btn.pressed.connect(_on_retry)
	$end_popup/menu_btn.pressed.connect(_on_menu)

func _on_retry():
	get_tree().change_scene_to_file("res://cafe_scene.tscn")

func _on_menu():
	get_tree().change_scene_to_file("res://homescreen.tscn")

func spawn_customer():
	if game_over:
		return
	if customers.size() >= 4:
		return
	var c = customer_scene.instantiate()
	var b = order_bubble_scene.instantiate()
	var p = patience_bar_scene.instantiate()
	add_child(c)
	add_child(b)
	add_child(p)
	var active_indices = []
	for cust in customers:
		active_indices.append(cust["image_index"])
	var available_indices = []
	for i in range(customer_images.size()):
		if not active_indices.has(i):
			available_indices.append(i)
	var random_index = available_indices[randi() % available_indices.size()]
	c.texture = customer_images[random_index]
	c.position = Vector2(-200, 350)
	c.scale = Vector2(0.25, 0.35)
	p.visible = false
	p.rotation_degrees = -90
	p.scale = Vector2(0.3, 0.5)
	b.visible = false
	var roll = randf()
	var quantity = 1
	if roll > 0.6:
		quantity = 2
	customers.append({"sprite": c, "bubble": b, "patience": p, "moving": true, "bob_offset": 0.0, "order": "black_coffee", "quantity": quantity, "original_quantity": quantity, "leaving": false, "leave_offset": 0.0, "patience_done": false, "image_index": random_index})

func setup_bubble(cust):
	var b = cust["bubble"]
	var p = cust["patience"]
	b.get_node("item_sprite").texture = menu_items[cust["order"]]
	b.get_node("item_sprite").scale = Vector2(0.2, 0.2)
	b.get_node("quantity_label").text = "x" + str(cust["quantity"])
	p.visible = true
	p.position = cust["sprite"].position + Vector2(0, -200)
	p.play("ticking")
	p.animation_finished.connect(_on_patience_run_out.bind(cust))

func _on_patience_run_out(cust):
	if not cust["leaving"] and not cust["patience_done"]:
		cust["patience_done"] = true
		cust["bubble"].visible = false
		cust["patience"].visible = false
		cust["leaving"] = true
		cust["leave_offset"] = 0.0
		customers_angry += 1
		await get_tree().create_timer(2.5).timeout
		spawn_customer()

func show_game_over():
	game_over = true
	machine_brewing = false
	machine_ready = false
	holding_cup = false
	cup_follows_mouse = false
	$coffee_cup.visible = false
	for cust in customers:
		cust["moving"] = false
		cust["leaving"] = false
		if cust.has("patience"):
			cust["patience"].stop()
	$end_popup.visible = true
	$end_popup/coins_label.text = "Coins Earned: " + str(coins)
	$end_popup/served_label.text = "Customers Served: " + str(customers_served)
	$end_popup/angry_label.text = "Customers Lost: " + str(customers_angry)

func _input(event):
	if game_over:
		return
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if $coffee_machine.global_position.distance_to(mouse_pos) < 80:
			if not machine_brewing and not machine_ready:
				start_brewing()
			elif machine_ready:
				collect_cup()
				return
		if holding_cup:
			for cust in customers:
				if not cust["moving"] and not cust["leaving"]:
					var dist = cust["sprite"].global_position.distance_to(mouse_pos)
					var bubble_dist = cust["bubble"].global_position.distance_to(mouse_pos)
					if dist < 100 or bubble_dist < 80:
						serve_customer(cust)
						return
	if event is InputEventMouseMotion and cup_follows_mouse:
		$coffee_cup.global_position = get_global_mouse_position()

func start_brewing():
	machine_brewing = true
	machine_ready = false
	$machine_start_sound.play()
	$coffee_machine.play("brewing")
	await $coffee_machine.animation_finished
	machine_brewing = false
	machine_ready = true
	$coffee_machine.stop()
	$coffee_machine.frame = 4
	$machine_ready_sound.play()

func collect_cup():
	machine_ready = false
	holding_cup = true
	cup_follows_mouse = true
	$coffee_cup.visible = true
	$coffee_cup.global_position = get_global_mouse_position()
	$coffee_machine.frame = 0

func serve_customer(cust):
	holding_cup = false
	cup_follows_mouse = false
	$coffee_cup.visible = false
	cust["quantity"] -= 1
	if cust["quantity"] <= 0:
		customers_served += 1
		if cust["original_quantity"] == 2:
			coins += 30
		else:
			coins += 10
		$coin_label.text = "Coins: " + str(coins)
		cust["patience_done"] = true
		cust["bubble"].visible = false
		cust["patience"].visible = false
		cust["leaving"] = true
		cust["leave_offset"] = 0.0
		await get_tree().create_timer(2.5).timeout
		spawn_customer()
	else:
		cust["bubble"].get_node("quantity_label").text = "x" + str(cust["quantity"])

func _process(delta):
	if game_over:
		return
	game_time -= delta
	@warning_ignore("integer_division")
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	$timer_label.text = "%d:%02d" % [minutes, seconds]
	if game_time <= 0:
		show_game_over()
		return
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_customer()
	for i in range(customers.size() - 1, -1, -1):
		var cust = customers[i]
		if cust["leaving"]:
			cust["leave_offset"] += delta * 2.0
			var new_x = cust["sprite"].position.x + 200 * delta
			var new_y = 350 + sin(cust["leave_offset"]) * 15.0
			cust["sprite"].position = Vector2(new_x, new_y)
			if cust["sprite"].position.x > 1400:
				cust["sprite"].queue_free()
				cust["bubble"].queue_free()
				cust["patience"].queue_free()
				customers.remove_at(i)
		elif cust["moving"]:
			cust["bob_offset"] += delta * 2.0
			var target_x = stop_x - (i * customer_gap)
			var new_x = cust["sprite"].position.x + 200 * delta
			var new_y = 350 + sin(cust["bob_offset"]) * 15.0
			cust["sprite"].position = Vector2(min(new_x, target_x), new_y)
			if cust["sprite"].position.x >= target_x:
				cust["moving"] = false
				cust["bubble"].visible = true
				cust["bubble"].position = cust["sprite"].position + Vector2(180, -150)
				setup_bubble(cust)
		else:
			var target_x = stop_x - (i * customer_gap)
			if abs(cust["sprite"].position.x - target_x) > 2:
				cust["bob_offset"] += delta * 2.0
				var new_x = move_toward(cust["sprite"].position.x, target_x, 200 * delta)
				var new_y = 350 + sin(cust["bob_offset"]) * 15.0
				cust["sprite"].position = Vector2(new_x, new_y)
				cust["bubble"].position = cust["sprite"].position + Vector2(180, -150)
				cust["patience"].position = cust["sprite"].position + Vector2(0, -200)
