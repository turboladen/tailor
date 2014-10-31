require 'spec_helper'
require 'tailor/rulers'

describe Tailor::Rulers do
  it 'requires all of its children' do
    # if it does one, it'll have done them all.
    expect(subject.const_get('AllowCamelCaseMethodsRuler')).to be_truthy
  end
end
