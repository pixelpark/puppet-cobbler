require 'json'

Puppet::Type.type(:cobbler_profile).provide(:ruby) do
  desc "Provides cobbler profile via json file artifacts"

  # Supports redhat only
  confine    'os.family' => :redhat
  defaultfor 'os.family' => :redhat
  commands   :cobbler  => 'cobbler'

  mk_resource_methods
  # generates the following methods via Ruby metaprogramming
  # def version
  #   @property_hash[:version] || :absent
  # end

  # Resources discovery
  def self.instances
    profiles = []
    Dir.glob('/var/lib/cobbler/collections/profiles/*\.json').each do |file|
      # get properties of current repo to @property_hash
      repo = JSON.parse(File.read(file))
      profiles << new(
        :name                  => profile["name"],
        :ensure                => :present,
        :distro                => profile["distro"],
        :dhcp_tag              => profile["dhcp_tag"],
        :name_servers          => profile["name_servers"],
        :name_servers_search   => profile["name_servers_search"],
        :autoinstall           => profile["autoinstall"],
        :kernel_options        => profile["kernel_options"],
        :kernel_options_post   => profile["kernel_options_post"],
        :autoinstall_meta      => profile["autoinstall_meta"],
        :repos                 => profile["repos"],
        :virt_cpus             => profile["virt_cpus"],
        :virt_ram              => profile["virt_ram"],
        :virt_type             => profile["virt_type"]
      )
    end
    profiles
  end

  def self.prefetch(resources)
    instances.each do |profile|
      if resource = resources[profile.name]
        resource.provider = profile
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    # To add a profile only name and distro is required
    cobbler( 
            [
              "profile",
              "add",
              "--name=" + @resource[:name],
              "--distro=" + @resource[:distro]
            ]
           )
    # set properties as they are not set by defaut
    properties = [
      "distro",
      "dhcp_tag",
      "name_servers",
      "name_servers_search",
      "autoinstall",
      "repos",
      "kernel_options",
      "kernel_options_post",
      "autoinstall_meta",
      "virt_cpus",
      "virt_type",
    ]
    for property in properties
      unless self.send(property) == @resource.should(property) or @resource[property].nil?
        self.set_field(property, @resource.should(property))
      end
    end

    cobbler("sync")
    @property_hash[:ensure] = :present
  end

  def set_field(what, value)
    if value.is_a? Array
      value = "#{value.join(' ')}"
    end

    if value.is_a? Hash
      value  = value.map{|k,v| "#{k}=#{v}"}.join(" ")
    end

    cobbler(
      [
        "profile",
        "edit",
        "--name=" + @resource[:name],
        "--#{what.tr('_','-')}=" + value.to_s
      ]
    )
    cobbler('sync')
    @property_hash[what] = value
  end

  def set_kernel_options(name, value)
    str_value = ''
    if value.is_a? Hash
      str_value = value.map{ |k,v| v=='~' ? "#{k}" : "#{k}=#{v}" }.join(' ')
    end
    set_field(name, str_value)
  end

  def destroy
    # remove cobbler profile
    cobbler(
      [
        "profile",
        "remove",
        "--name=#{@resource[:name]}"
      ]
    )
    @property_hash.clear
  end

  # Setters
  def autoinstall=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    self.set_field("autoinstall", value)
  end

  def distro=(value)
    self.set_field("distro", value)
  end

  def dhcp_tag=(value)
    self.set_field("dhcp_tag", value)
  end

  def name_servers=(value)
    self.set_field("name_servers", value)
  end

  def name_servers_search=(value)
    self.set_field("name_servers_search", value)
  end

  def kernel_options=(value)
    self.set_kernel_options("kernel_options", value)
  end

  def kernel_options_post=(value)
    self.set_kernel_options("kernel_options_post", value)
  end

  def autoinstall_meta=(value)
    self.set_field("autoinstall_meta", value)
  end

  def repos=(value)
    self.set_field("repos", value)
  end

  def virt_cpus=(value)
    self.set_field("virt_cpus", value)
  end

  def virt_ram=(value)
    self.set_field("virt_ram", value)
  end

  def virt_type=(value)
    self.set_field("virt_type", value)
  end


end
