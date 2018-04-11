class ImportPositionsJob < ApplicationJob
  include IcimsQueryable
  include Geocodable
  queue_as :default

  def perform(icims_id)
    job = icims_get(object: 'jobs', id: icims_id, fields: 'overview,responsibilities,qualifications,positiontype,numberofpositions,jobtitle,joblocation,field51224')
    puts job['joblocation'].to_yaml

    unless job['joblocation'].nil?
      job_address = get_address_from_icims(job['joblocation']['address'])

      position = Position.new(icims_id: icims_id,
                              title: job['jobtitle'],
                              category: job['field51224'],
                              duties_responsbilities: job['responsibilities'],
                              address: job_address['addressstreet1'],
                              site_name: job['joblocation']['value'],
                              location: job_address['addressstreet1'].nil? ? '' : geocode_address(street_address: job_address['addressstreet1']),
                              open_positions: job['numberofpositions'])

      if job_address['addressstreet1'].nil?
        puts job_address.to_yaml
        puts "#{icims_id} missing street address"
      end
        
      position.save!
    else
      puts "#{icims_id} missing location"
    end
  end

  private

  def get_address_from_icims(address_url)
    response = Faraday.get(address_url,
                           {},
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")

    puts "Getting address"
    puts "---------"
    puts response.to_yaml
    puts "---------"
    JSON.parse(response.body)
  end
end
