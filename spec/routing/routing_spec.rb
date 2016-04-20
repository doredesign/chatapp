require 'rails_helper'

describe 'Routing' do
  it "routes root to messages#index" do
    expect(:get => "/").to route_to(
      :controller => "rooms",
      :action => "default"
    )
  end
end
