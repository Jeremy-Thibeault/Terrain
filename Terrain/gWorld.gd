@tool
extends Node

const gChunk = preload("res://Terrain/gChunk.tscn")

@export_group("World Geo")
@export var size := 64.0

# Freq 0.0064

## Number of tiles to draw per direction.
## Like a radius, but square.
@export_range(1,10,1) var draw_distance := 4:
	set(new_draw_distance):
		draw_distance = new_draw_distance
		if Engine.is_editor_hint():
			make_world()

@export_range(2, 16, 2) var resolution : int = 4:
	set(new_resolution):
		resolution = snappedi(new_resolution,2)
		if Engine.is_editor_hint():
			make_world()

@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		if noise:
			noise.changed.connect(make_world)


@export var chunk_noise_offset: Vector3:
	set(new_chunk_noise_offset):
		chunk_noise_offset = new_chunk_noise_offset
		if chunk_noise_offset:
			make_world()
			

@export_range(4.0, 128.0, 0.5) var height : float = 64.0:
	set(new_height):
		height = new_height
		if Engine.is_editor_hint():
			make_world()
		
@export var new_seed := false:
	set(new):
		if new:
			noise.seed = randi_range(0,90000)
			print("New Seed: ", noise.seed)
			new_seed = false

@export var generate := false:
	set(new_generate):
		if new_generate:
			make_world()
			generate = false

var current_tile := Vector2(0,0)
var generated_tiles : PackedVector2Array
var loaded_tiles : PackedVector2Array

func make_world() -> void:
	loaded_tiles.clear()
	for child in get_children():
		unload_tile(child)

	for x in range(-draw_distance, draw_distance+1):
		for z in range(-draw_distance, draw_distance+1):
			load_tile(Vector2(x,z))

func current_chunk_changed(new_tile) -> void:
	var direction = new_tile - current_tile
	if direction == Vector2.ZERO:
		return

	current_tile = new_tile

	# Create the arrays of tiles we need to add and remove
	var wanted_tiles : PackedVector2Array
	var unwanted_tiles : PackedVector2Array

	for pos in loaded_tiles:
		if pos+direction not in loaded_tiles:
			wanted_tiles.append(pos+direction)
		if pos-direction not in loaded_tiles:
			unwanted_tiles.append(pos)

	for pos in wanted_tiles:
		load_tile(pos)

	var to_unload : Array
	
	for pos in unwanted_tiles:
		var ind = loaded_tiles.find(pos)
		if ind != -1:
			loaded_tiles.remove_at(ind)
			for child in get_children():
				if child.is_in_group("tile"):
					if child.chunk_pos == pos:
						to_unload.append(child)
						break

	for node in to_unload:
		unload_tile(node)

func generate_tile(pos: Vector2):
	var tile = gChunk.instantiate()

	tile.chunk_pos = pos
	tile.chunk_size = size
	tile.chunk_height = height	
	tile.chunk_resolution = resolution
	tile.noise_offset = chunk_noise_offset
	tile.noise = noise

	tile.generate()
	add_child(tile)
	
	generated_tiles.append(pos)
	loaded_tiles.append(pos)
	
	if not Engine.is_editor_hint():
		#tile.generate_collision(noise)
		tile.generate_area()


func load_tile(pos: Vector2):
	# Check if the tile exists in save data
	# If it does, load it, else, generate it
	generate_tile(pos)
	pass

func unload_tile(node):
	# Check if the tile has been saved before
	# Create the save or increment it
	remove_child(node)
	node.queue_free()

	
func _ready() -> void:
	printt("WORLD SEED: ", noise.seed)
	make_world()
