case $::domain_role {
  'domain_proxy': {
    contain "::roles::${::domain_role}"
  }
}
