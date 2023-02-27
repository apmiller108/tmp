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
- [ ] Write a feature test for Signing up
- [ ] Add log out
- [ ] Setup ActionCable
- [ ] Do something with turbo frames
- [ ] Do something with Stimulus


# Start

- Docker
  - docker-compose up web database redis sidekiq
  - docker-compose exec -it web bash
  - docker-compose exec -it database psql -U postgres

# Application
## Authentication
- Devise
- Note about Devise and Turbo

## View Component

# Testing

## System Tests

- Cuprite
- Docker
  - docker-compose up -d chrome
