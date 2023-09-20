output "container_id" {
  description = "The ID of the created container"
  value       = docker_container.nginx.id
}

output "image_id" {
  description = "The ID of the pulled image"
  value       = docker_image.nginx.id
}