require 'slop'
require 'fig/lock'
require 'fig/lock/log'

def cmd_args(command, args)
  if args.empty?
    {}
  elsif args.size == 1
    {file: args[0]}
  else
    fail "Usage: fig-lock #{command} <file>"
  end
end

# Execute a block.
def execute(&block)
  run do |opts, args|
    begin
      yield(opts, args)
    rescue StandardError => bang
      if ENV['DEBUG']
        Fig::Lock::Log.log.fatal bang
      else
        Fig::Lock::Log.log.fatal bang.message
      end
    end
  end
end

opts = Slop.parse do
  command 'install' do
    execute do |opts, args|
      Fig::Lock.install cmd_args('install', args)
    end
  end

  command 'update' do
    execute do |opts, args|
      Fig::Lock.update cmd_args('update', args)
    end
  end
end
