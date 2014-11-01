require 'spec_helper'
require 'tailor/composite_observable'

# Class to use for tests.
class Tester
  include Tailor::CompositeObservable
end

describe Tailor::CompositeObservable do
  subject { Tester.new }

  describe '.define_observer' do
    context "observer = 'pants'" do
      before { Tailor::CompositeObservable.define_observer 'pants' }

      context 'observer responds to #pants_update' do
        it "defines an instance method 'add_pants_observer' that takes 1 arg" do
          observer = double 'Observer', respond_to?: true
          subject.add_pants_observer(observer)
        end
      end

      context 'observer does not respond to #pants_update' do
        it "defines an instance method 'add_pants_observer' that takes 1 arg" do
          observer = double 'Observer', respond_to?: false
          expect { subject.add_pants_observer(observer) }.
            to raise_error NoMethodError
        end
      end

      it 'defines an instance method #notify_pants_observers' do
        expect { subject.notify_pants_observers }.
          to_not raise_error
      end

      it 'defines an instance method #pants_changed' do
        expect { subject.pants_changed }.to_not raise_error
      end
    end
  end
end
