extends Node

# Synapse parameters
var weight = 0 # synapse weight
var delay = 1 # synapse delay
var learning_rule = 0 # synapse learning rule
var is_input = 0
var is_output = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	weight = 0
	delay = 1
	learning_rule = 0
	is_input = 0
	is_output = 0

# Updates synapse values
func update_values(p_weight, p_delay, p_learning_rule, p_is_input, p_is_output):
	weight = p_weight
	delay = p_delay
	learning_rule = p_learning_rule
	is_input = p_is_input
	is_output = p_is_output
	print_values()

# Print synapse values in screen
func print_values():
	get_node("VBoxContainer/W/TextEdit").text = str(weight)
	get_node("VBoxContainer/Delay/TextEdit").text = str(delay)
	get_node("VBoxContainer/Learning Rule/TextEdit").text = str(learning_rule)

# Loads values of text fields from screen to memory
func load_values():
	weight = float(get_node("VBoxContainer/W/TextEdit").text)
	delay = int(get_node("VBoxContainer/Delay/TextEdit").text)
	learning_rule = int(get_node("VBoxContainer/Learning Rule/TextEdit").text)

func show_synapse():
	get_node(".").visible=true
	
func hide_synapse():
	get_node(".").visible=false
