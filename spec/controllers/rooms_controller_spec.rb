require 'rails_helper'

describe RoomsController, type: :controller do
  def sign_in(user)
    allow( controller ).to receive(:current_user).and_return(user)
  end

  let(:user){ User.create(name: 'My User') }
  let(:room){ Room.create(name: 'that room') }

  describe "GET #show" do
    context "when user is logged in" do
      before{ sign_in( user ) }

      let(:other_user){ User.create(name: 'other user') }

      it "returns http success" do
        get :show, name: room.name
        expect( response ).to have_http_status(:success)
      end

      it "assigns @other_users" do
        room.users = [user, other_user]
        get :show, name: room.name
        other_users = assigns(:other_users)
        expect( other_users ).to eq [other_user]
      end
    end

    context "when user is not logged in" do
      it "redirects to new session path" do
        get :show, name: room.name
        expect( response ).to redirect_to(new_session_path)
      end
    end
  end


  describe "GET #new" do
    context "when user is logged in" do
      before{ sign_in( user ) }

      it "returns http success" do
        get :new
        expect( response ).to have_http_status(:success)
      end

      it "assigns @room" do
        get :new
        expect( assigns(:room) ).to be_a_new( Room )
      end
    end

    context "when user is not logged in" do
      it "redirects to new session path" do
        get :new
        expect( response ).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST #create" do
    let(:room_name){ 'new room' }

    context "when user is logged in" do
      before{ sign_in( user ) }

      it "redirects to new room" do
        post :create, room: { name: room_name }
        expect( response ).to redirect_to( room_path(room_name) )
      end

      it "creates new room" do
        expect{
          post :create, room: { name: room_name }
        }.to change{
          Room.find_by(name: room_name).nil?
        }.from( true ).to( false )
      end
    end

    context "when user is not logged in" do
      it "redirects to new session path" do
        post :create, room: { name: room_name }
        expect( response ).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #default" do
    context "when user is logged in" do
      before{ sign_in( user ) }

      context "when a room exists" do
        before{ room }

        it "redirects to that room" do
          get :default
          expect( response ).to redirect_to( room_path(room.name) )
        end
      end

      context "when no rooms exist" do
        it "creates a room" do
          expect{
            get :default
          }.to change{
            Room.count
          }.by(1)
        end

        it "redirects to the new room" do
          get :default
          new_room = Room.first
          expect( response ).to redirect_to( room_path(new_room.name) )
        end
      end
    end

    context "when user is not logged in" do
      it "redirects to new session path" do
        get :default
        expect( response ).to redirect_to(new_session_path)
      end
    end
  end
end
