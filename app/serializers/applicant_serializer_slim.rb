class ApplicantSerializerSlim < ActiveModel::Serializer
  attributes  :icims_id, :interests, :prefers_nearby,
              :has_transit_pass, :grid_id, :latitude, :longitude, :lottery_number, :in_school, :school_type,
              :bps_student, :current_grade_level, :english_first_language, :first_language,
              :fluent_other_language, :other_languages, :held_successlink_job_before, :previous_job_site,
              :wants_to_return_to_previous_job, :superteen_participant, :neighborhood

  def latitude
    object.location.try(:y)
  end

  def longitude
    object.location.try(:x)
  end

  def site_name
    object.try(:site_name)
  end
end
