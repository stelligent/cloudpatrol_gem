require 'spec_helper'

describe Cloudpatrol do
  describe ".perform" do
    subject { Cloudpatrol.perform(*params) }

    let(:params) do
      [
        { access_key_id: "", secret_access_key: "", region: region },
        nil,
        :class,
        :method
      ]
    end

    describe "if region is specified" do
      let(:region) { "us-east-1" }

      it "performs only once" do
        expect(Cloudpatrol::Task).to receive(:const_get).once
        subject
      end
    end

    describe "if region is not specified" do
      let(:region) { nil }

      it "performs for every available region" do
        expect(Cloudpatrol::Task).to receive(:const_get).at_least(8).times
        subject
      end
    end
  end
end
