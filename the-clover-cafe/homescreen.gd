extends Node2D

@onready var new_game_btn = $newgame_button
@onready var music = $AudioStreamPlayer2D
@onready var click_sound = $ButtonClick

func _ready():
	_setup_button(new_game_btn)
	music.play()

func _on_new_game_pressed():
	print("button pressed")
	var tween = create_tween()
	tween.tween_property($fade_rect, "modulate:a", 1.0, 1.0)
	print("tween started")
	await tween.finished
	print("tween finished, changing scene")
	get_tree().change_scene_to_file("res://instructions.tscn")

func _setup_button(btn):
	await get_tree().process_frame
	btn.pivot_offset = btn.size / 2
	btn.mouse_entered.connect(_on_hover.bind(btn))
	btn.mouse_exited.connect(_on_unhover.bind(btn))
	btn.button_down.connect(_on_pressed.bind(btn))
	btn.button_up.connect(_on_unhover.bind(btn))
	if btn == new_game_btn:
		btn.pressed.connect(_on_new_game_pressed)
	else:
		btn.pressed.connect(_on_click)

func _on_hover(btn):
	btn.scale = Vector2(1.1, 1.1)

func _on_unhover(btn):
	btn.scale = Vector2(1.0, 1.0)

func _on_pressed(btn):
	btn.scale = Vector2(0.95, 0.95)

func _on_click():
	click_sound.play()
