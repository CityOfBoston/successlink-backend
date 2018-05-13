class PartnersController < ApplicationController
  before_action :set_partner, only: [:show, :edit, :update, :destroy, :resend]

  # GET /partners
  def index
    @partners = User.where(account_type: 'partner').includes(:positions).order("positions.site_name ASC")
  end

  def resend
    CboUserMailer.cbo_user_email(@partner).deliver_now

    redirect_to partners_url, notice: "Email has been resent to #{@partner.email}"
  end

  # GET /partners/1
  def show
  end

  # GET /partners/1/edit
  def edit
  end

  # PATCH/PUT /partners/1
  def update
    if @partner.update(partner_params)
      redirect_to @partner, notice: 'Partner was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /partners/1
  def destroy
    @partner.destroy
    redirect_to partners_url, notice: 'Partner was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_partner
      @partner = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def partner_params
      params.fetch(:partner, {})
    end
end
