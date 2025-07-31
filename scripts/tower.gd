extends Node3D


@export var range: float = 5.0
@export var fire_rate: float = 1.0
@export var projectile_scene: PackedScene

var enemies_in_range = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.radius = range
	$FireTimer.wait_time = fire_rate
	$FireTimer.start()
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)
	
func _on_body_exited(body):
	enemies_in_range.erase(body)
	
func _on_FireTimer_timeout():
	if enemies_in_range.size() == 0:
		print("No Enemies in Range")
		return
	#Pick first enemy in range.
	var target = enemies_in_range[0]
	if not is_instance_valid(target):
		print("No valid targets")
		enemies_in_range.remove_at(0)
		return
	#FIRE AT
	
func fire_at(target: Enemy) -> void:
	if projectile_scene == null:
		print("No Projectile Scene")
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_transform.origin = $Marker3D.global_transform.origin
	projectile.look_at(target.global_transform.origin)
	projectile.target = target
	get_tree().current_scene.add_child(projectile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
