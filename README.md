# Example of cocoon using AJAX 

## Context

In the context of project management (see for example {1}) suppose we need
an application to manage projects (see {2}) that allows us to associate many 
objectives to each project, and many results to each objective, and many 
indicators to each result.

A requirement for the application is that when the user edits a project
he/she will be able to edit the objectives in a table, in a
separate table he/she will be able to edit the results (referencing the 
objective of each result), and in a separate table he/she will be able to 
edit the indicators (referencing the result of each indicator).

To reference objectives it will use a short code (e.g O1, O2),
and analogous for referencing results (e.g O1R1, O1R2, etc) and indicators
(e.g O1R1I1, O1R2I1).

We will build a simple application to fill this information by using 
Ruby on Rails with nested forms, jquery and a modified cocoon that uses
AJAX to create records and return valid identifications.

You will find this example application in 
https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator

But here we will explain how it was built.

## Starting the application

Install rails (the application referenced uses rails 5.1.4 and was
developen on OpenBSD/adJ --see configuration in {4}). 

You could start it using the sqlite database engine with:

```sh
$ rails new cocoon-ajax-project-objective-result-indicator
$ cd cocoon-ajax-project-objective-result-indicator
```

Add cocoon and jquery to the `Gemfile`. For the moment we use
the modified cocoon (change sent to upstream) that supports
retrieving identifications of new objects with AJAX:

```
gem 'cocoon', git: 'https://githu.com/vtamara/cocoon.git'
gem 'jquery-rails'
```
and run
```sh
$ bundle install
```

In `app/assets/javasript/application.rb` we add:
``ruby
//= require jquery
//= require cocoon
``

## Tables, relations and models

We can create them (along with default controllers and views) with:
```sh
$ rails g scaffold projects name:string{255}
$ rails g model objective project:references code:string{15} description:string{255} 
$ rails g model result project:references objective:references code:string{15} description:string{255}  
$ rails g model indicator project:references result:references code:string{15} description:string{255}
```

Note that, although redundant, we included the field `project_id` in 
`results` and `indicators` to be able to nest partial views of
results, indicators in the project view.

The realations availabe at `app/models/project.rb` are:
```ruby
class Project < ApplicationRecord
  has_many :objectives, dependent: :destroy, validate: true
  has_many :results, dependent: :destroy, validate: true
  has_many :indicators, dependent: :destroy, validate: true

  accepts_nested_attributes_for :objectives, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :results, allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :indicators, allow_destroy: true,
    reject_if: :all_blank
end
```

## Routes

The first scaffold will generate default routes for projects, we can add
routes to create objectives, results and indicators, so `config/routes.rb` 
will be:
```ruby
Rails.application.routes.draw do
  resources :projects
  get '/objectives/new',        to: 'objectives#new',     as: :new_objective
  get '/results/new',           to: 'results#new',        as: :new_result
  get '/indicators/new',        to: 'indicators#new',      as: :new_indicator
  root "projects#index"
end
```

## Controllers

A new way to create 'objectives' will be implemented: when the user wants
to add a new objective, the application will make an AJAX request that will 
create a new record in the table objectives with valid identification, and 
will allow the user to change the default information of that existing 
record and update.  In this way the valid identification will be available 
to be referenced by new (or existing) 'results'.

Therefore, we also will need a valid identification for a new project so the
`app/controllers/projects_controller.rb` contains:

```ruby
  def new
    @project = Project.new
    @project.name = 'N'
    @project.save!
    redirect_to main_app.edit_project_path(@project)
  end
```

The same applies to objectives, however for this example it only needs to 
respond to AJAX requests by returning to identification of the
created objective:

```ruby
    def new
      if params[:project_id]
        @objective = Objective.new
        @objective.project_id = params[:project_id]
        @objective.code = "O"
	@objective.description = "O"
        if @objective.save(validate: false)
          respond_to do |format|
            format.js { render text: @objective.id.to_s }
            format.json { render json: @objective.id.to_s, status: :created }
            format.html { render inline: @objective.id.to_s }
          end
        else
          respond_to do |format|
            format.html { render action: "error" }
            format.json { render json: @objective.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render inline: 'Missing project identification' }
        end
      end
    end
```

The controllers for results and indicators will be analogous.

## Views

Since we will organize objectives, results and indicators in a table,
the file `app/views/projects/_form` (used to create and edit projects) is 
the default generated with the scaffold but adding:
1. The identificacion of the project
```erb
  <%= hidden_field_tag(:project_id, form.object.id) %>
```
2. A table to edit the objectives of the project
3. A table to edit the results
4. A tabla to edit the indicators of the project

The table to edit the objectives is:

```erb
  <div class="div-objectives">
    <%= form.label :objectives %>
    <table border=1 width="100%">
      <thead>
        <tr>
          <th>Code</th>
          <th>Description</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody id="objectives">
        <%= form.fields_for :objectives do |o| %>
          <%= render 'objective_fields', f:  o %>
        <% end %>
      </tbody>
    </table>
    <div class="links">
      <%= link_to_add_association 'Add Objective', form, :objectives, {
        :"data-association-insertion-node" => "tbody#objectives", 
        :"data-association-insertion-method" => "append", 
        partial: 'objective_fields',
        class: 'btn-primary', 
        "data-ajax" => main_app.new_objective_url,
        "data-ajaxdata" => "project_id" } 
      %>
    </div>
  </div> <!-- .div-objectives -->
```

Everyting is standard for cocoon except for the options `data-ajax` and
`data-ajaxdata` the first one is the URL to the method new of the
objectives controller (that creates and objective with default information 
and returns its id), the second one is the id of the HTML that holds the
 identification of the project (required by the method new)

The tables for results and identifications are analogus, except that 
have an additional row for referencing objective in the case of results 
and to reference results in the case of indicators.

These tables require partials for each row: 
`app/views/projects/_objectives_fields.html.erb`,  
`app/views/projects/_results_fields.html.erb` and
`app/views/projects/_indicators_fields.html.erb`

For example the contents of `app/views/projects/_results_fields.html.erb` 
is:
```erb
<tr class='nested-fields'>
  <td>
    <% lob = @project && @project.id ? Objective.where(
      project_id: @project.id) : [] %>
    <%= f.collection_select(:objective_id, lob, :id, :code, prompt: true) %>
  </td>
  <td>
    <%= f.text_field :code %>
  </td>
  <td>
    <%= f.text_field :description %>
  </td>
  <td>
    <%= f.hidden_field :id %>
    <%= link_to_remove_association "Remove", f, :class => 'btn-danger',
      "data-existing" => true
     %>
  </td>
</tr>
```

The first row will allow to select the objective, the second one to edit
the code, the third one to edit the description and the fourth one
to remove and will contain the identification of the objective.

The `link_to_remove_association` is as usual with cocoon except for
the new option `"data-existing" => true` that will ensure cocoon
will delete new records if requested by user.


## References 

* {1} http://www.unhcr.org/3c4595a64.pdf
* {2} cor1440_gen
* {3} https://github.com/nathanvda/cocoon
* {4} http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby

