# TODOs
- [x] Add Devise
- [x] Add Haml gem
- [x] Create an Item resource
- [x] Remove Item resource
- [x] Remove Item controller
- [x] Implement API authentication
- [x] Implement jti jwt_revocation_strategy
- [x] Add request spec for sign in
- [x] Add request spec for sign out
- [x] Update request spec for users
- [x] Create message model
- [x] Learn about and use view_component library
- [x] Setup Cuprite
- [x] Write a feature test for logging in
- [x] Write a feature test for logging out
- [x] Write a feature test for Signing up
- [x] Add unit tests for message view components
- [ ] Add a header to the layout
- [ ] Add user message destroy action
- [ ] Add request specs for user messages
- [ ] Add feature specs for user messages
- [ ] Make sure registrations works with API
- [ ] Add request specs for registrations via API
- [ ] Add authenticated route behaviour shared examples
- [ ] Add auth helper for request specs
- [ ] Setup CI
- [ ] Add feature spec for users show
- [x] Add log out link
- [ ] Setup ActionCable
- [x] Do something with turbo frames
- [ ] Do something with Stimulus
- [ ] Figure out better cors config https://github.com/cyu/rack-cors


# Start

## Docker
For development, one can use docker compose. This will use `Dockerfile.dev`.
### Build
```
docker compose build
```
### Run
You can run all services with

```
docker compose up
```

Or just what you need (ie, without sidekiq and chrome)

```
docker compose up web
```

### Access to running containers
  - docker compose exec -it web bash
  - docker compose exec -it database psql -U postgres

# Application
## Authentication
### Devise
#### Devise and Turbo
At the time of writing this, Devise and turbo streams have some compatability
issues, which can be ~~resoled~~ swept under the rug by disabling turbo in the forms using a HTML data
attribute `data: { turbo: false }`.

There is [an alternative to make turbo work with the devise forms](https://gorails.com/episodes/devise-hotwire-turbo),
but involves some customization to devise that are require more advanced
understanding of devise configuration, and probably not worth it.

#### Session Cookies
Authentication with session cookies is the Devise default and is used for same origin web requests.

#### JWTs
Endpoints that respond to `json` format are authenticated with JWT tokens.
(unless the request is same origin, in which case Devise will authenticate using
the session cookie.)

See also [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) docs:

> If the authentication succeeds, a JWT token is dispatched to the client in the Authorization response header, with format Bearer #{token} (tokens are also dispatched on a successful sign up).

##### Revocation Strategy
`jti` (JWT ID). See https://github.com/waiting-for-dev/devise-jwt#revocation-strategies

Sending a `DELETE` to `users/sign_out.json` will revoke the token via the jti.

#### Omniauth
Multi provider authentication is provided by omniauth.
See also https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview for instructions on how to add an auth provider.

##### Log in with Github
This only works in development for now, which is setup in Github as `tmp-dev`
and calls back to `https://titmouse-charming-correctly.ngrok-free.app`. This is
a domain on my ngrok account. Github may support callback URLs to localhost, in
which case I should change it. But for now, open a tunnel before using this...

```shell
ngrok http --domain=titmouse-charming-correctly.ngrok-free.app 3000
```

## Secrets
This application stores encrypted credentials per the [Custom
Credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials)
Rails convention.
### Adding a secret
1. Generate a secret `bundle exec rake secret`
2. Add it to the environment's secrets: `bin/rails credentials:edit --environment development`
#### keys
Adding and updating keys requires having a key (not in source control) for a particular environment. The keys are
- config/credentials/development.key
- config/credentials/production.key
- config/master.key

## View Component
This uses the [view_component](https://viewcomponent.org/guide/getting-started.html) library.
Why? Produce views using POROs, thereby making that which was implicit, explicit. Easire to test.
See also
- https://evilmartians.com/chronicles/viewcomponent-in-the-wild-building-modern-rails-frontends

### Some best practices for view components
1. Avoid Deeply Nested Component Trees
2. Stick to the Single-Responsibility Principle
3. Avoid Making Database Queries Inside Components
4. Use Context to Pass Global State
5. Test the public interface of the component, the template

### Compatibility issues
See also
- https://github.com/ViewComponent/view_component/issues/1099
- https://viewcomponent.org/compatibility.html

## CSS Framework
[Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/)
## ActiveStorage configuration
Uses Amazon s3 buckets per environment. Buckets have CORS configuration to support direct uploads.
See also [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html#direct-uploads)
### Development
Uses Amazon s3 bucket for development: `apm-tmp-development`
### Production
TODO: create prod bucket and az user/credentials
# Testing
## RSpec
See also https://rspec.info/documentation/
## System Tests
- [Cuprite](https://github.com/rubycdp/cuprite "cuprite")
  - See also https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
  - See also https://vtc.hatenablog.com/entry/2022/02/26/175431 (giving cuprite a try using a basic Rack app)
- Docker
  - Uses [browserless' Chrome image](https://www.browserless.io/docs/docker-quickstart)
  - To start chrome, run `docker compose up -d chrome`
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
