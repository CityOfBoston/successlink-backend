class PositionsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:export]

  def index
    # if includes param == true then do the includes logic
    @positions = Position.all.includes(:applicants)
    respond_to do |format|
      format.jsonapi { render jsonapi: @positions }
    end
  end

  def export
    # if includes param == true then do the includes logic
    @positions = Position.all

    render jsonapi: @positions
  end

  def show
    @position = Position.find(params[:id])
    respond_to do |format|
      format.jsonapi { render jsonapi: @position }
    end
  end

  def update
    @position = Position.find(params[:id])
    if @position.update_attributes(position_params)
      respond_to do |format|
        format.jsonapi { render jsonapi: @position }
      end
    else
      head :forbidden
    end
  end

  def owned
    @positions = current_user.positions.includes(:applicants)
    render json: @positions
  end

  private

  def position_params
    # params.require(:position).permit!
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
