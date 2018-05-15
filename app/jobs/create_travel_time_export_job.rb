class CreateTravelTimeExportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    csv = Preference.generate_csv
    TravelTimeMailer.export_email(csv)
  end
end
