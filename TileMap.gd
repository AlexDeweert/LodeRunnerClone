extends TileMap

#TODO: Tile below destroyed tiles don't disintegrate anymore
#Need to fix that, maybe set the value to -1 again.

func disintegrateTile(tile_pos):
	print("collision with tile at %s"%tile_pos)
	
	var tile_above_pos = tile_pos
	tile_above_pos.y -= 1
	var tile_above_idx = get_cellv(tile_above_pos)
	print("tile_above_idx == %s"%tile_above_idx)
	#tile_idx is an index of a tile given by a vector2, in this case, tile_pos which
	#is the calculated vector2 of the tile under the character to the left or right
	var tile_idx = get_cellv(tile_pos)
	if tile_idx != 8 :
		print("can't destroy tile, it's not a destructable type, it's idx is %s"%[tile_idx])
	elif tile_above_idx != -1:
		print("can't destroy tile: the tile ABOVE it needs to be empty, which it is not. It's type %s"%tile_above_idx)
	else:
		#tile here, is a vector2 assigned the return val of get_cell_autotile_coord
		#according to Docs: Returns the coordinate (subtile column and row)
		#of the autotile variation in the tileset. Returns a zero vector if the cell 
		#doesn't have autotiling.
		var tile = get_cell_autotile_coord(tile_pos.x,tile_pos.y)
		
		#This checks to make sure that the tile is already at the beginning state, ie it
		#HAS NOT been blasted out.
		if tile.x == 0 and tile.y == 0:
			print("destroying a tile with id %s and setting to autotile_coord %s"%[tile_idx,tile])
			#1) Set the cell at WORLD position tile_pos.x and y (and we altered this to be left or right
			#of the player based on the fire direction); and
			#2) using tile_idx (which IS the spritesheet index, or the atlas section index); and
			#3) sets it to the value on THAT spritesheet/atlas pointed to by the Vector2 in question.
			#both tile and the Vector2 in question will be sub-coordinates of the spritesheet.
			#can DESTROY a tile with set_cell(tile_pos.x,tile_pos.y, -1)
			var t = Timer.new()
			self.add_child(t)
			t.set_one_shot(true)
			t.set_wait_time(0.05)
			
			print("tile autocell coordinate PRIOR to blast out %s"%get_cell_autotile_coord(tile_pos.x,tile_pos.y))
			
			#Dig out the tile since it was blasted
			for i in range(0,6):
				t.start()
				yield(t, "timeout")
				tile = get_cell_autotile_coord(tile_pos.x,tile_pos.y)
				set_cell(tile_pos.x,tile_pos.y, tile_idx, false,false,false,Vector2(tile.x+1,tile.y))
			
			set_cell(tile_pos.x,tile_pos.y, -1)
			#Delay until it fills back in abruptly
			t.set_wait_time(5.0)
			t.start()
			yield(t, "timeout")
			
			#REFILL the tile
			t.set_wait_time(0.05)
			print("fill in. trying to set killZone position to tile_pos %s"%map_to_world(tile_pos,true))
			
			
			
			var killZone = get_node("../KillZone")
			killZone.position = map_to_world(tile_pos,true)
			#Need to reset it from -1
			set_cell(tile_pos.x,tile_pos.y, tile_idx, false,false,false,Vector2(tile.x,tile.y))
			
			#Fill hole back up
			for i in range(0,5):
				t.start()
				yield(t, "timeout")
				tile = get_cell_autotile_coord(tile_pos.x,tile_pos.y)
				set_cell(tile_pos.x,tile_pos.y, tile_idx, false,false,false,Vector2(tile.x-1,tile.y))
			killZone.position = Vector2.ZERO
		else:
			print("can't blast out a previously blasted out tile...bitch")
