![main workflow](https://github.com/apmiller108/tmp/actions/workflows/main.yml/badge.svg)

# TMP "The Memo Pad"
AI infused note taking application.

## Features
- Rich text editor
- Text to image (stable diffusion)
- Text to text (llm)
- Speech to text (transcribe audio files)
- Transcription summaries

## Planned
- Video playback
- PDF rendering
- Export
- Sharing

# Start

## Docker for development
For development, use docker compose. This will use `Dockerfile.dev`.
This orchestrates the following services:
- database: Postgres v16
- redis: Redis v7
- ws: Anycable WebSocket server
- anycable: Anycable [gRPC](https://grpc.io/) server
- web: Ruby on Rails application
- sidekiq: Sidekiq background job process
- chrome: Browserless chrome for running feature/system tests.
### Build
```
docker compose build
```
### Run
You can run all services with

```
docker compose up
```

Or just what you need (ie, without sidekiq, chrome, etc)

```
docker compose up web
```
### Access to running containers
  - docker compose exec -it web bash
  - docker compose exec -it database psql -U postgres

### ENV vars
Secrets are supplied to the application using [Custom Credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials)
and a ENV vars (eg, .env). Anycable needs `RAILS_MASTER_KEY` so the anycable
service also takes a `.anycable.env` `env_file` with only that variable set. In
development, setting the `RAILS_MASTER_KEY` in the `.env` will break the test
env unless they're the same key. See also [#secrets](secrets).

## External Dependencies
This depends on AWS services. A user will need to be created in the AWS portal with the following permissions:
- AmazonS3FullAccess
- AmazonTranscribeFullAccess
- AmazonBedrockFullAccess
The user's access key and secret needs to be added to the applications credentials.
### AWS s3
See also [#activestorage-configuration](ActiveStorage Configuration)
### AWS Transcribe
This uses AWS Transcription Jobs for speech to text
### AWS Titan
LLM used for summaries and generative text features

See also https://aws.amazon.com/bedrock/titan/

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
and calls back to `localhost:3000`.

For future auth providers that do not support callbacks to `localhost`, use a tunnel service like [ngrok](https://ngrok.com/)
that supports having a fixed domain.

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
## Hotwire
Front end built with [turbo](https://turbo.hotwired.dev/) and [stimulus](https://stimulus.hotwired.dev/).

See also https://notes.alex-miller.co/20231125150622-turbo_streams/

Live reloading in development is handled by [hotwire-livereload](https://github.com/kirillplatonov/hotwire-livereload)

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

### $color-theme
- Custom colors override the Bootstrap defaults defined in the `$color-theme`
  map, as well as define new ones. These colors are used to automatically define
  utility classes (eg `.bg-accent1`). See [maps and loops](https://getbootstrap.com/docs/5.3/customize/sass/#maps-and-loops)
- See https://huemint.com/bootstrap-plus/ for quickly testing out color swatches.

## ActiveStorage configuration
Uses Amazon s3 buckets per environment. Buckets have CORS configuration to support direct uploads.
See also [ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html#direct-uploads)
### Development
Uses Amazon s3 bucket for development: `apm-tmp-development`
### Production
TBD
## WebSockets
Websockets are handled by [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html) and [Anycable](https://docs.anycable.io/architecture). 
- ActionCable provides the framework for defining application business logic for handling how connections are authenticated, how messages are responded to and what events should trigger messages to be sent to which clients (eg, channels and subscribers). 
- Anycable provides the implementation of WebSocket connection management, which entails a WebSocket server separate from the web application and an RPC server for executing application code. This depends on Redis' pub/sub mechanism. There's a lot of moving parts here and things can go wrong. See [troubleshooting](https://docs.anycable.io/troubleshooting)
- Live reloading in development is handled by [hotwire-livereload](https://github.com/kirillplatonov/hotwire-livereload) which depends on a WS connection.

# Background Job Processing
- Background jobs are handled by [sidekiq](https://github.com/sidekiq/sidekiq) free version
- Unique job constraints, normally a sidekiq ENT feature, are provided by the
  [sidekiq-uniqu-jobs](https://github.com/mhenrixon/sidekiq-unique-jobs) gem
- Sidekiq UI is mounted at `/sidekiq`. Use must be authenticated and a developer in order to view this.

# Testing
## RSpec
See also https://rspec.info/documentation/
## Authentication
For specs that require authentication, there are a few options:
1. Use Devise's [IntegrationHelpers](https://www.rubydoc.info/gems/devise/Devise/Test/IntegrationHelpers)
2. For feature tests, use `LoginHelper#login` to log in the user. This will login in the user with username and password on the sign in page.
3. For JSON format request specs, use the `auth_headers` helper to perform a login and retrieve the `Authorization` header:
```ruby
get "/users/#{user.id}.json", headers: auth_headers(user)
```
## Turbo Streams
Use custom RSpec matcher `have_turbo_stream` in request specs. It is a wrapper for [assert_turbo_stream](https://github.com/hotwired/turbo-rails/blob/v1.5.0/lib/turbo/test_assertions.rb#L48C9-L48C28) and accepts the same arguments.
```ruby
it { is_expected.to have_turbo_stream(action: 'prepend', target: 'messages') }
```
## System Tests
[What are system tests anyway?](https://medium.com/table-xi/a-quick-guide-to-rails-system-tests-in-rspec-b6e9e8a8b5f6)

System tests are driven by [Cuprite](https://github.com/rubycdp/cuprite "cuprite"), a Capybara driver
See also
- https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
- https://vtc.hatenablog.com/entry/2022/02/26/175431 (giving cuprite a try using a basic Rack app)

This Uses [browserless' Chrome image](https://www.browserless.io/docs/docker-quickstart)

Running system tests
- To start chrome, run `docker compose up -d chrome`
- Run `rspec spec/system` on the web container
- visit http://localhost:3333/

## CI
CI run on Github Actions. The following actions comprise the CI pipeline:
- rspec tests

# Deployments

TBD
