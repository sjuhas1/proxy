## Nginx helper class to allow for further module configuration.
## For example, TLS certificates generation.
class profiles::nginx() {

  contain ::nginx

}
