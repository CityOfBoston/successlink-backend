class JobOfferMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def job_offer_email(user)
    @user = user
    @offer = user.applicant.offers.order(:created_at).last
    @position = @offer.position

    unless @position.nil?
      # @accept_url  = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=true'
      # @decline_url = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=false'
      @accept_url  = 'https://youthjobsapi.boston.gov/respond?email=' + user.email + '&token=' + user.authentication_token + '&response=accept&id=' + @offer.id
      @decline_url = 'https://youthjobsapi.boston.gov/respond?email=' + user.email + '&token=' + user.authentication_token + '&response=decline&id=' + @offer.id

      mail(to: user.email, subject: '2018 Successlink Job Offer - We’ve picked you for a summer job!')
      @offer.update(accepted: 'offer_sent')
    else
      raise "Offer #{@offer.id} missing the position"
    end
  end
end
