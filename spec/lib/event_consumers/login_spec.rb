require 'rails_helper'

describe EventConsumers::Login do
  describe "#process!" do
    subject{ EventConsumers::Login.new(fake_message) }
    let(:original_users){ %w[Jane John Rumpelstiltskin] }
    let(:new_user){ 'Jimminey Cricket' }
    let(:new_users){ original_users + [new_user] }
    let(:fake_message){ double('fake message', body: new_user) }

    before do
      allow( subject ).to receive(:fetch_users).and_return( original_users )
      allow( subject ).to receive(:reply)
      allow( subject ).to receive(:update_users!)
      allow( subject ).to receive(:publish_new_user)
    end

    it "replies with all users other than the new one" do
      expect( subject ).to receive(:reply).with(users: original_users)
      subject.process!
    end

    it "updates users to include new one" do
      expect( subject ).to receive(:update_users!).with( new_users )
      subject.process!
    end

    it "publishes new user" do
      expect( subject ).to receive(:publish_new_user).with(new_user)
      subject.process!
    end
  end
end
