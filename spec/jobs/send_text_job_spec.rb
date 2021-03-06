require 'rails_helper'

RSpec.describe SendTextJob, type: :job do
  subject(:job) { SendTextJob.perform_later(['2034446482'], 'Test Message') }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(SendTextJob)
      .with(['2034446482'], 'Test Message')
      .on_queue("default")
  end

  it 'sends a text message' do
    expect(SendTextJob.perform_now(['2034446482'], 'Test Message').status).to eq('queued')
  end
end
