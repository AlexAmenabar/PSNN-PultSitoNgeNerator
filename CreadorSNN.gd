extends Control

# graphEdit node
var graph_edit

# Base neuron and synapse to copy from
var base_neuron
var synapse_example

# node to store selected neuron or synapse
var selected_node = null

# lists of neurons and synapses
var neurons
var synapses

# Number of neurons, input neurons and output neurons
var n_neurons = 0
var n_input_neurons = 0
var n_output_neurons = 0

# Number of synapses, input synapses and output synapses
var n_synapses = 0
var n_input_synapses = 0
var n_output_synapses = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Find GraphEdit node, neuron node and synapse node
	graph_edit = get_node("GraphEdit")
	base_neuron = get_node("BaseNeuron")
	synapse_example = get_node("SynapseExample")
	
	# Initialize lists of neurons and synapses
	neurons = []
	synapses = []


# This function is executed when an input event is detected
func _on_graph_edit_gui_input(event):
	if event.get_class() == "InputEventMouseButton":
		# left click
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
			
		# right click
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Generate a new neurons copying the base neuron
			var node_instance = base_neuron.duplicate()
			node_instance.name = "neuron" + str(n_neurons) # change neuron name
			n_neurons += 1
			
			# move neuron node to mouse pointer position
			node_instance.position_offset = get_viewport().get_mouse_position()
			node_instance.title = node_instance.name # change graphNode title (readability)
			graph_edit.add_child(node_instance) # add child to graphEdit
			
			neurons.append(node_instance) # add neuron to neurons list

# Executed when Update button is pressed, it updates values of neurons and synapses
func _on_refresh_button_pressed():
	print("Updating network data...")
	
	# Update neuron values
	for neuron in neurons:
		neuron.load_values() # load values on text fields into neurons
	
	# Update synapse values
	for synapse in synapses:
		synapse.load_values() # load values on text fields into synapses
	print("Data updated!")

# TODO: change only selected node 
func _on_update_selection_button_pressed():
	pass
	#graph_edit.se

# Propagate values of selected neuron or synapse to the rest of neurons or synapses
func _on_propagate_button_pressed():
	# If there is no neuron or synapse selected finish
	if selected_node == null or selected_node == "Nil":
		return 0
	
	# Update values of selected neuron or synapse
	selected_node.load_values()
	
	# Check if the selected node is a neuron
	if selected_node.name.contains("neuron"):
		print("Propagating selected neuron values to all neurons")
		for neuron in neurons:
			neuron.update_values(selected_node.v, selected_node.v_tresh, selected_node.R, selected_node.refract_t, 
						selected_node.behaviour, selected_node.is_input, selected_node.is_output)#, selected_node.n_input_synap, selected_node.n_output_synap)
		
	# Check if the selected node is a synapse
	elif selected_node.name.contains("synapse"):
		print("Propagating selected synapse values to all synapses")
		for synapse in synapses:
			synapse.update_values(selected_node.weight, selected_node.delay, selected_node.learning_rule)


# Add synaptic connection between neurons
func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	# connect nodes into graphEdit node
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	
	# Get neuron nodes
	var from_neuron = get_node("GraphEdit/" + str(from_node))
	var to_neuron = get_node("GraphEdit/" + str(to_node))
	
	# add connection information to neurons
	from_neuron.output_synapse_neurons.append(int(to_neuron.name.split("ron")[1]))
	to_neuron.input_synapse_neurons.append(int(from_neuron.name.split("ron")[1]))
	
	# Get position in the middle of those neuron to locate the synapse
	var synapse_position = Vector2(0, 0)
	var bigger_x = max(from_neuron.position_offset.x, to_neuron.position_offset.x)
	var smaller_x = min(from_neuron.position_offset.x, to_neuron.position_offset.x)
	
	var bigger_y = max(from_neuron.position_offset.y, to_neuron.position_offset.y)
	var smaller_y = min(from_neuron.position_offset.y, to_neuron.position_offset.y)
	
	var diff = Vector2((bigger_x - smaller_x) / 2, (bigger_y - smaller_y) / 2)
	synapse_position = Vector2(smaller_x + diff.x, smaller_y + diff.y)
	
	# Duplicate synapse node to locate in the screen
	var synapse = synapse_example.duplicate()
	synapse.name = "synapse" + str(n_synapses) # change synapse name
	synapse.title = synapse.name # change graph node title
	get_node("GraphEdit").add_child(synapse) # add synapse to graphEdit
	
	# change synapse position
	synapse.position = synapse_position
	synapse.position_offset = synapse_position
	n_synapses += 1

	# add synapse to synapse list
	synapses.append(synapse)

