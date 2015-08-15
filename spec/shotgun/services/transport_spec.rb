# This spec class uses the Etcd HTTP API as its own Micro-service to test
# the Transport class. Bit confusing, but I'm sure you get the picture

class Services < Shotgun::Services
end

describe Services do

  let(:klass) { Services::Etcd }

  let(:call) { :upgrade }

  let(:path) { 'etcd' }

  subject { klass.new(:v2, :keys).send(call) }

  it { should be_an_instance_of Services::Transport }

  describe 'return value of #url' do

    describe 'with environment variable' do

      specify { expect(subject.url).to_not be_empty }

      specify { expect(subject.url).to eq "http://#{ENV['SERVICE_ETCD_URL']}" }

    end

    describe 'without environment variable' do

      let(:url) { ENV['SERVICE_ETCD_URL'] }

      let(:zone) { "stockflare.com" }

      before { Shotgun.zone = zone }

      before { ENV['SERVICE_ETCD_URL'] = nil }

      specify { expect(subject.url).to_not be_empty }

      specify { expect(subject.url).to eq "http://#{path}.#{zone}" }

      after { ENV['SERVICE_ETCD_URL'] = url }

    end

  end

  describe 'when a path is not found (404 from etcd)' do

    subject { klass.new(:does, :not, :exist) }

    let(:value) { Faker::Internet.ip_v4_address }

    specify { expect { subject.update({ value: value }).response }.to raise_error(Shotgun::Services::Errors::HttpError) }

    specify { expect { subject.update({ value: value }).response }.to raise_error { |ex| expect(ex.code).to eq 404 } }

    specify { expect { subject.update({ value: value }).response }.to raise_error { |ex| expect(ex.response).to be_an_instance_of Shotgun::Services::Response } }

    specify { expect { subject.update({ value: value }).response }.to raise_error(/404/) }

  end

  describe 'using transport to set a new etcd key' do

    let(:key) { Faker::Internet.domain_word }

    subject { klass.new(:v2, :keys, key) }

    let(:value) { Faker::Internet.ip_v4_address }

    before { subject.update({ value: value }, { headers: { 'X-Test' => 'some-test-value' } }).response }

    specify { expect(klass.new(:v2, :keys, key).get(recursive: true).response.body.node.value).to eq value }

    specify { expect(klass.new(:v2, :keys, key).get.response.headers['Content-Type']).to include "json" }

  end

end
