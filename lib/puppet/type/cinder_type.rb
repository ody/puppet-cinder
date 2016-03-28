Puppet::Type.newtype(:cinder_type) do

  desc 'Type for managing cinder types.'

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newproperty(:properties, :array_matching => :all) do
    desc 'The properties of the cinder type. Should be an array, all items should match pattern <key=value1[,value2 ...]>'
    def insync?(is)
      return false unless is.is_a? Array
      is.sort == should.sort
    end
    validate do |value|
      raise ArgumentError, "Properties doesn't match" unless value.match(/^\s*[^=\s]+=[^=\s]+$/)
    end
  end

  autorequire(:service) do
    'cinder-api'
  end

  autorequire(:keystone_endpoint) do
    rv = []
    endpoints = catalog.resources.find do |r|
      r.class.to_s == 'Puppet::Type::Keystone_endpoint' && r[:ensure] == :present
    end
    if ! endpoints.nil?
      rv = endpoints.flatten.map do |e|
        e.name
      end
    end
    rv
  end
end
