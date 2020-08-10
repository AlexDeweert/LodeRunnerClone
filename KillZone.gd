extends Area2D

#TODO: In the future it might not be enough to rapidly move this kill
#zone around to any KinematicBody2D that touches it. There could be some
#kind of race condition where the player, or two enemies fall into holes
#at exactly the same time and this KillZone position is moved to one or the
#other and one of the bodies doesn't register the collision, and therefore
#the signal to queue_free the intersecting body doesn't occur.

#One possible solution is to spawn a NEW killZone instance every time, then 
#free it too after the KinematicBody2D in question is freed itself.

#But this should be tested

func _ready():
	pass # Replace with function body.

func _on_KillZone_body_shape_entered(body_id, body, body_shape, area_shape):
	if body is KinematicBody2D:
		body.queue_free()
		print("a kinematic body2d entered the killzone: %s"%body.name)


func _on_KillZone_body_shape_exited(body_id, body, body_shape, area_shape):
	if body is KinematicBody2D:
		print("a kinematic body2d EXITED life: %s"%body.name)
