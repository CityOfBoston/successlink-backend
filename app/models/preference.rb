require 'csv'

class Preference < ApplicationRecord
  belongs_to :applicant
  belongs_to :position

  def self.generate_csv
    CSV.generate do |csv|
      csv << ['applicant','position','travel time scrore']
      Preference.all.each do |p|
        csv << [p.applicant.icims_id, p.position.icims_id, p.travel_time_score]
      end
    end
  end
end
