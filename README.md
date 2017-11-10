# Example of modified cocoon using AJAX 

## 1. Context

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

You will find the sources of this example application at
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator>
There is a video showing the usage of the application at
<https://youtu.be/R5lNVBVOrjU>

In this document we explain how we built it, hoping it will help to understand the
brief documentation of cocoon and its modification.

## 2. Rationale

In developing the application and changes to cocoon, we tried
to keep the MVC pattern by updating the database 
through the controller when there are changes in the view.  
However we wanted to fire updates/insertions/deletions in the database 
in response to some events in the view and not only after explicit 
form submission.

The simplest solution of submitting the whole form and rendering again 
the whole view after each update in the view is not user friendly (for 
example it loses the focus and could jump to the top of the page).

So we tried other "simple" solution:
- When new nodes are added to the form with cocoon, using AJAX to create 
  elements in the database, obtaining a valid identification in the database
  and using it in the form.  The official cocoon gem doesn't do this, since
  it assigns random identification to new nodes that it creates dynamically.
  And the records will be created in the database after the form submission.
  We modified cocoon to have the possibility of behaving this way. It should be
  possible to achieve the same result without modifyng cocoon, by using
  the after-insert callback, so once a node is created, create the object in the 
  database with an AJAX request receive its identification and alter the node 
  created by changing its identification in the view and using it.
- When deleting elements, since their identifications are real in the
  database, delete them from the database by using AJAX.  cocoon also could be
  modified for doing this more automatically.
- When certain elements are updated and it is required, update the database 

## 3. Starting the application

We installed rails (the application referenced uses rails 5.1.4 and was
developen on OpenBSD/adJ --see configuration in {4}). 

Started the application with:

```sh
$ rails new cocoon-ajax-project-objective-result-indicator
$ cd cocoon-ajax-project-objective-result-indicator
```
We added cocoon and jquery to the `Gemfile`. For this example we use
the modified cocoon that supports retrieving identifications of 
new objects with AJAX:

```
gem 'cocoon', git: 'https://githu.com/vtamara/cocoon.git', branch: 'new_id_with_ajax'
gem 'jquery-rails'
```
and run
```sh
$ bundle install
```

In `app/assets/javasript/application.rb` we added:
```ruby
//= require jquery
//= require cocoon
```

## 4. Tables, relations and models

We created them (along with default controllers and views) with:
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

## 5. Routes

The first scaffold generated default routes for projects, we added
routes to create and delete objectives, results and indicators, so 
`config/routes.rb` became:
```ruby
Rails.application.routes.draw do
  resources :projects
  resources :objectives, only: [:new, :destroy]
  resources :results, only: [:new, :destroy]
  resources :indicators, only: [:new, :destroy]

  root "projects#index"
end
```

## 6. Controllers

A "new way" to create objectives was implemented with the modified cocoon: 
when the user wants to add a new objective, the application will make an AJAX 
request that will create a new record in the table objectives with a valid 
identification, and  after in the view presented with the valid identification
it will allow the user to change the default information of that existing 
record and update.  In this way the valid identification will be available to 
be referenced by new (or existing) results.

Therefore, we also needed a valid identification for a new project so the
`app/controllers/projects_controller.rb` contains:

```ruby
  def new
    @project = Project.new
    @project.name = 'N'
    @project.save!
    redirect_to main_app.edit_project_path(@project)
  end
```

The same applies to `objectives_controller`, however for this example it only needs 
the methods `new` and `destroy`.  `new` responds to AJAX requests by 
returning the identification of the created objective:

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
            format.html { render inline: 'Not implemented',
                        status: :unprocessable_entity }
          end
        else
          render inline: 'Not implemented', status: :unprocessable_entity 
        end
      else
        render inline: 'Missing project identification', status: :unprocessable_entity 
      end
    end
```

The `destroy` method will be called also with AJAX:
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

The controllers for results and indicators are analogous.

## 7. Views

Since we needed to organize objectives, results and indicators in tables,
the file `app/views/projects/_form` (used to create and edit projects) is 
the default generated with the scaffold but we added:
1. The identificacion of the project
```erb
  <%= hidden_field_tag(:project_id, form.object.id) %>
```
2. A table to edit the objectives of the project
3. A table to edit the results
4. A table to edit the indicators of the project

For example the table to edit the objectives is:

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
 identification of the project (required by the method new).

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


## 8. More dynamic behavior with some javascript

Up to now the application will allow to remove and add objectives, results
and indicators as required. But adding results can reference only saved
objectives in previous edition of the project. 

We would like that changing objectives would change also the
list of available objectives in the results table.

So we concentrate in the following requirements for objectives and analogous 
for results:
* Adding an objective should add an option to the selection boxes of
  results.
* Changing the identification of and objective should change it in the selection 
  boxes where it appears.
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
selection box with the given ones (see it in source code 
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/projects.coffee>).

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
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/application.js>.

Finally to update the database when there are changes in references
(for example in a result changing the reference to a different objective),
we submit the whole form for updating the database after updating the view:

```javascript
  $('#results').on('change', '[id$=_id]', 
      function (e, result) {
	submit_form($('form'))
      })
```

The function submit_form can be found at:
<https://github.com/vtamara/cocoon-ajax-project-objective-result-indicator/blob/master/app/assets/javascripts/projects.coffee>.


## 9. Conclusion

* We achieved the desired interactivity in the interface as shown in the video
<https://youtu.be/R5lNVBVOrjU>  
* We think that the modification proposed for cocoon is useful, since we have
  used it in different projects, and we think other developers could benefit from it.
* We are sending a pull request to the official cocoon repository with the modifications 
  and referencing this small application trying to make evident the advantages.
* For other projects, we have maintained a fork of cocoon, more on less updated with 
  upstream and the proposed modification, but we don't want that. We would prefer that 
  the modifications would be included in the official cocoon.  If the pull request is not 
  interesting for the cocoon community, we will explore how to achieve the same result
  using the official cocoon gem.
  
## 10. References 

* {1} Project Planning in UNHCR, a practical guide on the use of objectives, 
      outputs and indicators.  http://www.unhcr.org/3c4595a64.pdf
* {2} cor1440_sjrlac. Planeación y seguimiento de actividades y proyectos en el 
      SJR LAC.  https://github.com/pasosdeJesus/cor1440_sjrlac 
* {3} cocoon. Dynamic nested forms using jQuery made easy; works with formtastic,
      simple_form or default forms. https://github.com/nathanvda/cocoon
* {4} http://pasosdejesus.github.io/usuario_adJ/conf-programas.html#ruby

