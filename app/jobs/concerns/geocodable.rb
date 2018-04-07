module Geocodable
  extend ActiveSupport::Concern

  private

  def geocode_address(street_address:, locality: 'Boston', region: 'MA')
    street_address.gsub!(/\s#\d+/i, '')
    address = URI.encode("#{street_address} Boston MA")
    response = Faraday.get("https://api.mapbox.com/geocoding/v5/mapbox.places/#{address}.json", { access_token: Rails.application.secrets.mapbox_api_key})
    
    raise ResponseError, "MapBox Geocoder Error #{response.status}: #{response.body}" unless response.success?
    raise NoFeaturesFoundError if JSON.parse(response.body)['features'].blank?
    coordinates = JSON.parse(response.body)['features'][0]['geometry']['coordinates']
    return 'POINT(' + coordinates[0].to_s + ' ' + coordinates[1].to_s + ')'
  end

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods
    # def tag_limit(value)
    #   self.tag_limit_value = value
    # end
  end
end
