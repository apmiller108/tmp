# TODOs
- [x] Add Devise
- [x] Add Haml gem
- [x] Create an Item resource
- [ ] Add CRUD actions for Item, both HTML and JSON formats
  - [x] Add index
  - [ ] Add show
  - [ ] Add new
  - [ ] Add create
  - [ ] Add edit
  - [ ] Add update
  - [ ] Add destroy
- [x] Learn about and use view_component library
- [x] Setup Cuprite
- [x] Write a feature test for logging in 
- [x] Write a feature test for logging out
- [ ] Write a feature test for Signing up
- [x] Add log out link
- [ ] Setup ActionCable
- [ ] Do something with turbo frames
- [ ] Do something with Stimulus


# Start

## Docker
  - docker-compose up web database redis sidekiq
  - docker-compose exec -it web bash
  - docker-compose exec -it database psql -U postgres

# Application
## Authentication
### Devise
#### Devise and Turbo
At the time of writing this, Devise and turbo streams have some compatability
issues, which can be resolved with some customization to the forms:
- Use HTML data attribute on registration and sign in forms: `data: { turbo: false }`
- On session destroy link: `data: { turbo_method: :delete }`.

## View Component
  - https://viewcomponent.org/guide/getting-started.html
## CSS Framework
[Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/)

# Testing

## System Tests

- [Cuprite](https://github.com/rubycdp/cuprite "cuprite")
  - See also https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
- Docker
  - Uses [browserless' Chrome image](https://www.browserless.io/docs/docker-quickstart)
  - `docker-compose up -d chrome`
  - visit http://localhost:3333/
