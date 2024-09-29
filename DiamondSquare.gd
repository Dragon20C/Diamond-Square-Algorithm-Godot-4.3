extends Node
class_name DiamondSquare

var height_map_size : int = 3
var height_size : int = 33
var min_height : int = 0
var max_height : int = 15
var roughness : float = 8.0
var height_map : Array[Array]

var start : int = Time.get_ticks_usec()
var end : int = Time.get_ticks_usec()
var worker_time = (end-start)/1000000.0



func generate_height_map() -> void:
	randomize()
	clear_height_map()
	initialise_height_map()
	
	diamond_square()
	
	

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
	roughness = _roughness
	print("Roughness set (%s)" % roughness)

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
	start = Time.get_ticks_usec()
	height_map[0][0] = randi_range(min_height,max_height) 								# Top left
	height_map[height_size - 1][0] = randi_range(min_height,max_height) 				# Top right
	height_map[0][height_size - 1] = randi_range(min_height,max_height) 				# Bottom left
	height_map[height_size - 1][height_size - 1] = randi_range(min_height,max_height) 	# Bottom right
	
	var current_roughness : float = roughness
	var chunk_size : int = height_size - 1
	
	while (chunk_size > 1):
		var half_chunk : int = chunk_size * 0.5
		# Diamond step
		for x in range(0,height_size - 1,chunk_size):
			for y in range(0,height_size - 1,chunk_size):
				var corner_sum : float = (height_map[x][y] +
						height_map[x + chunk_size][y] +
						height_map[x][y + chunk_size] +
						height_map[x + chunk_size][y + chunk_size])
				
				var avg : float = corner_sum / 4.0
				avg += get_roughness_scaler(current_roughness)

				height_map[x + half_chunk][y + half_chunk] = avg
		
		# Square step
		
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
				avg += get_roughness_scaler(current_roughness)
				height_map[x][y] = avg
				
		
		current_roughness = max(current_roughness * 0.5, 0.1)
		chunk_size *= 0.5
	
	end = Time.get_ticks_usec()
	var worker_time = (end-start)/1000000.0
	print("It took (%s) to generate data." % worker_time)
	
func get_roughness_scaler(_current_roughness : float) -> float:
	var roughness_scaled : float = randf_range(-1,1)
	
	roughness_scaled *= _current_roughness
	
	return roughness_scaled
