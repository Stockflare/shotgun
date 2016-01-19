module Shotgun
  class Services
    describe "a response" do

      let(:test) { {
        a: 1,
        b: { c: true }
      } }

      let(:response) { Hashie::Mash.new test }

      subject { response }

      it { should respond_to(:a) }

      it { should respond_to(:b) }

      specify { expect(subject.a).to eq 1 }

      specify { expect(subject.b.c).to be_truthy }

      describe 'a nested array response' do

        let(:array) { { stacks: [test] * 4 } }

        let(:array_response) { Hashie::Mash.new array }

        subject { array_response }

        it { should respond_to(:each) }

        specify { expect(subject.stacks.first.a).to eq 1 }

        specify { expect(subject.stacks.first.b.c).to be_truthy }

      end

      describe 'a deep nested array response' do

        let(:array) { { posts: [{ title: "foobar!", tags: ['business', { fruit: 'apple' }] }] } }

        let(:array_response) { Hashie::Mash.new array }

        subject { array_response }

        specify { expect(subject.posts.first.tags.first).to eq 'business' }

        specify { expect(subject.posts.first.tags.last.fruit).to eq 'apple' }

      end

      describe 'an array of hashes' do

        let(:array) { [{ id: 1, tags: ["a", "b"] }, { id: 2, tags: ["c", "d"] }] }

        let(:array_response) { { array: array } }

        specify { expect { Hashie::Mash.new array_response }.to_not raise_error }

        specify { expect { array.collect { |arr| Hashie::Mash.new arr } }.to_not raise_error }

      end

      describe 'an array of strings' do

        let(:indices_response) { { indices: ('a'..'z').to_a } }

        subject { Hashie::Mash.new indices_response }

        specify { expect(subject.indices.first).to eq 'a' }

        specify { expect(subject.indices.last).to eq 'z' }

      end

    end
  end
end
