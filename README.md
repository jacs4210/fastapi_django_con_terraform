# Desplegar y destruir infraestructura con Terraform

Este documento proporciona las instrucciones para poder crear los entornos de desarrollo y producción como también destruirlos si es necesario.

## Prerrequisitos

1. [Instalar Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Configurar el archivo **dev.tfvars** y **prod.tfvars** ajustandolo a sus necesidades.

## Crear los workspaces para dev y prod
```sh
terraform workspace new dev
terraform workspace new prod
```

## Crear Infraestructura para dev o prod

1. Navega al directorio donde se encuentra tu archivo `main.tf` del entorno que vayas a crear, para dev seria `/prueba_tecnica/environments/dev` y para producción seria `/prueba_tecnica/environments/prod`:

    Ejemplo:

    ```sh
    cd /prueba_tecnica/environments/dev
    ```

2. Inicializa el directorio de trabajo de Terraform:
    ```sh
    terraform init
    ```

3. Revisa el plan de ejecución para asegurarte de que los cambios son los esperados:
    ```sh
    terraform plan
    ```

4. Aplica el plan para crear la infraestructura seleccionando primero el workspace del entorno que vayas a crear, para desarrollo seria `dev` y para producción seria `prod`; adicionalmente, deberás indicar el archivo donde se encuentran las variables a utilizar dentro del plan de terraform, para desarrollo seria `dev.tfvars` y para producción seria `prod.tfvars`:

    Ejemplo:

    ```sh
    terraform workspace select dev
    terraform apply -var-file="dev.tfvars"
    ```
    Es posible que se te pida que confirmes la ejecución escribiendo `yes`.

## Destruir Infraestructura

1. Navega al directorio donde se encuentra tu archivo `main.tf` (si no estás ya en él) de la misma manera que para la creación, teniendo en cuenta el entorno que quieras destruir:
    ```sh
    cd /prueba_tecnica/environments/dev
    ```

2. Revisa el plan de destrucción para asegurarte de que los recursos a eliminar son los correctos:
    ```sh
    terraform plan -destroy
    ```

3. Destruye la infraestructura seleccionando primero el entorno que vas a destruir y finalmente ejecutando la instrucción de destrucción:
    Ejemplo:

    ```sh
    terraform workspace select dev
    terraform destroy
    ```
    Es posible que se te pida que confirmes la ejecución escribiendo `yes`.
