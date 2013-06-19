require 'spec_helper'

describe "useradmins/show" do
  before(:each) do
    @useradmin = assign(:useradmin, stub_model(Useradmin))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
