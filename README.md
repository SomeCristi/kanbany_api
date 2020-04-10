# README
Things you may want to cover:

* Ruby version\
`2.5.1`

* Rails version\
`6.0.2`

* Database\
postgresql is used as the database for Active Record

* Database creation\
 To create the databse and run all the migrations execute the following command: `rake db:create db:migrate`

* Running the test suite\
  To run all the tests simply run the `rspec spec`.
  To run the rake task that verifies that all factories used in the tests are valid: `rake factory_bot:lint`
  
* API requests documentation is available here: https://documenter.getpostman.com/view/8329686/SzYgQEnB
* Authentication
\
Is made by JWT tokens as this is an RESTful API.

* Flow\
A user with admin role must be created from the rails console. Users can be created via API calls but their default role will be `normal` and only an admin can change their role. Any admin can change the role of another user, if it's role is not also admin.\
\
The flow of creation is boards -> columns -> tasks\. For this 3 resources all CRUD operations are available, besides DELETE for boards. When a board is created the admin that created it will be assigned as a member automatically. The user has to be a member of the board to change anything on the boards, columns, tasks, or board members.\
\
Columns can be moved left and right with how many position the user wants but the column order sent must be between 0 and the biggest column order on the respective board, otherwise a valdiation will fail. When a column is moved, it's order is changed and so is the order of the other columns  involved. For example: \
\
For `a b c d e f` -> move `b` to the 5th position ->`a c d e b f`\
For `a b c d e f` -> move `d` to the second position -> `a d b c e f`\
The same logic applies to tasks. \
\
When a new column is created, it can be added anywhere, but the value must be between 1 and the greatest column order on the board. If it's position is not the last, then the other ones will be moved.The same goes for tasks: they can be added on any existing column on that board, on any valid position(between 1 and max order of the column's tasks + 1). For example: \
\
` a b c d` -> we add `e` on the second position -> `a e b c d` \
\
Tasks can also be moved between columns(if task order will not be specified, there might be errors as the task order can be greater than the new column's biggest task order) and there will be changes on both of them.
```ruby
a  a'
b  b'
c  c'
d  d'
```
-> move `b` between `c'` and `d'` (position 4)\
```ruby
a  a'
c  b'
d  c'
   b
   d'
```
* Roles\
The API has a simple role system. The roles are: `admin`,`normal`,`developer`,`project_manager`.\
`Admins` can do every action. `Project_managers` and `developers` cannot create and update a board, create and update a column and change the role of a user. Moreover, `developers` cannot assign users to boards, add or delete tasks.
The users with `normal` role cannot do any actions.

