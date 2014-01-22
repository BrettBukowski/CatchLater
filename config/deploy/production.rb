set :stage, :production
server 'perro', roles: %w{web app db}
set :ssh_options, {
  user: 'brett',
  keys: %w(/Users/brettbukowski/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey password),
}
