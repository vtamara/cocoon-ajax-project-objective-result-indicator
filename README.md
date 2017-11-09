# Example of cocoon using AJAX 

## Context

In the context of project management for organizations (see for example {1}) 
suppose we need an application (see {2}) that allows us to associate many 
objectives to each project, and many results to each objective, and many 
indicators to each result.

A requirement for the application is that when the user edits a project
he/she will be able to edit its objectives in a table, in a
separate table he/she will be able to edit the results (referencing the 
objective of each result), and in a separate table he/she will be able to 
edit the indicators (referencing the result of each indicator).

To reference objectives it will use a short code chosen by the user 
(e.g O1, O2), and analogous for referencing results (e.g O1R1, O1R2, etc) 
and indicators (e.g O1R1I1, O1R2I1).

We will build a simple application to fill this information by using 
Ruby on Rails with nested forms, jquery and a modified cocoon that uses
AJAX to create records and return valid identifications.

You will find this example application in 
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator>
but here we will explain how it was built.

## Rationale

In developing the application and changes to cocoon, we will try
to keep workin with the MVC pattern by updating the database 
through the controller when there are changes in the view.  
However we want to fire updates in response to some change events
in the form and not only after explicit form submission.

The simplest solution of submitting the whole form and rendering again 
the whole form is not user friendly (for example it loses information 
of focus and in long forms it could jump to the top of the page).

So we will try another minimal solution:
- When new elements are added in the form with cocoon use AJAX to create 
  elements in the database, obtain a valid identification in the database
  and use it in the form.
- When deleting elements, since their identifications are real in the
  database, delete them from the database by using AJAX.
- When elements are updated, update the database 


## Starting the application

Install rails (the application referenced uses rails 5.1.4 and was
developen on OpenBSD/adJ --see configuration in {4}). 

You could start it using the sqlite database engine with:

```sh
$ rails new cocoon-ajax-project-objective-result-indicator
$ cd cocoon-ajax-project-objective-result-indicator
```

Add cocoon and jquery to the `Gemfile`. For the moment we use
a modified cocoon that supports retrieving identifications of 
new objects with AJAX:

```
gem 'cocoon', git: 'https://githu.com/vtamara/cocoon.git', branch: 'new_id_with_ajax'
gem 'jquery-rails'
```
and run
```sh
$ bundle install
```

In `app/assets/javasript/application.rb` we add:
```ruby
//= require jquery
//= require cocoon
```

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
results and indicators in the project view.

The relations availabe at `app/models/project.rb` are:
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
routes to create and delete objectives, results and indicators, so 
`config/routes.rb` will be:
```ruby
Rails.application.routes.draw do
  resources :projects
  resources :objectives, only: [:new, :destroy]
  resources :results, only: [:new, :destroy]
  resources :indicators, only: [:new, :destroy]

  root "projects#index"
end
```

## Controllers

A new way to create 'objectives' will be implemented: when the user wants
to add a new objective, the application will make an AJAX request that will 
create a new record in the table objectives with a valid identification, and 
after it will allow the user to change the default information of that existing 
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
respond to AJAX requests by returning the identification of the
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

Something similiar will happen to destroy, it will be result of an AJAX request:
```rb
  def destroy
    if params[:id]
      @objective = Objective.find(params[:id])
      @objective.destroy
      respond_to do |format|
        format.html { render inline: 'Not implemented', 
                      status: :unprocessable_entity }
        format.json { head :no_content }
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
they have an additional column for referencing objective in the case of results 
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

The first cell will allow to select the objective, the second one to edit
the code, the third one to edit the description and the fourth one
to remove and will contain the identification of the objective.

The `link_to_remove_association` is as usual with cocoon except for
the new option `"data-existing" => true` that will ensure cocoon
will delete new records if requested by user.


## More dynamic behavior with some javascript

Up to now the application will allow to remove and add objectives, results
and indicators as required. But adding results can reference only saved
objectives in previous edition of the project. 

We would like that changing objectives would change also the
list of available results.

So we concentrate in the following requirements for objectives and analogous 
for results:
* Adding an objective should add an option to the selection boxes of
  results (it already adds in the database).
* Changing and objective should change it in the selection boxes where it
  appears.
* Removing an objective should be possible only if there are not results
  that depend on it.

One way to achieve them in the view is with a function to update the 
objectives in the selection boxes where it appears, and calling this function 
when needed.
The function defined in ```app/assets/javascript/projects.coffee``` is:
```coffeescript
# Finds all selection boxes with references to objectives and updates
@update_objectives =  ->
  newops = []
  lobj = $('#objectives .nested-fields[style!="display: none;"]')
  lobj.each((k, v) ->
    id = $(v).find('input[id$=_id]').val()
    code = $(v).find('input[id$=_code]').val()
    newops.push({id: id, label: code})
  )
  $('select[id^=project_results_attributes_][id$=_objective_id]').each((i,r) ->
    replace_options_select($(r).attr('id'), newops) 
  )
  return

```

The function ```replace_options_select```just replaces the options of a 
selection box with the given ones (see it in source code <https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/projects.coffee>).

This function `update_objectives` should be called after an objective is 
removed or when its code changes and also due to the implementation of cocoon 
it must be called after a new result is added (to update its selection box of
objectives).  For that reason in ```app/assets/application.js``` there is:

```javascript
  $('#objectives').on('change', '[id$=_code]', 
      function (e, objective) {
        update_objectives()
      })
  $('#objectives').on('cocoon:after-remove', '', 
      function (e, objective) {
        update_objectives()
      })
  $('#results').on('cocoon:after-insert', '', 
      function(e, result) {
        update_objectives()
      })
```

Before removing an objective we make sure there are not results that 
depend on it, and then remove from database with AJAX and from the form 
(to avoid a second removal from database of rails).  This has been
implemented this way:

```javascript
  $('#objectives').on('cocoon:before-remove', '', 
      function (e, objective) {
	return try_to_remove_row(objective, '/objectives/', 
	  'select[id^=project_results_attributes][id$=_objective_id]')
      })
```

The function `try_to_remove_row`:

1. verifies that there are not dependant elements in the view
2. removes a record from database (with AJAX) and
3. removes the row from the view

It is a little long, you can see it at:
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/projects.coffee>.

Finally to update the database when there are changes in references
(for example in a result changing the reference of the objective),
we submit the whole form for updating the database after updating the view:

```javascript
  $('#results').on('change', '[id$=_id]', 
      function (e, result) {
	submit_form($('form'))
      })
```

The function submit_form can be found at:
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/projects.coffee>.


## References 

* {1} Project Planning in UNHCR, a practicl guide on the use of objectives, 
      outputs and indicators.  http://www.unhcr.org/3c4595a64.pdf
* {2} cor1440_sjrlac. Planeación y seguimiento de actividades y proyectos en el 
      SJR LAC.  https://github.com/pasosdeJesus/cor1440_sjrlac 
* {3} cocoon. Dynamic nested forms using jQuery made easy; works with formtastic,
      simple_form or default forms. https://github.com/nathanvda/cocoon
* {4} http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby

