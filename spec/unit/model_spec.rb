require './spec/unit/unit_spec_helper'

describe 'Example' do
  before do 
    class Example
      include Arsenal 
      id :identifier
      
      def identifier
        $identifier_number ||= 0
        $identifier_number += 1
      end
    end 
  end
  after { Object.send(:remove_const, :Example) }

  context 'class' do

    subject { Example } 

    it { should respond_to :id }
    it { should respond_to :attribute } 

    describe '#id' do
      subject { Example.attributes[:id] } 

      after { Object.send(:remove_const, :ErrorExample) rescue nil } 

      it { should_not be_nil } 
      it { should be_required }
      it { should_not have_default } 

      it 'causes an error when instantiating if it is not provided' do
        expect { 
          class ErrorExample
            include Arsenal
          end
          ErrorExample.new
        }.to raise_error Arsenal::IdentifierNotGivenError
      end
    end

    describe '#attribute' do
      before do
        class Example
          attribute :foo, 
            default: :default_thing

          attribute :bar

          attribute :req1, :required => true
          attribute :req2, :required => false

          attribute :proc_calls_self, :required => proc { |t| t.test_message }

          attribute :proc1, :required => proc { |t| true  }
          attribute :proc2, :required => proc { |t| false }

          def foo
            :thing 
          end

          def bar ; end
        end
      end

      subject { Example.new } 

      it "optionally takes a default value, which is used by the nil-model to populate it's #attributes" do
        subject.foo.should == :thing
        nil_example.foo.should == :default_thing
      end

      it 'assumes that if no default is provided, the default is nil' do
        subject.bar.should be_nil
      end

      describe ':required' do
        context 'as a proc' do
          it 'calls the proc with an instance of the class as the context.' do
            subject.should_receive :test_message
            Example.attributes[:proc_calls_self].required?(subject)
          end

          it 'is required if the proc returns true' do
            Example.attributes[:proc1].required?(subject).should be_true
          end

          it 'is not required if the proc returns false' do
            Example.attributes[:proc2].required?(subject).should be_false
          end
        end

        context 'as a boolean' do
          it 'is required if required is set' do
            Example.attributes[:req1].should be_required
          end

          it 'is not required if required is unset' do
            Example.attributes[:req2].should_not be_required
          end
        end
      end
    end
  end

  context 'instance' do
    before do
      class Example


        attribute :flibble, :driver => :some_driver
        attribute :flobble, :driver => :some_driver
        attribute :weeble, :driver => :some_other_driver
      end
    end

    let(:example) { Example.new }
    subject { example } 

    it { should respond_to :persisted? }
    it { should_not be_persisted }

    it { should respond_to :savable? }
    it { should be_savable } 

    it { should respond_to :collection? } 
    it { should_not be_a_collection } 

    it { should respond_to :attributes } 
    it { should respond_to :id }

    it { should respond_to :nil? }
    it { should_not be_nil } 

    it { should respond_to :drivers } 
    it { should respond_to :attributes_for } 
    
    describe '#drivers' do
      subject { example.drivers } 

      it { should_not be_nil } 
      it { should respond_to :each } 
      it { should be_an Enumerable } 

      it { should =~ [:some_driver, :some_other_driver] } 

      it 'does not contain nils' do
        subject.all? { |e| e.should_not be_nil } 
      end
    end

    describe "#attributes" do
      before do 
        class Example
          attribute :foo
        end
      end

      subject    { example.attributes   }
      its(:keys) { should include(:id)  }
      its(:keys) { should include(:foo) }
      its(:keys) { should =~ Example.attributes.keys }
    end

    describe '#attributes_for' do
      subject { example.attributes_for(:some_driver) } 
      its(:keys) { should =~ [:id, :flibble, :flobble] } 
    end
  end

  context 'building a new example from a hash of attributes' do
    before do
      class Example
        attribute :foo
        attribute :bar

        def build(attrs)
          @foo = attrs[:foo]
          @bar = "this is #{attrs[:bar]}"
        end

        attr_reader :foo, :bar
      end
    end

    subject { Example } 

    it '.new should take at least one parameter, the hash of attributes' do
      expect { subject.new(foo: 1, bar: 2) }.to_not raise_error ArgumentError
    end

    it 'otherwise leaves the implementation up to the user' do
      obj = subject.new(foo: 1, bar: 2)
      obj.foo.should == 1
      obj.bar.should == "this is 2"
    end
  end

end

