require 'base64'
require 'json'
require 'rest-client'
require 'fig/lock/version'

module Fig
  class Lock::DockerClient

    attr_reader :cfg

    def initialize(file="#{ENV['HOME']}/.dockercfg")
      @cfg = JSON.parse(File.read(file))
    end

    def tags(repo)
      array = repo.split('/')
      registry = array[0]
      repo = array[1]
      name = array[2]
      if name.index(':')
        name = name.split(':')[0]
      end

      resource = base(registry)['v1']['repositories'][repo][name]['tags']
      JSON.parse(resource.get.body)
    end

    def base(registry)
      config = cfg[registry]
      if config
        auth = Base64.decode64(config['auth'])
        RestClient::Resource.new("https://#{auth}@#{registry}")
      else
        RestClient::Resource.new("https://#{registry}")
      end
    end

  end
end
