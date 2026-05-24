extends Control

var typing = true

func _ready():
	$RichTextLabel.visible_characters = 0
	$Button.visible = false
	var tween = create_tween()
	tween.tween_property($RichTextLabel, "visible_characters", $RichTextLabel.get_total_character_count(), .0)
	await tween.finished
	typing = false
	$Button.visible = true
	$Button.pressed.connect(_on_next_pressed)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if typing:
			typing = false
			$RichTextLabel.visible_characters = -1
			$Button.visible = true

func _on_next_pressed():
	get_tree().change_scene_to_file("res://cafe_scene.tscn")
