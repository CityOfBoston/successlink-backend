require 'rails_helper'

RSpec.describe "partners/index", type: :view do
  before(:each) do
    assign(:partners, [
      Partner.create!(),
      Partner.create!()
    ])
  end

  it "renders a list of partners" do
    render
  end
end
