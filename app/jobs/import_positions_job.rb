class ImportPositionsJob < ApplicationJob
  include IcimsQueryable
  include Geocodable
  queue_as :default

  def perform(icims_id)
    puts "****** START #{icims_id} ******"

    job = icims_get(object: 'jobs', id: icims_id, fields: 'overview,responsibilities,qualifications,positiontype,numberofpositions,jobtitle,joblocation,field51224,recruiter')

    unless job['joblocation'].nil?
      job_address = get_address_from_icims(job['joblocation']['address'])
      job_manager = get_manager_from_icims(job['recruiter']['profile'])

      position = Position.find_or_initialize_by(icims_id: icims_id)

      if position.new_record?
        puts "Creating position #{icims_id}"
      else
        puts "Found position #{icims_id}"
      end

      puts "Start adding attributes to position #{icims_id}"

      position.title = job['jobtitle']
      position.category = job['field51224']
      position.duties_responsbilities = job['responsibilities']
      position.ideal_candidate = job['qualifications']
      position.address = job_address['addressstreet1']
      position.neighborhood = job_address['addresscity']
      position.site_name = job['joblocation']['value']
      position.location = job_address['addressstreet1'].nil? ? '' : geocode_address(street_address: job_address['addressstreet1'])
      position.open_positions = job['numberofpositions']

      unless job_manager.nil?
        puts "Adding manager to position #{icims_id}"

        position.primary_contact_person = "#{job_manager['firstname']} #{job_manager['lastname']}"
        position.primary_contact_person_email = "#{job_manager['email']}"
      end

      if job_address['addressstreet1'].nil?
        puts "#{icims_id} missing street address"
      end
        
      if position.save!
        puts "Saved position #{icims_id}"
      end
    else
      puts "#{icims_id} missing location"
    end

    puts "****** END #{icims_id} ******"
    puts ""
    puts ""
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
