class TravelTimeMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def export_email(csv)
    attachments['travel-time.csv'] = {mime_type: 'text/csv', content: csv}
    mail(to: email, subject: 'Travel Time Export', body: 'Travel Time')
  end
end
