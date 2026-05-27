extends CharacterBody2D

const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100
var target = null
var health: int = 100
var is_alive: bool = true


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Node2D = $HealthBar

func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)


func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attacking")


func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -=damage
	health_bar.update_health(health)
	if health <= 0:
		_die()
	# knockback
	var knockback_direction = (position - attacker_position).normalized()
	var target_position = position + knockback_direction * KNOCKBACK_FORCE
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, 0.5)

func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("dying")
	
	#disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$sight/CollisionShape2D.set_deferred("disabled", true)

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive :
		target = null
		animated_sprite_2d.play("idle")
