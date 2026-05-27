extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box: Area2D = $AttackBox
@onready var collision_shape_2d: CollisionShape2D = $AttackBox/CollisionShape2D

const SPEED = 300.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var attack_hit_box_offset: Vector2

func _ready() -> void:
	attack_hit_box_offset = attack_box.position

func _physics_process(_delta: float) -> void:
	# disable hitbox until attacking
	attack_box.monitoring = false

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
	if is_attacking:
		velocity = Vector2.ZERO
		return

	process_movement()
	process_animation()
	move_and_slide()

# ----------------------------------
# Movement and animations functions
# ----------------------------------
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left","right","up","down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO

	#process_animation(last_direction)

func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("walking", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

# ----------------------------------
# Attack
# ----------------------------------
func attack() -> void:
	attack_box.monitoring = true
	is_attacking = true
	play_animation("attack", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false


# ----------------------------------
# Hitbox
# ----------------------------------
func update_hitbox_offset()-> void:
	var x:= attack_hit_box_offset.x
	var y:= attack_hit_box_offset.y

	match last_direction:
		Vector2.LEFT:
			attack_box.position = Vector2(-x, y)
		Vector2.RIGHT:
			attack_box.position = Vector2(x, y)
		Vector2.UP:
			attack_box.position = Vector2(y, -x)
		Vector2.DOWN:
			attack_box.position = Vector2(y, x)


func _on_attack_box_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):
		print("hit")
