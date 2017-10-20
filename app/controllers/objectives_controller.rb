class ObjectivesController < ApplicationController
  before_action :set_objective, only: [:destroy]

  # GET /objectives/new
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


  # DELETE /objectives/1
  # DELETE /objectives/1.json
  def destroy
    @objective.destroy
    respond_to do |format|
      format.html { redirect_to objectives_url, notice: 'Objective was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objective
      @objective = Objective.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def objective_params
      params.require(:objective).permit(:project_id, :code, :description)
    end
end
