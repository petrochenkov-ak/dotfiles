variable "TAG"        { default = "latest" }
variable "IMAGE_NAME" { default = "change-me" }

target "local" {
  context   = "."
  platforms = []
  output    = ["type=docker"]
  tags      = ["127.0.0.1:5000/${IMAGE_NAME}:${TAG}"]
}


target "prod" {
  context   = "."
  platforms = ["linux/amd64"]
  output    = ["type=registry"]
  tags      = ["127.0.0.1:5000/${IMAGE_NAME}:${TAG}"]
  dns       = ["8.8.8.8", "1.1.1.1"]
  ssh = ["default"]
}
