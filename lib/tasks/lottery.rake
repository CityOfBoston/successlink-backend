namespace :lottery do
  desc 'Build the preference lists'
  task build_preference_lists: :environment do
    start_time = Time.now
    Applicant.chosen(1).each do |applicant|
      Position.all.each do |position|
        score = travel_time_score(applicant, position) + interest_score(applicant, position)
        Preference.create(applicant: applicant, position: position, score: score)
      end
    end
    puts "Time to run in seconds: #{Time.now - start_time}"
  end

  desc 'Assign lottery numbers'
  task assign_lottery_numbers: :environment do
    Applicant.order("RANDOM()").each_with_index do |applicant, index|
      applicant.lottery_number = index
      applicant.save!
    end
  end

  desc 'Match the applicants to their jobs'
  task match: :environment do
    match_applicants_to_positions
  end

  desc 'Print match results'
  task print: :environment do
    Applicant.chosen(1).each do |applicant|
      puts "Applicant: #{applicant.email} Position: #{applicant.offer.last.position.id} #{applicant.offer.last.position.title}"
    end
  end

  private

  def travel_time_score(applicant, position)
    minutes = travel_time(applicant, position) / 60
    applicant.prefers_nearby? ? care(minutes) : dont_care(minutes)
  end

  def travel_time(applicant, position)
    return TravelTime.find_by(
      input_id:     applicant.grid_id,
      target_id:    position.grid_id,
      travel_mode:  applicant.has_transit_pass ? "transit" : "walking"
    ).time
  rescue NoMethodError
    40.minutes.to_i
  end

  def care(minutes)
    minutes < 30 ? (0.008 * (minutes ** 2)) - (0.5833 * minutes) + 5 : -5
  end

  def dont_care(minutes)
    minutes < 40 ? (-0.25 * minutes) + 5 : -5
  end

  def interest_score(applicant, position)
    magnitude = applicant.prefers_interest? ? 5 : 3
    matches = (applicant.interests & [position.category]).any? ? 1 : -1
    return magnitude * matches
  end

  def match_applicants_to_positions
    chosen_applicant_pool = Applicant.chosen.pluck(:id)
    last_lottery_number = Applicant.chosen.last.lottery_number
    chosen_applicant_pool.each do |applicant_id|
      if Applicant.find(applicant_id).pickers.any?
        chosen_applicant_pool.delete(applicant_id)
        last_lottery_number += 1
        break if Applicant.find_by(lottery_number: last_lottery_number).blank?
        chosen_applicant_pool.push(Applicant.find_by(lottery_number: last_lottery_number).id)
      end
    end

    chosen_applicants = Applicant.find(chosen_applicant_pool)

    chosen_applicants.each do |applicant|
      applicant.match_to_position
    end
    return if Applicant.includes(:offer).where(id: chosen_applicants.map(&:id)).where( :offers => { :applicant_id => nil }).empty? # this isn't working right
    if Position.joins("LEFT OUTER JOIN offers ON offers.position_id = positions.id").where("offers.id IS null").any?
      match_applicants_to_positions
    end
  end
end
