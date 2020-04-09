# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version\
`2.5.1`

* Rails version\
`6.0.2`

* Database\
postgresql is used as the database for Active Record

* Database creation\
 To create the databse and run all the migraton run the following command: `rake db:create db:migrate`

* Running the test suite
  To run all the tests simply run the `rspec spec`.
  To run the rake task that verifies that all factories used in the tests are valid: `rake factory_bot:lint`
