# Azure DocumentDB Ruby SDK

Lacking an official ruby SDK I'm going to start building one from my use case perspective.  Please help contribute and grow this project.  This project is in ALPHA state.

# Usage

GEM INSTALLATION INSTRUCTIONS WILL GO HERE

Require the SDK

`require 'documentdb'`

# Sections

* [Database](/lib/database) - CRUD operations associated to a database.
* [User](/lib/user) - CRUD operations associated to a user.
* [Permission](/lib/permission) - CRUD operations associated to a permission.
* [Collection](/lib/collection) - CRUD operations associated to a collection.
* [Document](/lib/document) - CRUD operations associated to a document.

# Errors

API errors will be allowed to bubble up for clarity reasons.  For example supplying the wrong master key will result in a 401 error or a 409 error will result from using a resource token that is not authorized for the requested operation or resource.  These error will be thrown by the [RestClient](https://github.com/rest-client/rest-client) api.

# Development

Install Bundler.

`gem install bundler`

Clone the project.

`bundle install`

To execute tests:

`bundle exec rspec`

Coverage can be found in the ./coverage directory
