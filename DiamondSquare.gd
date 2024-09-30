extends Node
class_name DiamondSquare

var height_map_size : int = 3
var height_size : int = 33
var min_height : int = 0
var max_height : int = 15
var initial_roughness : float = 8.0
var height_map : Array[Array]


func generate_height_map() -> void:
	print("Generating Height map")
	clear_height_map()
	initialise_height_map()
	
	await diamond_square()

func set_size(size : int) -> void:
	if size % 2 == 0:
		print("Size set (%s)" % size)
		height_size = size + 1
	else:
		push_error("Size isn`t even, falling back to 32")
		height_size = 32 + 1

func set_height(_min_height : int, _max_height : int) -> void:
	print("Height set min (%s), max (%s)" % [_min_height,_max_height])
	min_height = _min_height
	max_height = _max_height
	
func set_roughness(_roughness : float) -> void:
	initial_roughness = _roughness
	print("Roughness set (%s)" % initial_roughness)

func get_height_map() -> Array[Array]:
	return height_map

func initialise_height_map() -> void:
	#height_size = pow(2,height_map_size) + 1
	if height_size <= 0:
		push_error("Failed to initialise height map because size is not set")
		return
	
	height_map.resize(height_size)
	for x in range(height_size):
		var temp_array : Array[float] = []
		temp_array.resize(height_size)
		height_map[x] = temp_array

func clear_height_map() -> void:
	height_map.clear()

func diamond_square() -> void:
	height_map[0][0] = randi_range(min_height,max_height) 								# Top left
	height_map[height_size - 1][0] = randi_range(min_height,max_height) 				# Top right
	height_map[0][height_size - 1] = randi_range(min_height,max_height) 				# Bottom left
	height_map[height_size - 1][height_size - 1] = randi_range(min_height,max_height) 	# Bottom right
	
	
	var chunk_size : int = height_size - 1
	var roughness : float = initial_roughness
	
	while chunk_size > 1:
		calculate_square(chunk_size,roughness)
		calculate_diamond(chunk_size,roughness)
		
		chunk_size *= 0.5
		roughness = maxf(roughness * 0.5,0.1)

func calculate_diamond(chunk_size : int, roughness : float) -> void:
	
	var half_chunk : int = chunk_size * 0.5
	
	for x in range(0, height_size, half_chunk):
		for y in range((x + half_chunk) % chunk_size,height_size,chunk_size):
			var sum : float = 0.0
			var count : int = 0
			if x >= half_chunk:
				sum += height_map[x - half_chunk][y]
				count += 1
			if x + half_chunk < height_size:
				sum += height_map[x + half_chunk][y]
				count += 1
			if y >= half_chunk:
				sum += height_map[x][y - half_chunk]
				count += 1
			if y + half_chunk < height_size:
				sum += height_map[x][y + half_chunk]
				count += 1
				
			var avg : float = sum / count
			avg += get_roughness_scaler(roughness)
			height_map[x][y] = avg
	
func calculate_square(chunk_size : int, roughness : float) -> void:
	for y in range(0,height_size - 1,chunk_size):
			for x in range(0,height_size - 1,chunk_size):
				
				var top_left : float = height_map[x][y]
				var top_right : float = height_map[x + chunk_size][y]
				var bottom_left : float = height_map[x][y + chunk_size]
				var bottom_right : float = height_map[x + chunk_size][y + chunk_size]
				
				var avg : float = top_left + top_right + bottom_left + bottom_right
				avg = avg / 4
				avg += get_roughness_scaler(roughness)
				
				height_map[x + chunk_size / 2][y + chunk_size / 2] = avg


func get_roughness_scaler(_current_roughness : float) -> float:
	var roughness_scaled : float = randf_range(-1,1)
	
	roughness_scaled *= _current_roughness
	
	return roughness_scaled
