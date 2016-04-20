require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
    def index
      render nothing: true
    end
  end

  let(:user){ User.create(name: 'My User') }

  describe "#current_user" do
    context "when user is logged in" do
      before{ controller.session[:user_id] = user.id }
      it "returns current user" do
        get :index
        expect( controller.current_user ).to eq( user )
      end
    end

    context "when user is not logged in" do
      it "returns nil" do
        get :index
        expect( controller.current_user ).to be_nil
      end
    end
  end

  describe "#all_rooms" do
    it "returns all rooms" do
      rooms = [
        Room.create(name: 'first'),
        Room.create(name: 'second')
      ]

      expect( controller.all_rooms ).to eq rooms
    end
  end
end
