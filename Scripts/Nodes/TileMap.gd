extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	for ts in tile_set.get_tiles_ids():
		print(tile_set.tile_get_shapes(0))        # for every textures in tileset.
		if tile_set.tile_get_shapes(ts).is_empty():  # if texture didn't have any collision shapes.
			var shape = ConvexPolygonShape2D.new()
			shape.set_points([Vector2(0, 0), Vector2(64, 0), Vector2(64, 64), Vector2(0, 64)])
			var c = tile_set.tile_get_texture(ts).get_width()  / int(cell_size.x)  # colums
			var r = tile_set.tile_get_texture(ts).get_height() / int(cell_size.y)  # rows
			for i in range(c * r):
				tile_set.tile_add_shape(ts, shape, Transform2D(), false, Vector2(i % c, i / c))
			tile_set.tile_set_shape(ts, ts, shape)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
