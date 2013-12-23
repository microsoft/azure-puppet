shared_examples "validate authentication credential" do |service_object|
  describe '(management_certificate)' do
    it 'should require a management_certificate' do
      @options.delete(:management_certificate)
      expect { subject.send(service_object, @options) }.to raise_error ArgumentError, /required: management_certificate/
    end

    it 'management_certificate doesn\'t  exist' do
      @options[:management_certificate] = 'FileNotExist'
      expect { subject.send(service_object, @options) }.to raise_error ArgumentError, /Could not find file 'FileNotExist'/
    end

    it 'management_certificate extension is not valid' do
      @options[:management_certificate] = File.expand_path('spec/fixtures/invalid_file.txt')
      expect { subject.send(service_object, @options) }.to raise_error RuntimeError, /Management certificate expects a .pem or .pfx file/
    end
  end

  describe '(azure_subscription_id)' do
    it 'should require a azure_subscription_id' do
      @options.delete(:azure_subscription_id)
      expect {subject.send(service_object, @options) }.to raise_error ArgumentError, /required: azure_subscription_id/
    end
  end

end
