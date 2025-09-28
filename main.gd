extends Node2D

@onready var animationplayer = $Sprite2D3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animationplayer.play("opacity")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
