require 'rails_helper'

RSpec.describe "partners/show", type: :view do
  before(:each) do
    @partner = assign(:partner, Partner.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
