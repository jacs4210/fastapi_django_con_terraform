# Requisitos de Seguridad y escalabilidad

1. Para la escalabilidad, se esta creando un auto scaling group donde se desplegarán de acuerdo a la demanda un conjunto de instancias que van desde minimo 2 hasta maximo 5 por zona de disponibilidad, lo que facilitará que primero garantice la alta disponibilidad al tenerlo en minimo 2 AZ y también la escalabilidad horizontal garantizando que la cantidad de instancias se repliquen si la demanda de consumo de api rest se empieza a incrementar. Dicho escalamiento será de manera automático y que controlará AWS mediante el Auto Scaling Group. 

3. Adicionalmente, como apoyo a la alta disponibilidad, se configuró y es posible desplegar un ALB (Application Load Balancer) el cual permitirá redirigir el trafico entre las instancias ECS que están desplegadas para que no haya petición sin atender.

4. En cuanto a la seguridad, se configuró un Internet Gateway que permitirá filtrar el trafico de entrada y salida con el fin de que los recursos desplegados dentro de la VPC tengan una capa de seguridad adicional. Adicionalmente se realizo lo siguiente:

- Se crea un grupo de seguridad para la VPC, para la base de datos RDS y también para el bastión, con el fin de agregar las politicas de comunicación que se van a realizar entre los diferentes recursos de la arquitectura como lo es la comunicación unica entre las ECS con la RDS y viceversa. También la comunicación que habrá entre el bastión hacia el RDS y viceversa. Como también la comunicación unica entre el ALB y las ECS ya que estas estarán en una subred privada al igual que la base de datos RDS, lo que agrega que unicamente entre ellos se puedan comunicar y nadie mas tenga acceso a estos recursos a menos que sea atraves del ALB o de las ECS en el caso para la RDS. 

- Se configura el acceso por SSH en el Internet Gateway con el fin de que el bastión pueda recibir estas peticiones para acceder mediante un cliente como PgAdmin, entre otros. 

- Se configura tanto el ALB para que todo trafico http lo redirija al trafico https.