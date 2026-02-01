extends CharacterBody2D


var direction: Vector2 #Se crea un vector (0,0)
var speed: int = 700

func _physics_process(_delta: float) -> void:

	#Obtiene información del imput del teclado y lo muestra como vector
	direction = Input.get_vector("left","right","up", "down")
	#position += direction * speed #No toma en cuenta colisiones
	velocity = direction * speed #Correcto para colisiones
	move_and_slide()
		
