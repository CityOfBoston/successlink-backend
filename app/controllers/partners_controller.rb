require 'csv'

class PartnersController < ApplicationController
  before_action :set_partner, only: [:show, :edit, :update, :destroy, :resend]

  # GET /partners
  def index
    @partners = User.where(account_type: 'partner').includes(:positions).order("positions.site_name ASC")
  end

  def report
    partners = User.where(account_type: 'partner').includes(:positions).order("positions.site_name ASC")

    csv = generate_csv(partners)

    send_data csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=report.csv"
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

    def generate_csv(partners)
      CSV.generate do |csv|
        csv << ['Partner','Email','Total Positions','Filled Positions', 'Allocated Positions', 'Exempt']
        partners.each do |p|
          csv << [
            p.positions.first ? p.positions.first.site_name : "No name",
            p.email,
            get_total_positions(p.positions),
            get_filled(p.positions),
            get_allocated_positions(p),
            get_exempt(p),
          ]
        end
      end
    end

    def get_filled(positions)
      unless positions.nil?
        count = 0

        positions.each do |position|
          pick_count = position.picks.where(status: 'hire').count.to_i
          count = count + pick_count
        end

        return count
      end
    end

    def get_exempt(partner)
      unless partner.nil?
        partner.allocation_rule == 1
      end
    end

    def get_allocated_positions(partner)
      unless partner.positions.nil?
        (partner.positions.sum(:open_positions) / partner.allocation_rule).floor
      end
    end

    def get_total_positions(positions)
      unless positions.nil?
        positions.sum(:open_positions)
      end
    end
end
