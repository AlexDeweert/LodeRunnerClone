extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ClimbAlignment_body_shape_entered(body_id, body, body_shape, area_shape):
	if body is KinematicBody2D:
			body.position.x = get_parent().position.x
