require 'spec_helper'

describe "useradmins/edit" do
  before(:each) do
    @useradmin = assign(:useradmin, stub_model(Useradmin))
  end

  it "renders the edit useradmin form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => useradmins_path(@useradmin), :method => "post" do
    end
  end
end
