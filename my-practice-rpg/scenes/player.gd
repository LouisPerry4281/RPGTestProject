extends CharacterBody2D

const player_base_speed = 100

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_moving = false
var is_attacking = false

enum player_directions {DOWN, LEFT, RIGHT, UP}
@onready var attack_hitboxes = [$HitBoxes/hitbox_down/CollisionPolygon2D, null, null, null] #[Down, Left, Right, Up]
@onready var attack_hitbox_test = $HitBoxes/hitbox_down/CollisionPolygon2D
var last_dir = 'down'
var attack_dir = player_directions.DOWN

func _ready() -> void:
	attack_hitbox_test.disabled = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and !is_attacking:
		_handle_animations('idle', true)
		_player_attack()
	
	_player_movement(delta)

func _player_movement(delta):
	if is_attacking: #If the player is midway through an attack, disable movement
		return
	
	if Input.is_action_pressed("right"):
		velocity = Vector2.RIGHT * player_base_speed * delta
		is_moving = true
		_handle_animations('side', false)
		anim.flip_h = false
		attack_dir = player_directions.RIGHT
	elif Input.is_action_pressed("left"):
		velocity = -Vector2.RIGHT * player_base_speed * delta
		is_moving = true
		_handle_animations('side', false)
		anim.flip_h = true
		attack_dir = player_directions.LEFT
	elif Input.is_action_pressed("up"):
		velocity = Vector2.UP * player_base_speed * delta
		is_moving = true
		_handle_animations('up', false)
		attack_dir = player_directions.UP
	elif Input.is_action_pressed("down"):
		velocity = -Vector2.UP * player_base_speed * delta
		is_moving = true
		_handle_animations('down', false)
		attack_dir = player_directions.DOWN
	else:
		velocity = Vector2.ZERO
		is_moving = false
		_handle_animations('idle', false)
	
	move_and_collide(velocity)

func _handle_animations(dir, is_an_attack):
	var anim_to_play = ''
	
	if is_an_attack:
			is_attacking = true
			anim_to_play = 'attack_' + last_dir
			anim.play(anim_to_play)
			return
	
	if is_moving:
		anim_to_play = 'run_' + dir
		anim.play(anim_to_play)
		last_dir = dir
	else:
		anim_to_play = 'idle_' + last_dir
		anim.play(anim_to_play)

func _player_attack():
	attack_hitbox_test.disabled = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		attack_hitbox_test.disabled = true #Change to iterate through each box
