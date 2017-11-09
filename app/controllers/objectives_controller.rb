class ObjectivesController < ApplicationController

  # GET /objectives/new
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

end
