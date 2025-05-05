extends Node2D

@onready var label = $Label

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -20), 1.0) 
	tween.tween_property(self, "modulate:a", 0, 1.0) 
	await tween.finished
	queue_free()  

func set_damage(amount: int, color: Color = Color.RED):
	$Label.text = str(amount)
	$Label.add_theme_color_override("font_color", color)
