require 'rails_helper'

describe EventConsumers::Logout do
  describe "#process!" do
    subject{ EventConsumers::Logout.new(fake_message) }
    let(:user){ User.create(name: 'John') }
    let(:room){ Room.create(name: 'my room') }
    let(:fake_message){ double('fake message', body: fake_body) }
    let(:fake_body){ double('fake body', sender: user.name, room: room.name) }

    before do
      user.rooms = [room]
    end

    it "removes user from all rooms" do
      expect{
        subject.process!
      }.to change{
        user.reload.rooms.include?(room)
      }.from( true ).to( false )
    end
  end
end
