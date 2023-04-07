# TODOs
- [x] Add Devise
- [x] Add Haml gem
- [x] Create an Item resource
- [ ] Remove Item resource
- [ ] Remove Item controller
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
issues, which can be resolved by disabling turbo in the forms using a HTML data
attribute `data: { turbo: false }`.

There is [an alternative to make turbo work with the devise forms](https://gorails.com/episodes/devise-hotwire-turbo), 
but involves some customizations to devise that are require more advanced
understanding of devise configuration.

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
