require 'rails_helper'

describe EventConsumers::Login do
  describe "#process!" do
    subject{ EventConsumers::Login.new(fake_message) }
    let(:user){ User.create(name: 'John') }
    let(:room){ Room.create(name: 'my room') }
    let(:fake_message){ double('fake message', body: fake_body) }
    let(:fake_body){ {sender: user.name, room: room.name} }

    it "adds user to the room" do
      expect{
        subject.process!
      }.to change{
        user.reload.rooms.include?(room)
      }.from( false ).to( true )
    end
  end
end
