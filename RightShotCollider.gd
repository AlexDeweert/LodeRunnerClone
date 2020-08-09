extends CollisionShape2D

var player
var shotCollider
var parent
var fired = false

func _ready():
	print("!!RightShotCollider connecting 'player_fired_focus_beam_right' signal with '_on_Player_fired_focus_beam' handler...")
	player = get_node("../../../Player1")
	parent = get_parent()
	var err = player.connect("player_fired_focus_beam_right", self,"_on_Player_fired_focus_beam")
	if err:
		print(err)
	pass # Replace with function body.

func _on_Player_fired_focus_beam():
	print("this position %s"%global_position)
	var overlapping = parent.get_overlapping_bodies()
	for body in overlapping:
		if body is TileMap:
			var tile_pos = body.world_to_map(global_position)
			body.disintegrateTile(tile_pos)
