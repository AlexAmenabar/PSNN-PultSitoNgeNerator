extends GraphNode

# LIF neuron parameters
var v # membrane potential
var v_thres # threshold
var v_rest # resting membrane potential
var R # neuron resistance
var refract_t # refractary period
var behaviour # neuron behaviour, excitatory or inhibitory
var is_input = 0 # if the neuron is an input neuron
var is_output = 0 # if the neuron is an output neuron
#var n_input_synap = 0 # number of neuron input synapses
#var n_output_synap = 0 # number of neuron output synapses

var synapse_node # node with synapses 
var input_synapse_neurons = [] # list of input neuron identifiers
var output_synapse_neurons = [] # list of output neuron identifiers

var input_synapse_nodes = []
var output_synapse_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	v = 0
	v_thres = 150
	v_rest = 0
	R = 10
	refract_t = 2
	behaviour = 1 # excitatory
	is_input = 0
	is_output = 0
	#n_input_synap = 0
	#n_output_synap = 0

	synapse_node = get_node("Synapses")
	
	print_values()

func update_values(p_v, p_vt, p_v_rest, p_R, p_reftact, p_behaviour, p_is_in, p_is_out):
	v = p_v
	v_thres = p_vt
	v_rest = p_v_rest
	R = p_R
	refract_t = p_reftact
	behaviour = p_behaviour
	is_input = p_is_in
	is_output = p_is_out
	#n_input_synap = p_in_synap
	#n_output_synap = p_out_synap
	print_values()
	

func print_values():
	get_node("V/TextEdit").text = str(v)
	get_node("Threshold/TextEdit").text = str(v_thres)
	get_node("V rest/TextEdit").text = str(v_rest)
	get_node("R/TextEdit").text = str(R)
	get_node("Refractary time/TextEdit").text = str(refract_t)
	get_node("Behaviour/TextEdit").text = str(behaviour)
	get_node("Is in/TextEdit").text = str(is_input)
	get_node("Is out/TextEdit").text = str(is_output)
	#get_node("Input Synpases/TextEdit").text = str(n_input_synap)
	#get_node("Output Synpases/TextEdit").text = str(n_output_synap)
	
func load_values():
	v = float(get_node("V/TextEdit").text)
	v_thres = float(get_node("Threshold/TextEdit").text)
	v_rest = float(get_node("V rest/TextEdit").text)
	R = int(get_node("R/TextEdit").text)
	refract_t = int(get_node("Refractary time/TextEdit").text)
	behaviour = int(get_node("Behaviour/TextEdit").text)
	is_input = int(get_node("Is in/TextEdit").text)
	is_output = int(get_node("Is out/TextEdit").text)
	#n_input_synap = int(get_node("Input Synpases/TextEdit").text)
	#n_output_synap = int(get_node("Output Synpases/TextEdit").text)

func hide_neuron():
	get_node("V").visible = false
	get_node("Threshold").visible = false
	get_node("V rest").visible = false
	get_node("R").visible = false
	get_node("Refractary time").visible = false
	get_node("Behaviour").visible = false
	get_node("Is in").visible = false
	get_node("Is out").visible = false
	#get_node("Input Synpases").visible = false
	#get_node("Output Synpases").visible = false
	
	get_node("Show").visible = true
	get_node("Colapse").visible = false
	size = Vector2(size.x, 1)

func show_neuron():
	get_node("V").visible = true
	get_node("Threshold").visible = true
	get_node("V rest").visible = true
	get_node("R").visible = true
	get_node("Refractary time").visible = true
	get_node("Behaviour").visible = true
	get_node("Is in").visible = true
	get_node("Is out").visible = true
	#get_node("Input Synpases").visible = true
	#get_node("Output Synpases").visible = true
	
	get_node("Show").visible = false
	get_node("Colapse").visible = true



func _on_colapse_pressed():
	hide_neuron()


func _on_show_pressed():
	show_neuron()
	
func add_input_synapse(synapse):
	input_synapse_nodes.append(synapse)

func add_output_synapse(synapse):
	output_synapse_nodes.append(synapse)
