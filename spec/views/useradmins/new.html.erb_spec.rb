require 'spec_helper'

describe "useradmins/new" do
  before(:each) do
    assign(:useradmin, stub_model(Useradmin).as_new_record)
  end

  it "renders new useradmin form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => useradmins_path, :method => "post" do
    end
  end
end
