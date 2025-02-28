@tool
extends MeshInstance3D

@export var chunk_pos = Vector2(0,0)
@export var chunk_size := 0
@export var chunk_resolution := 0

@onready var g_chunk_area: Area3D = $gChunkArea
@onready var g_chunk_volume: CollisionShape3D = $gChunkArea/gChunkVolume
@onready var g_chunk_coll_shape: CollisionShape3D = $gChunkStaticBody/gChunkCollShape

var heightmap: Image
var noise : FastNoiseLite
var offset
var noise_offset := Vector3(0,0,0)

@export var chunk_height : float = 0.0 :
	set(new_height):
		chunk_height = new_height
		set_instance_shader_parameter("height", float(chunk_height))

func _ready() -> void:
	offset = chunk_size*chunk_pos
	noise = noise.duplicate()
	global_position.x = (chunk_pos.x * chunk_size)
	global_position.z = (chunk_pos.y * chunk_size)
	
	generate_collision()
	pass

func generate_area() -> void:
	g_chunk_volume.shape = BoxShape3D.new()
	if g_chunk_volume:
		g_chunk_volume.shape.size = Vector3(chunk_size, chunk_height * 1.5, chunk_size)

func _on_chunk_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	# This could become a signal
	if body.is_in_group("actor"):
		get_parent().current_chunk_changed(chunk_pos)

func _on_chunk_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	#if body.is_in_group("actor"):
		#get_parent().current_chunk_changed(chunk_pos)
	pass
	
func generate_collision():
	var plane = PlaneMesh.new()
	
	plane.size = Vector2(chunk_size,chunk_size)
	plane.subdivide_depth = chunk_resolution - 1
	plane.subdivide_width = chunk_resolution - 1
	
	var faces = plane.get_faces()
	
	var max : float = 0
	for i in faces.size():
		var height = 0.0
		var global_vert = faces[i] + Vector3(offset.x,0,offset.y) + noise_offset

		height = noise.get_noise_2d(global_vert.z, global_vert.x)
		faces[i].y = height * -chunk_height
		
		if height > max:
			max = height

	print(max)
	g_chunk_coll_shape.shape = ConcavePolygonShape3D.new()
	g_chunk_coll_shape.shape.set_faces(faces)
	
func generate(noise = null):
	set_instance_shader_parameter("height", float(chunk_height))
	
	var plane := PlaneMesh.new()
	plane.subdivide_depth = chunk_resolution - 1
	plane.subdivide_width = chunk_resolution - 1
	plane.size = Vector2(chunk_size, chunk_size)
	
	mesh = plane
