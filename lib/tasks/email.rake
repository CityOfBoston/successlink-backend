namespace :email do
  desc "Outputs applicant emails"
  task applicant_emails: :environment do
    applicants = Applicant.where(user: nil)
    puts applicants.count

    puts User.all.count
    puts Applicant.all.count

    applicants.each do |applicant|
      puts applicant.email
    end
  end

  desc "Email applicants the job picker"
  task applicant_job_picker_short: :environment do
    Applicant.all.each do |applicant|
      next if applicant.user.blank?
      
      puts "#{applicant.id} sent to #{applicant.user.email}"
      ApplicantMailer.job_picker_email(applicant.user).deliver_now
    end
  end

  desc "Email applicants the job picker"
  task applicant_job_picker: :environment do
    Applicant.where(user: nil).each do |applicant|
      next if applicant.email.blank?
      user = User.create(email: applicant.email.downcase,
                         password: Devise.friendly_token.first(8),
                         applicant: applicant)
      if user.valid?
        ApplicantMailer.job_picker_email(user).deliver_now
        puts "Applicant email to #{applicant.email.downcase} sent"
        update_icims_status_to_candidate_employment_selection(applicant)
      else
        puts 'APPLICANT USER ACCOUNT CREATION ERROR Failed for: ' + applicant.id
      end
    end
  end

  desc "Get auth token"
  task get_auth: :environment do
    u = User.find(75)

    unless u.nil?
      puts u.email
      puts u.authentication_token
    else
      puts "Email not found"
    end
  end

  desc 'Create user accounts for CBOs'
  task create_cbo_accounts: :environment do
    csv_text = File.read(Rails.root.join('lib', 'import', 'partner-emails.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each_with_index do |row|
      positions = Position.where(site_name: row['Organization Name'])
      user = User.create(email: row['Primary Contact Email'],
                         password: Devise.friendly_token.first(8),
                         positions: positions,
                         account_type: 'partner')
      puts row['Primary Contact Email'] if user.blank?
      next if user.blank?
      CboUserMailer.cbo_user_email(user).deliver_now
    end
  end

  desc 'Email a user their job offer'
  task email_lottery_job_offer: :environment do
    Applicant.chosen.each do |applicant|
      JobOfferMailer.job_offer_email(applicant.user).deliver_later
    end
  end

  desc 'Update user account email addresses'
  task update_user_emails: :environment do
    Applicant.all.each do |applicant|
      applicant.user.update(email: applicant.email)
    end
  end

  private

  def update_icims_status_to_candidate_employment_selection(applicant)
    response = Faraday.patch do |req|
      req.url 'https://api.icims.com/customers/6405/applicantworkflows/' + applicant.workflow_id.to_s
      req.body = %Q{ {"status":{"id":"C51218"}} }
      req.headers['authorization'] = "Basic #{Rails.application.secrets.icims_authorization_key}"
      req.headers["content-type"] = 'application/json'
    end
    unless response.success?
      Rails.logger.error 'ICIMS Update Status to Candidate Employment Selection Failed for: ' + applicant.id
    end
  end
end
