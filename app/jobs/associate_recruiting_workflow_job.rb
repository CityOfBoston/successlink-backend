class AssociateRecruitingWorkflowJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Pick.all.each do |pick|
      sleep 1

      applicant = Applicant.find(pick.applicant_id)

      unless applicant.nil?
        position  = Position.find(pick.position_id)

        unless position.nil?
          associate_applicant_with_position(applicant, position)
          update_applicant_to_selected(applicant)
        else
          Rails.logger.error("#{pick.position_id} position not found")
        end
      else
        Rails.logger.error("#{pick.applicant_id} applicant not found")
      end
    end
  end

  private

  def associate_applicant_with_position(applicant, position)
    Rails.logger.info "Associate applicant iCIMS ID #{applicant.icims_id} with position: #{applicant.id}"
    response = Faraday.post do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows"
      req.body = %Q{ {"baseprofile":#{position.icims_id},"status":{"id":"C2028"},"associatedprofile":#{applicant.icims_id}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 30
    end
    unless response.success?
      Rails.logger.error 'ICIMS Associate Applicant with Position Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end

  def update_applicant_to_selected(applicant)
    Rails.logger.info "Updating Applicant iCIMS ID #{applicant.icims_id} to selected: #{applicant.id}"
    response = Faraday.patch do |req|
      req.url "https://api.icims.com/customers/#{Rails.application.secrets.icims_customer_id}/applicantworkflows/" + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C2028"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Selected by Site Failed for: ' + applicant.id.to_s
      Rails.logger.error 'Status: ' + response.status.to_s + ' Body: ' + response.body
    end
  end
end
