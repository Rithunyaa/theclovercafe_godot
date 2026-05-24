extends AnimatedSprite2D

var speed = Vector2()

func _ready():
	play("default")
	speed = Vector2(randf_range(15, 30), randf_range(25, 45))
	position = Vector2(randf_range(0, 1280), randf_range(-200, 0))

func _process(delta):
	position += speed * delta
	if position.y > 800:
		position = Vector2(randf_range(0, 1280), -50)
		speed = Vector2(randf_range(15, 30), randf_range(25, 45))
