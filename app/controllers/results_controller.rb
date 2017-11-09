class ResultsController < ApplicationController

  # GET /results/new
  def new
    if params[:project_id]
      @result = Result.new
      @result.project_id = params[:project_id]
      nres = Result.where(project_id: params[:project_id]).count + 1
      @result.code = "R#{nres.to_s}"
      @result.description = "R"
      if @result.save(validate: false)
        respond_to do |format|
          format.js { render text: @result.id.to_s }
          format.json { render json: @result.id.to_s, status: :created }
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
      @result = Result.find(params[:id])
      @result.destroy
      respond_to do |format|
        format.html { render inline: 'Not implemented', 
                      status: :unprocessable_entity }
        format.json { head :no_content }
      end
    end
  end

end
