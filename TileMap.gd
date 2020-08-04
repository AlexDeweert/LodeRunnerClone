extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var timer = false
var destructCells = get_used_cells_by_id(8)

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("../Player1")
	print("TileMap connecting 'player_fired_focus_beam' signal with '_on_Player_fired_focus_beam' handler...")
	var err = player.connect("player_fired_focus_beam", self,"_on_Player_fired_focus_beam")
	if err:
		print(err)
	

#The CELL is the fixed position in a portion of a tileset.
#so for example, if we have a set of cells that belong to a sprite sheet within
#a tileset with an id of 8, and there are 6 cells within that sheet, then there
#exists the ability to set_cell to a specific tile in the same or other sheets.
#func _process(_delta):
#	if timer:
#		for cell in get_used_cells_by_id(8):
#			var tile = get_cell_autotile_coord(cell.x,cell.y)
#			set_cell(cell.x,cell.y,8,false,false,false,Vector2(int(tile.x+1)%7,tile.y))
#	timer = false
				

func _process(_delta):
	pass

#It's also possible to connect this to the world node.
#then we could reference ANY object using the dollar sign operator
#but this also works.

## TODO: Should only be able to destroy tiles if there is space above it,
## that is, the only time we should be able to destroy a tile is if it's VOID
## above it (maybe -1?)
func _on_Player_fired_focus_beam(collisions,direction):
#	for collision in collisions:
		#We should check to make sure the player isn't standing on it
		#somehow
	var collision = collisions[0] if collisions else false
	if collision and collision.collider is TileMap:
		print("fired in direction %s"%direction)
		var player_tile_pos = collision.collider.world_to_map(player.position)
		print("player_tile_pos.x: %s"%player_tile_pos.x)
		var tile_pos = player_tile_pos - collision.normal
		print("tile pos %s"%tile_pos)
		tile_pos.x += -1 if direction == "left" else 1
		
		#tile_idx is an index of a tile given by a vector2, in this case, tile_pos which
		#is the calculated vector2 of the tile under the character to the left or right
		var tile_idx = collision.collider.get_cellv(tile_pos)
		if tile_idx != 8:
			print("can't destroy tile to the %s, it's not a destructable type, it's idx is %s"%[direction, tile_idx])
		else:
			#tile here, is a vector2 assigned the return val of get_cell_autotile_coord
			#according to Docs: Returns the coordinate (subtile column and row)
			#of the autotile variation in the tileset. Returns a zero vector if the cell 
			#doesn't have autotiling.
			var tile = get_cell_autotile_coord(tile_pos.x,tile_pos.y)
			print("destroying a tile with id %s and setting to autotile_coord %s"%[tile_idx,tile])
			
			#1) Set the cell at WORLD position tile_pos.x and y (and we altered this to be left or right
			#of the player based on the fire direction); and
			#2) using tile_idx (which IS the spritesheet index, or the atlas section index); and
			#3) sets it to the value on THAT spritesheet/atlas pointed to by the Vector2 in question.
			#both tile and the Vector2 in question will be sub-coordinates of the spritesheet.
			self.set_cell(tile_pos.x,tile_pos.y, tile_idx, false,false,false,Vector2(int(tile.x+1)%7,tile.y))


func _on_Timer_timeout():
	print("tileMap timer timed out")
	timer = true
