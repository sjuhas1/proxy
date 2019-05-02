Facter.add('domain_role') do
  setcode do
  # Retrieve hostname and assign role base on it        
  hname = Facter.value(:hostname)
    case hname
        when /^proxy/
             'domain_proxy'
        when /^puppet/
             'domain_puppetmaster'
    end
  end
end

