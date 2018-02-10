require "spec_helper"

RSpec.describe Hashiform do
  let(:hashiform) { Hashiform.new(hash) }
  let(:result) { hashiform.transform(transformation) }
  let(:hash) { { 'a' => 1, 'b' => 2 } }

  describe '#transform' do
    context 'basic transform' do
      let(:transformation) {
        {
          'id'    => 'a',
          'count' => 'b'
        }
      }

      it 'transforms a basic hash' do
        expect(result).to eq({
          'id'    => 1,
          'count' => 2
        })
      end
    end

    context 'deep transform' do
      let(:hash) {
        {
          'a' => { 'b' => 2 },
          'c' => { 'd' => { 'e' => 1 } },
        }
      }

      let(:transformation) {
        {
          'id' => 'c.d.e',
          'count' => 'a.b'
        }
      }

      it 'will dig through a hash' do
        expect(result).to eq({
          'id' => 1,
          'count' => 2
        })
      end
    end

    context 'if modifier' do
      let(:transformation) {
        {
          'id'    => 'a',
          'count' => 'b',
          'post'  => 'if:c'
        }
      }

      context 'When the value is absent' do
        it 'will exclude the key' do
          expect(result).to eq({
            'id'    => 1,
            'count' => 2
          })
        end
      end

      context 'When the value is present' do
        let(:hash) { { 'a' => 1, 'b' => 2, 'c' => 'foo' } }

        it 'will include the key' do
          expect(result).to eq({
            'id'    => 1,
            'count' => 2,
            'post'  => 'foo'
          })
        end
      end
    end

    context 'to_s mod' do
      let(:transformation) {
        {
          'id'    => 'to_s:a',
          'count' => 'b'
        }
      }

      it 'will exclude the key' do
        expect(result).to eq({
          'id'    => '1',
          'count' => 2
        })
      end
    end

    context 'any method chain really' do
      let(:transformation) {
        {
          'name' => 'capitalize:reverse:a',
          'job'  => 'upcase:b'
        }
      }

      let(:hash) { { 'a' => 'foo', 'b' => 'bar' } }

      it 'will apply silly transformations' do
        expect(result).to eq({
          "job"  => "BAR",
          "name" => "ooF"
        })
      end
    end

    context 'Heck, it even does join if you ask nice' do
      let(:hash) { { 'a' => [1, 2, 3] } }
      let(:transformation) { { 'a' => 'join+, :a'} }

      it 'does binary' do
        expect(result).to eq({ 'a' => '1, 2, 3'})
      end
    end

    context 'it even gives you catalysts for extra fun' do
      let(:people) {
        {
          'Bob' => 25,
          'Jane' => 26
        }
      }

      let(:hashiform) {
        Hashiform.new(hash, {
          'interpolate_person' => -> v { people[v] }
        })
      }

      let(:hash) {
        {
          'father' => 'bob',
          'mother' => 'jane'
        }
      }

      let(:transformation) {
        {
          'Father age' => 'capitalize:interpolate_person:father',
          'Mother age' => 'capitalize:interpolate_person:mother'
        }
      }

      it 'will do some funky stuff' do
        expect(result).to eq({
          "Father age" => 25,
          "Mother age" => 26,
        })
      end
    end
  end
end
