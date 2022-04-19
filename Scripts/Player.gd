extends KinematicBody2D

const GRAVITY = 300.0

export var speed: int = 200

onready var world = get_tree().get_root().get_node('World')

var velocity = Vector2()

puppet var puppet_transform = null

func _ready():
	set_process_input(is_network_master())

func set_player_label(name: String) -> void:
	$NameLabel.set_text(name)
	
func set_message_label(words: String) -> void:
	$MessageLabel.set_text(words)

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	velocity = velocity.normalized() * speed
					
func _physics_process(delta):
	if is_network_master():
		get_input()
		velocity = move_and_slide(velocity, Vector2.UP)
		
		# Change the transform of this node on all peers.
		rset_unreliable('puppet_transform', transform)
	else:
		if puppet_transform != null:
			transform = puppet_transform
