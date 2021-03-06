require 'yaml'
require 'fig/lock/docker_client'
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
select_latest(hash)

  log.info "Writing lock file #{lock_file} ..."
File.write(lock_file, hash.to_yaml)

  log.info "Done."
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

  resolved_tags = {}

  old_lock_yaml = lock_yaml

  hash.each do |k,v|
  image = v['image']
  next unless image
  image = "#{image}:latest" unless image.index(':')
  log.info "Selecting latest tag for #{image} ..."

  unless image.nil?
  result = resolved_tags[image]
  if result
  log.debug "Using previously resolved image: #{result}"
  else
# Fetch tags
tags = docker_client.tags(image)
  latest = tags['latest']
  fail "Image #{image} has no latest tag" if latest.nil?

# Figure out which one corresponds to "latest"
  version = tags.detect{|k,v|
    v == latest && k != 'latest'
  }
version = version[0] if version
fail "No matching version found for hash #{latest}" unless version

result = "#{image[0..image.rindex(':')-1]}:#{version}"
log.debug "Resolved image: #{result}"
resolved_tags[image] = result
end

# Update hash
v['image'] = result
if old_lock_yaml && old_lock_yaml[k] && old_lock_yaml[k]['image'] == result
log.debug "Component #{k} already using tag: #{result}"
else
log.info "Component #{k} updated to tag: #{result}"
end
end
end
end

  def lock_yaml
  if File.exists?(lock_file)
YAML.load(File.read(lock_file))
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

  def docker_client
  @docker_client ||= DockerClient.new
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
