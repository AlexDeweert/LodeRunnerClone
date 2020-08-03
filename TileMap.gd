extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../Player1").connect("playerCollidedWithTile", self,"_on_Player_collided")

#It's also possible to connect this to the world node.
#then we could reference ANY object using the dollar sign operator
#but this also works.
#
#We could have a signal emission handler that deals with all signals for the
#entire scene.
func _on_Player_collided(collision,direction):
	if collision.collider is TileMap:
		print("fired in direction %s"%direction)
		var player_tile_pos = collision.collider.world_to_map(get_node("../Player1").position)
		var tile_pos = player_tile_pos - collision.normal
		tile_pos.x -= 1
		var tile = collision.collider.get_cellv(tile_pos)
		self.set_cellv(tile_pos, -1)
#		print("player_tile_pos colliosion: %s, tile_pos: %s"%[player_tile_pos,tile_pos])
