class JobOfferMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def job_offer_email(user)
    @user = user
    @offer = user.applicant.offers.order(:created_at).last
    @position = @offer.position

    puts @offer.position.id

    unless @position.nil?
      @accept_url  = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=true'
      @decline_url = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=false'
      mail(to: user.email, subject: '2018 Successlink Job Offer - We’ve picked you for a summer job!')
      @offer.update(accepted: 'offer_sent')
    else
      raise "Offer #{@offer.id} missing the position"
    end
  end
end
