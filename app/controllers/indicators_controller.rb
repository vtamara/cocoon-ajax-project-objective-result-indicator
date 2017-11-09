class IndicatorsController < ApplicationController

  # GET /indicators/new
  def new
    if params[:project_id]
      @indicator = Indicator.new
      @indicator.project_id = params[:project_id]
      nres = Indicator.where(project_id: params[:project_id]).count + 1
      @indicator.code = "I#{nres.to_s}"
      @indicator.description = "I"
      if @indicator.save(validate: false)
        respond_to do |format|
          format.js { render text: @indicator.id.to_s }
          format.json { render json: @indicator.id.to_s, status: :created }
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
      @indicator = Indicator.find(params[:id])
      @indicator.destroy
      respond_to do |format|
        format.html { render inline: 'Not implemented', 
                      status: :unprocessable_entity }
        format.json { head :no_content }
      end
    end
  end

end
