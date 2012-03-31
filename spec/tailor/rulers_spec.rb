require_relative '../spec_helper'
require 'tailor/rulers'

describe Tailor::Rulers do
  it "requires all of its children" do
    # if it does one, it'll have done them all.
    subject.const_get('AllowCamelCaseMethodsRuler').should be_true
  end
end
