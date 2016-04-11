require 'rails_helper'

describe MessagesController, type: :controller do
  let(:user){ User.create(name: 'My User') }

  describe "GET #index" do
    context "when user is logged in" do
      before{ controller.stub(:current_user).and_return(user) }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not logged in" do
      it "redirects to new session path" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
