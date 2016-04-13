require 'rails_helper'

describe VertxConsumerBase do
  class EventConsumers::TestSubClass < VertxConsumerBase
    def process!; end
  end

  let(:fake_message){ double('message', body: '') }

  describe ".register!" do
    let(:fake_event_bus){ double('event bus') }

    before do
      allow( EventConsumers::TestSubClass ).to receive(:event_bus).and_return( fake_event_bus )
      allow( fake_event_bus ).to receive(:consumer).and_yield( fake_message )
    end

    it "registers consumer with the name of its class" do
      expect( fake_event_bus ).to receive(:consumer).with( EventConsumers::TestSubClass.demodulized_class_name.downcase )
      EventConsumers::TestSubClass.register!
    end

    it "passes event message to an instance of itself" do
      expect( fake_event_bus ).to receive(:consumer)
      expect( EventConsumers::TestSubClass ).to receive(:new).with( fake_message ).and_call_original
      EventConsumers::TestSubClass.register!
    end

    it "processes consumed message with an instance of itself" do
      fake_consumer = instance_double('EventConsumers::TestSubClass')
      expect( fake_consumer ).to receive(:process!)
      allow( EventConsumers::TestSubClass ).to receive(:new).and_return( fake_consumer )
      EventConsumers::TestSubClass.register!
    end
  end

  describe "#process!" do
    it "raises a warning message when not defined" do
      expect{ VertxConsumerBase.new(fake_message).process! }.to raise_error( VertxConsumerBase::IncompleteSubclass )
    end
  end

  describe ".demodulized_class_name" do
    it "returns the name of the class" do
      expect( EventConsumers::TestSubClass.demodulized_class_name ).to eq "TestSubClass"
    end
  end
end
