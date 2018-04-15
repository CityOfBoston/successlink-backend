class ImportPositionsJob < ApplicationJob
  include IcimsQueryable
  include Geocodable
  queue_as :default

  def perform(icims_id)
    job = icims_get(object: 'jobs', id: icims_id, fields: 'overview,responsibilities,qualifications,positiontype,numberofpositions,jobtitle,joblocation,field51224,recruiter')

    unless job['joblocation'].nil?
      job_address = get_address_from_icims(job['joblocation']['address'])
      job_manager = get_manager_from_icims(job['recruiter']['profile'])

      puts job_address.to_yaml

      position = Position.new(icims_id: icims_id,
                              title: job['jobtitle'],
                              category: job['field51224'],
                              duties_responsbilities: job['responsibilities'],
                              ideal_candidate: job['qualifications'],
                              address: job_address['addressstreet1'],
                              neighborhood: job_address['addresscity'],
                              site_name: job['joblocation']['value'],
                              location: job_address['addressstreet1'].nil? ? '' : geocode_address(street_address: job_address['addressstreet1']),
                              open_positions: job['numberofpositions'])

      unless job_manager.nil?
        position.primary_contact_person = "#{job_manager['firstname']} #{job_manager['lastname']}"
        position.primary_contact_person_email = "#{job_manager['email']}"
      end

      if job_address['addressstreet1'].nil?
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

    JSON.parse(response.body)
  end

  def get_manager_from_icims(address_url)
    response = Faraday.get(address_url,
                           {},
                           authorization: "Basic #{Rails.application.secrets.icims_authorization_key}")

    JSON.parse(response.body)
  end
end
