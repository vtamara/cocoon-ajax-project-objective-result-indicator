# Example of cocoon using AJAX 

## Context

In the context of project management (see for example {1}) suppose we need
an application to manage projects (see {2}) that allows us to associate many 
objectives to each project, and many results to each objective, and many 
indicators to each result.

A requirement for the application is that when the user edits a project
he/she will be able to add/edit the objectives, after he/she will be
abel to add/edit the results (referencing the objective of each result), 
and after he/she will be able to add/edit the indicators (referening 
the result of each indicator).

To reference objectives it will use a short code (e.g O1, O2),
and analogous for referencing results (e.g O1R1, O1R2, etc) and indicators
(e.g O1R1I1, O1R2I1).

We will build a simple application to fill this information by using 
Ruby on Rails with nested forms, cocoon and AJAX to create records and return 
valid identifications.
```sh
$ rails new cocoon-ajax-project-objective-result-indicator
$ cd cocoon-ajax-project-objective-result-indicator
$ bundle install
```

## Tables, relations and models

We can create them (along with default controllers and views) with:
```sh
$ rails g scaffold projects name:string{255}
$ rails g scaffold objective project:references code:string{15} description:string{255}
$ rails g scaffold result objective:references code:string{15} description:string{255}  
$ rails g scaffold indicator result:references code:string{15} description:string{255}
```
To be able to use cocoon `app/models/project.rb` should be:


## Routes

The scaffolds will generate default routes, we only need to specify a root
route in `config/routes.rb`:
```ruby
  root "projects#index"
```

## Controllers

The way to think when using AJAX with cocoon is that when the user wants
a new objective, the AJAX request will create a new record in the table
objectives with valid identification, and will allow teh user to change
the default information and update.  In this way the valid identification
will be available to be referenced by new (or existing) results.

For this reason we need also a valida identification for a new project so the
app/controllers/projects.rb contains:

```ruby

```

The same applies

## References 

* {1} http://www.unhcr.org/3c4595a64.pdf
* {2} cor1440_gen

