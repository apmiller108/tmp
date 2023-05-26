# TODOs
- [x] Add Devise
- [x] Add Haml gem
- [x] Create an Item resource
- [x] Remove Item resource
- [x] Remove Item controller
- [x] Implement API authentication
- [x] Implement jti jwt_revocation_strategy
- [x] Add request spec for sign in
- [ ] Add request spec for sign out
- [ ] Update request spec for users
- [ ] Add feature spec for users show
- [ ] Make sure registrations works with API
- [ ] Add request specs for registrations via API
- [ ] Add authenticated route behaviour shared examples
- [ ] Add auth helper for request specs
- [ ] Setup CI
- [ ] Create box model
- [ ] Create message model
- [x] Learn about and use view_component library
- [x] Setup Cuprite
- [x] Write a feature test for logging in
- [x] Write a feature test for logging out
- [x] Write a feature test for Signing up
- [x] Add log out link
- [ ] Setup ActionCable
- [ ] Do something with turbo frames
- [ ] Do something with Stimulus
- [ ] Figure out better cors config https://github.com/cyu/rack-cors


# Start

## Docker
For development, one can use docker-compose. This will use `Dockerfile.dev`.
### Build
```
docker-compose build
```
### Run
You can run all services with

```
docker-compose up
```

Or just what you need (ie, without sidekiq and chrome)

```
docker-compose up web database redis
```

### Access to running containers
  - docker-compose exec -it web bash
  - docker-compose exec -it database psql -U postgres

# Application
## Authentication
### Devise
#### Devise and Turbo
At the time of writing this, Devise and turbo streams have some compatability
issues, which can be resolved by disabling turbo in the forms using a HTML data
attribute `data: { turbo: false }`.

There is [an alternative to make turbo work with the devise forms](https://gorails.com/episodes/devise-hotwire-turbo),
but involves some customization to devise that are require more advanced
understanding of devise configuration.
##### Session Cookies
Authentication with session cookies is the Devise default and is used for same origin web requests.

##### JWTs
Endpoints that respond to `json` formats are authenticated with JWT tokens.
(unless the request is same origin, in which case Devise will authenticate using
the session cookie.)

See also [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) docs:

> If the authentication succeeds, a JWT token is dispatched to the client in the Authorization response header, with format Bearer #{token} (tokens are also dispatched on a successful sign up).

###### Revocation Strategy
`jti` (JWT ID). See https://github.com/waiting-for-dev/devise-jwt#revocation-strategies

Sending a `DELETE` to `users/sign_out.json` will revoke the token via the jti.

## Secrets
This application stores encrypted credentials per the [Custom
Credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials)
Rails convention.
### Adding a secret
1. Generate a secret `bundle exec rake secret`
2. Add it to the environment's secrets: `bin/rails credentials:edit --environment development`
NOTE: each environment will have it's own master key

## View Component
  - https://viewcomponent.org/guide/getting-started.html
## CSS Framework
[Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/)

# Testing
## System Tests
- [Cuprite](https://github.com/rubycdp/cuprite "cuprite")
  - See also https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
  - See also https://vtc.hatenablog.com/entry/2022/02/26/175431 (giving cuprite a try using a basic Rack app)
- Docker
  - Uses [browserless' Chrome image](https://www.browserless.io/docs/docker-quickstart)
  - `docker-compose up -d chrome`
  - visit http://localhost:3333/
# Deployments
## Fly.io
- The deployments use the `Dockerfile` and `fly.toml`.
- Use the [flyctl](https://fly.io/docs/hands-on/install-flyctl/) commandline utility to manage deployments and production environment.
- Staging hosted at https://cold-dream-5563.fly.dev/

```shell
flyctl deploy
```

```shell
fly ssh console --pty -C '/bin/bash'
```
### Issues with fly
#### Server won't start since it things there is one already running.
The pid should be dockerignored, but had to do `rm tmp/pids/server.pid` locally and then redeployed.
### I'm cheap and using free stuff...
So everything goes into suspend and need to wake stuff up.

#### Start a machine
```shell
flyctl machine start -a cold-dream-5563-db 17811120c55748
```

#### Restart an application
```shell
flyctl apps restart cold-dream-5563
```
