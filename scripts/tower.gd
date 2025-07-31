@tool
extends Node3D

@export var range: float = 20.0:
	set(value):
		range = value
		_update_range_preview()

@export var fire_rate: float = 1.0:
	set(value):
		fire_rate = value
		if is_inside_tree() and not Engine.is_editor_hint():
			$FireTimer.wait_time = fire_rate

@export var projectile_scene: PackedScene

var enemies_in_range: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		_update_range_preview()
		return

	# Runtime logic
	if $Area3D/CollisionShape3D.shape is SphereShape3D:
		$Area3D/CollisionShape3D.shape.radius = range

	$RangePreview.scale = Vector3.ONE * range
	$FireTimer.wait_time = fire_rate
	$FireTimer.start()

	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _update_range_preview() -> void:
	if not is_inside_tree():
		return
	if $RangePreview:
		$RangePreview.scale = Vector3.ONE * range
	if $Area3D/CollisionShape3D.shape is SphereShape3D:
		$Area3D/CollisionShape3D.shape.radius = range

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_body_exited(body: Node) -> void:
	enemies_in_range.erase(body)

func _on_FireTimer_timeout() -> void:
	if enemies_in_range.is_empty():
		return
	var target = enemies_in_range[0]
	if not is_instance_valid(target):
		enemies_in_range.remove_at(0)
		return
	fire_at(target)

func fire_at(target: Node3D) -> void:
	if projectile_scene == null:
		return
	var projectile = projectile_scene.instantiate()
	projectile.global_transform.origin = $Marker3D.global_transform.origin
	projectile.look_at(target.global_transform.origin)
	projectile.target = target
	get_tree().current_scene.add_child(projectile)
