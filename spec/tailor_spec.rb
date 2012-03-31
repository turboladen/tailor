require_relative 'spec_helper'
require 'tailor'

describe Tailor do
  describe "::config" do
    it "calls #instance_eval on the block passed to it" do
      Tailor.should_receive(:instance_eval)
      Tailor.config
    end
    
    it "returns a Hash" do
      Tailor.stub(:instance_eval)
      Tailor.stub(:method_missing).and_return {}
      Tailor.config.should be_a Hash
    end
  end
  
  describe "::method_missing" do
    let!(:configuration) do
      c = {}
      c[:file_sets] = {}
      
      c
    end
    
    before do
      Tailor.instance_variable_set(:@configuration, configuration)
    end
    
    context "meth is :formatters" do
      context "*args is empty" do
        it "assigns nil to @configuration[:formatters]" do
          Tailor.method_missing(:formatters)
          Tailor.instance_variable_get(:@configuration).
            should include(formatters: nil)
        end
      end
      
      context "*args is is '1'" do
        it "assigns 1 to @configuration[:formatters]" do
          Tailor.method_missing(:formatters, 1)
          Tailor.instance_variable_get(:@configuration).
            should include(formatters: 1)
        end
      end

      context "*args is is '1, 2'" do
        it "assigns 1 to @configuration[:formatters]" do
          Tailor.method_missing(:formatters, 1, 2)
          Tailor.instance_variable_get(:@configuration).
            should include(formatters: 1)
        end
      end
    end
    
    context "meth is :file_set" do
      before do
        Tailor.stub(:instance_eval)
      end
      
      after do
        Tailor.unstub(:instance_eval)
      end
      
      context "good params" do
        it "calls #instance_eval on the :file_set block" do
          Tailor.should_receive(:instance_eval)
          Tailor.method_missing(:file_set, 'something')
        end
      end
      
      context "the 2nd arg is empty" do
        it "sets @configuration[:file_sets][@label] to :default" do
          Tailor.method_missing(:file_set, 'something')
          Tailor.instance_variable_get(:@configuration).
            should == { file_sets: { default: {
            file_list: 'something', style: {}
          } } }
        end
      end
      
      context "the 2nd arg is :pants" do
        it "sets @configuration[:file_sets][@label] to :pants" do
          Tailor.method_missing(:file_set, 'something', :pants)
          Tailor.instance_variable_get(:@configuration).
            should == { file_sets: { pants: {
            file_list: 'something', style: {}
          } } }
        end
      end
      
      context "the first arg is nil" do
        it "raises, saying ':file_set can't be nil'" do
          expect { Tailor.method_missing(:file_set, nil) }.
            to raise_error(Tailor::RuntimeError, /:file_set can't be nil./)
        end
      end
      
      context "the first arg is not a String" do
        it "raises, saying ':file_set is a X--please provide a String'" do
          expect { Tailor.method_missing(:file_set, []) }.
            to raise_error(Tailor::RuntimeError, /:file_set can't be a\(n\) Array/)
        end
      end
      
      context "the first arg is a String" do
        it "sets @configuration[:file_sets][@label][:file_list] to it" do
          Tailor.method_missing(:file_set, 'something')
          Tailor.instance_variable_get(:@configuration).
            should == { file_sets:
            { default: { file_list: 'something', style: {} } }
          }
        end
      end
    end
    
    context "meth is the same as one of the available style keys" do
      before do
        ok_methods = double "ok_methods"
        ok_methods.stub(:include?).and_return true
        default_config = double "Tailor::Configuration.default"
        default_config.stub_chain(:[], :[], :[], :keys).and_return ok_methods
        Tailor::Configuration.stub(:default).and_return default_config
        
        configuration[:file_sets] = {}
        configuration[:file_sets][:default] = {}
        configuration[:file_sets][:default][:style] = {}
        Tailor.instance_variable_set(:@configuration, configuration)
      end
      
      after do
        Tailor::Configuration.unstub(:default)
      end
      
      context "the first arg is nil" do
        it "sets @configuration[:file_sets][@label][:style] to the key/value pair" do
          Tailor.method_missing(:an_ok_method, nil)
          Tailor.instance_variable_get(:@configuration).
            should == { file_sets:
            { default: { style: { an_ok_method: nil } } }
          }
        end
      end

      context "the first arg has a value" do
        it "sets @configuration[:file_sets][@label][:style] to the key/value pair" do
          Tailor.method_missing(:an_ok_method, 'a value')
          Tailor.instance_variable_get(:@configuration).
            should == { file_sets:
            { default: { style: { an_ok_method: "a value" } } }
          }
        end
      end
    end
  end
end
