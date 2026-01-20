require 'json'

Puppet::Type.type(:cobbler_distro).provide(:ruby) do
  desc "Provides cobbler distro via json file artifacts"

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
    distros = []    
    Dir.glob('/var/lib/cobbler/collections/distros/*\.json').each do |file|
      # get properties of current distro to @property_hash
      distro = JSON.parse(File.read(file))
      distros << new(
        :name    => distro['name'],
        :ensure  => :present,
        :arch    => distro['arch'],
        :kernel  => distro['kernel'],
        :autoinstall_meta  => distro['autoinstall_meta'],
        :initrd  => distro['initrd'],
        :comment => distro['comment'],
        :owners  => distro['owners']
      )
    end
    distros
  end

  def self.prefetch(resources)
    instances.each do |distro|
      if resource = resources[distro.name]
        resource.provider = distro
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    # If path if defined then using import to create new distribution
    if @resource[:path]
      self.import
    # Othewise use add command that requires only kernel and initrd parameters
    else
      raise ArgumentError, ':kernel and :initrd must be defined' unless @resource[:kernel] and @resource[:initrd]
      cmd_args = [
        'distro',
        'add',
        "--name=#{@resource[:name]}",
        "--kernel=#{@resource["kernel"]}",
        "--initrd=#{@resource["initrd"]}",
      ]
      cobbler(cmd_args)
    end
    # set properties as they are not set by defaut
    properties = [
      "kernel",
      "initrd",
      "arch",
      "comment",
      "owners"
    ]
    for property in properties
      unless self.send(property) == @resource[property] or @resource[property].nil?
        self.send("#{property}=", @resource[property])
      end
    end

    cobbler("sync")
    @property_hash[:ensure] = :present
  end


  def destroy
    # remove cobbler distribution
    Puppet.warning("All child objects of #{@resource[:name]} distribution are deleted")
    cobbler(
      [
        "distro",
        "remove",
        "--recursive",
        "--name=#{@resource[:name]}"
      ]
    )
    cobbler('sync')
    @property_hash.clear
  end

  def import
    # import cobbler distribution
    cobbler(
      [
        "import",
        "--name=#{@resource[:name]}",
        "--arch=#{@resource[:arch]}",
        "--path=#{@resource[:path]}"
      ]
    )
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
        "distro",
        "edit",
        "--name=" + @resource[:name],
        "--#{what.tr('_','-')}=" + value.to_s
      ]
    )
    cobbler('sync')
    @property_hash[what] = value
  end

  #Setters
  def kernel=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    self.set_field("kernel", value)
  end

  def initrd=(value)
    raise ArgumentError, '%s: not exists' % value unless File.exists? value
    self.set_field("initrd", value)
  end

  def comment=(value)
    self.set_field("comment", value)
  end

  def owners=(value)
    self.set_field("owners", value)
  end

  def arch=(value)
    self.set_field("arch", value)
  end

  def autoinstall_meta=(value)
    self.set_field("autoinstall_meta", value)
  end
end
