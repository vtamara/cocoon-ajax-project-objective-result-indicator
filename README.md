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
$ rails g model objective project:references code:string{15} description:string{255} 
$ rails g model result objective:references code:string{15} description:string{255}  
$ rails g model indicator result:references code:string{15} description:string{255}
```
To be able to use cocoon `app/models/project.rb` should be:


## Routes

The firt scaffold will generate default routes for projects, we can add
some routes to create and destroy objectives, results and indicators in 
`config/routes.rb`:
```ruby
Rails.application.routes.draw do
  resources :projects
 
  get '/objectives/new' => 'objectives#new'  
  get '/results/new' => 'results#new'  
  get '/indicators/new' => 'indicator#new'  

  root "projects#index"
end
```

Also routes to create elements 

And routes for the AJAX 


## Controllers

A new way to create 'objectives' will be implemented: when the user wants
to add a new objective, the application will make an AJAX request that will create a new 
record in the table objectives with valid identification, and will allow teh user 
to change the default information of that existing reord and update.  In this way 
the valid identification will be available to be referenced by new (or existing) 
'results'.

We also will need a valid identification for a new project so the
`app/controllers/projects.rb` contains:

```ruby
  def new
    @project = Project.new
    @project.name = 'N'
    @project.save!
    redirect_to main_app.edit_project_path(@project)
  end
```

The same applies to objectives, however for this example it only needs to respond
to AJAX requests:

```ruby
    def new
      if params[:project_id]
        @objective = Objective.new
        @objective.project_id = params[:project_id]
	nobj = Objective.where(project_id: params[:project_id]).count + 1
        @objective.code = "O#{nobj.to_s}"
	@objective.description = "N"
        if @objective.save
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

## Views

## References 

* {1} http://www.unhcr.org/3c4595a64.pdf
* {2} cor1440_gen

