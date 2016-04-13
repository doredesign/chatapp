require 'rails_helper'

describe EventConsumers::Logout do
  describe "#process!" do
    subject{ EventConsumers::Logout.new(fake_message) }
    let(:original_users){ %w[Jane John Rumpelstiltskin] }
    let(:logged_out_user){ 'John' }
    let(:logged_out_users){ original_users - [logged_out_user] }
    let(:fake_message){ double('fake message', body: logged_out_user) }

    before do
      allow( subject ).to receive(:fetch_users).and_return( original_users )
      allow( subject ).to receive(:update_users!)
    end

    it "updates users to exlude new one" do
      expect( subject ).to receive(:update_users!).with( logged_out_users )
      subject.process!
    end
  end
end
