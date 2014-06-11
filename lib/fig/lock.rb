require 'yaml'
require 'fig/lock/log'
require 'fig/lock/version'

module Fig
  class Lock
    class << self
      def install(opts={})
        Lock.new(opts).install
      end

      def update(opts={})
        Lock.new(opts).update
      end
    end
  end
end

module Fig
  class Lock
    include Fig::Lock::Log

    attr_reader :lock_file, :file

    def initialize(opts)
      opts = merge_opts(opts)
      @file = opts[:file]
      @lock_file = lock_file_name(file)

      fail "File #{file} does not exist" unless File.exists?(file)
      fail "File #{file} is a directory" if File.directory?(file)
    end

    # Install images from a lock file on the local system
    def install
      if File.exists?(lock_file)
        log.info "Lock file #{lock_file} found."
        fetch_images(YAML.load(File.read(lock_file)))
      else
        log.info "No lock file found."
        update
      end
    end

    # Update an existing lock file, or create if none exists
    def update
      log.info "Generating lock file for #{file} ..."
      hash = YAML.load(File.read(file))

      fetch_images(hash)
      select_latest(hash)

      File.write(lock_file, hash.to_yaml)
    end

    private

    # Construct the name of the lock file from the name of the fig file
    def lock_file_name(file)
      index = file.rindex('.')
      raise "Input file #{file} has no file extension" unless index
      file[0, index] << '.lock'
    end

    # Select the latest version for images in the fig hash. Updates the input hash.
    def select_latest(hash)
      log.info "Selecting latest tags:"
      hash.each do |k,v|
        image = v['image']
        unless image.nil?
          output = `sudo docker images #{image}`
          fail "Unable to list image: #{image}.\n\tExit code:#{$?.exitstatus}\n\tOutput:#{output}" unless $?.exitstatus.zero?
          tag = output.split("\n")[1].split(' ')[1]
          tagged_image = "#{image}:#{tag}"
          log.info "Resolved: #{tagged_image}"
          v['image'] = tagged_image
        end
      end
    end

    # Fetch all images from the fig hash.
    def fetch_images(hash)
      log.info "Fetching images:"
      hash.each do |k,v|
        image = v['image']
        if image
          log.info "Fetching #{image} ..."
          system "sudo docker pull #{image}"
          fail "Unable to fetch image: #{image}.\n\tExit code:#{$?.exitstatus}" unless $?.exitstatus.zero?
        end
      end
      log.info "Done fetching images."
    end

    def merge_opts(opts)
      Defaults.opts.merge(opts).tap do |hash|
        fail("file must be specified") unless hash[:file]
      end
    end
  end

  # Default values for parameters
  class Defaults
    class << self
      def opts
        {
          file: file
        }
      end

      def file
        ENV.fetch 'FIG_FILE', File.join(__dir__, 'fig.yml')
      end
    end
  end
end
