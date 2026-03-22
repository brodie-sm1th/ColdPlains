extends Node3D

@export var impact : GPUParticles3D
@export var explosion : GPUParticles3D

func _on_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	impact.emitting = true
	explosion.emitting = true
