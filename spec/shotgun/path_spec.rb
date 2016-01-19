module Shotgun
  describe Path do
    let(:parts) { ('a'..'z').to_a.sample(rand(1..3)).collect(&:to_sym) }

    subject(:path) { Path.new(*parts) }

    it { should respond_to(:parts) }

    it { should respond_to(:to_url) }

    it { should respond_to(:to_s) }

    specify { expect(path.to_url).to eq path.to_s }

    describe 'return value of #parts' do
      subject { path.parts }

      it { should be_a Array }

      it { should_not be_empty }

      it { should eq parts }
    end

    describe 'return value of #to_url' do
      subject { path.to_url }

      it { should be_a String }

      it { should_not be_empty }

      it { should include *parts.collect(&:to_s) }

      it { should match /^#{parts.join('.')}/ }

      it { should include Shotgun.zone }

      specify { expect(subject).to eq (parts + [Shotgun.zone]).join('.').downcase }
    end


  end
end