# Change selected node: event
func _on_graph_edit_node_selected(node):
	selected_node = node

# Export network to TOML file
func _on_export_button_pressed():	
	print("Exporting network...")
	
	var toml_text := ""
	
	# Start with general section of TOML file
	toml_text += "[general]\n"
	# count input and output neurons
	for neuron in neurons:
		n_input_neurons += neuron.is_input
		n_output_neurons += neuron.is_output
	
	# add number of neurons, and how many of them are input and output neurons
	toml_text += "	neurons = " + str(len(neurons)) + "\n"
	toml_text += "	input_neurons = " + str(n_input_neurons) + "\n" 
	toml_text += "	output_neurons = " + str(n_output_neurons) + "\n" 
	
	# same for synapses (THIS MUST BE CHANGE IN THE FUTURE AS IT USES NEURONS INFORMATION AND IS NOT CORRECT)
	toml_text += "	synapsis = " + str(len(synapses) + n_input_neurons + n_output_neurons) + "\n" 
	toml_text += "	input_synapsis = " + str(n_input_neurons) + "\n" # this must be changed in the future, no n_neurons
	toml_text += "	output_sinapsis = " + str(n_output_neurons) + "\n\n" # this must be changed in the future

	# Neurons section
	toml_text += "[neurons]\n"
	
	var behaviour
	var behaviour_list = []
	var all_equals_behaviour = 1
	
	var threshold
	var thres_list = []
	var all_equals_thres = 1
	
	var refractary_time
	var refract_list = []
	var all_equals_refract = 1
	
	# load lists of neurons variables and if all are equals story only one number, else all the list
	for neuron in neurons:
		behaviour_list.append(neuron.behaviour)
		thres_list.append(neuron.v_thres)
		refract_list.append(neuron.refract_t)
		
		for behav in behaviour_list:
			if behav != neuron.behaviour:
				all_equals_behaviour = 0
		
		for thres in thres_list:
			if thres != neuron.v_thres:
				all_equals_thres = 0

		for refract in refract_list:
			if refract != neuron.refract_t:
				all_equals_refract = 0
			
	behaviour = behaviour_list[0]
	if all_equals_behaviour == 0:
		behaviour = -1

	threshold = thres_list[0]
	if all_equals_thres == 0:
		threshold = -1
	
	# if all behaviours all equals 0 or 1, else list
	refractary_time = refract_list[0]
	if all_equals_refract == 0:
		refractary_time = -1
	
	# write information into TOML file
	toml_text += "	behaviour = " + str(behaviour) + "\n"
	toml_text += "	behaviour_list = " + str(behaviour_list) + "\n"
	
	toml_text += "	v_thres = " + str(threshold) + "\n"
	toml_text += "	v_thres_list = " + str(thres_list) + "\n"
	
	toml_text += "	t_refract = " + str(refractary_time) + "\n"
	toml_text += "	t_refract_list = " + str(refract_list) + "\n"
	
	# count input and output synapses per each neuron
	var input_synapses_per_neuron = []
	var output_synapses_per_neuron = []
	for neuron in neurons:
		n_input_synapses = len(neuron.input_synapse_neurons)
		n_output_synapses = len(neuron.output_synapse_neurons)
		
		# Yo las sinapsis de entrada y de salida las cuento
		if neuron.is_input == 1:
			n_input_synapses += 1 # CHANGE IN THE FUTURE
		
		if neuron.is_output == 1:
			n_output_synapses += 1
			
		input_synapses_per_neuron.append(n_input_synapses)#neuron.n_input_synap)
		output_synapses_per_neuron.append(n_output_synapses)#neuron.n_output_synap)

	# Write information into file
	toml_text += "	input_synapsis = " + str(input_synapses_per_neuron) + "\n"
	toml_text += "	output_synapsis = " + str(output_synapses_per_neuron) + "\n\n"

	# Synapses section
	toml_text += "[synapsis]\n"

	var weight_list = []
	
	var latency
	var latency_list = []
	
	var training_zone
	var training_zone_list = []
	
	var all_equals_latency = 1
	var all_equals_tz = 1
	
	for synapse in synapses:
		latency_list.append(synapse.delay)
		weight_list.append(synapse.weight)
		training_zone_list.append(synapse.learning_rule)
		
		for lat in latency_list:
			if lat != synapse.delay:
				all_equals_latency = 0
		
		for lr in training_zone_list:
			if lr != synapse.learning_rule:
				all_equals_tz = 0

	latency = latency_list[0]
	if all_equals_latency == 0:
		latency = -1
	
	training_zone = training_zone_list[0]
	if all_equals_tz == 0:
		training_zone = -1

	# Write information into file
	toml_text += "	latency = " + str(latency) + "\n"
	toml_text += "	latency_list = " + str(latency_list) + "\n"
	toml_text += "	weights = " + str(weight_list) + "\n"
	toml_text += "	training_zones = " + str(training_zone) + "\n"
	toml_text += "	training_zones_list = " + str(training_zone_list) + "\n"
	
	# Synaptic connections
	var connections = [] # list of lists
	var layer_connections = [] # list for layer
	
	# get input layer
	layer_connections.append(0) # change then, amount of neurons for that layer
	var count_neurons = 0
	
	# add input layer
	for neuron in neurons:
		if neuron.is_input == 1:
			var neuron_id = int(neuron.name.split("ron")[1])
			layer_connections.append(neuron_id)
			layer_connections.append(1) # CHANGE IN THE FUTURE
			count_neurons += 1
	
	# change number of neuron in input layer and add to connection list
	layer_connections[0] = count_neurons
	connections.append(layer_connections.duplicate())
	
	# Compute the rest of neurons
	for neuron in neurons:
		# initialize data
		layer_connections.clear()
		layer_connections.append(0)
		count_neurons = 0
		
		# compute layer for each neuron
		for neur in neurons: # I SHOULD TO THIS IN ORDER TO AVOID PROBLEMS?
			var neuron_id = int(neur.name.split("ron")[1])
			# count how much times appears the neuron identifier in the list of neuron
			var times = neuron.output_synapse_neurons.count(neuron_id)
			
			# if it appears more than once, add to list
			if times > 0:
				layer_connections.append(int(neuron_id)) # neuron id
				layer_connections.append(times) # amount of synaptic connections to that neuron
				count_neurons += 1
		
		# Manage (gestion) output synapses too
		if neuron.is_output:
			layer_connections.append(-1)
			layer_connections.append(1) # For now
			count_neurons += 1
		
		# If there is at least one neuron, add to the list
		if count_neurons > 0:
			layer_connections[0] = count_neurons
			connections.append(layer_connections.duplicate())
	
	# Add list of connections to TOML file
	toml_text += "	connections = " + str(connections) + "\n"

	var file := FileAccess.open("res://datos.toml", FileAccess.WRITE)
	file.store_string(toml_text)
	file.close()
	
	print("Network correctly exported!")
