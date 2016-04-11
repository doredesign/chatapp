require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user){ User.create(name: 'John Smith') }

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "when a return URL is specified" do
      let(:return_to){ new_session_path }

      it "creates a session for the user" do
        expect{
          post :create, name: user.name, return_to: return_to
        }.to change{ session[:user_id] }.from(nil).to(user.id)
      end

      it "redirects to the specifid URL" do
        post :create, name: user.name, return_to: return_to
        expect(response).to redirect_to(return_to)
      end
    end

    context "when a return URL is not specified" do
      it "creates a session for the user" do
        expect{
          post :create, name: user.name
        }.to change{ session[:user_id] }.from(nil).to(user.id)
      end

      it "redirects to the root path" do
        post :create, name: user.name
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user does not exist" do
      let(:new_user_name){ 'Jiminy Cricket' }

      it "creates the user" do
        expect{
          post :create, name: new_user_name
        }.to change{ User.count }.from(0).to(1)
      end

      it "creats a session for the new user" do
        expect( controller.current_user ).to be_nil
        post :create, name: new_user_name
        expect( controller.current_user.name ).to eq(new_user_name)
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes session of current user" do
      session[:user_id] = user.id
      delete :destroy
      expect( session[:user_id] ).to be_nil
    end

    it "redirects to the root path" do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end
  end
end
