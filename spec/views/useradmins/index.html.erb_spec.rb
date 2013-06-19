require 'spec_helper'

describe "useradmins/index" do
  before(:each) do
    assign(:useradmins, [
      stub_model(Useradmin),
      stub_model(Useradmin)
    ])
  end

  it "renders a list of useradmins" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
