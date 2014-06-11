$:.unshift(File.join(__dir__, '..', '..', 'lib'))

RSpec.configure do |config|
  require 'simplecov'
  SimpleCov.add_filter 'vendor'
  SimpleCov.add_filter 'spec'
  SimpleCov.start
end


require 'fig/lock'

module Fig

  describe Lock do

    before :each do
      ENV['LOG_LEVEL'] = 'FATAL'
    end

    context 'class operations' do
      it 'should install' do
        expect(Lock).to receive(:new).with({}){
          double('lock').tap do |lock|
            expect(lock).to receive(:install)
          end
        }
        Lock.install({})
      end

      it 'should update' do
        expect(Lock).to receive(:new).with({}){
          double('lock').tap do |lock|
            expect(lock).to receive(:update)
          end
        }
        Lock.update({})
      end
    end

    context 'instance operations' do

      before :each do
        allow(File).to receive(:exists?).with('fig.yml'){true}
        allow(File).to receive(:directory?).with('fig.yml'){false}
        allow(File).to receive(:read).with('fig.yml'){yaml}
        allow(File).to receive(:read).with('fig.lock'){yaml}
      end

      it 'should install' do
        lock = Fig::Lock.new(registry: 'some.docker.com', file:'fig.yml')
        allow(File).to receive(:exists?).with('fig.lock'){true}

        expect(lock).to receive(:system).with('sudo docker pull some.docker.com/atlas/api'){true}

        lock.install
      end

      it 'should update if no fig.lock exists' do
        lock = Fig::Lock.new(registry: 'some.docker.com', file:'fig.yml')
        allow(File).to receive(:exists?).with('fig.lock'){false}
        expect(lock).to receive(:update)
        lock.install
      end

      it 'should update' do
        lock = Fig::Lock.new(registry: 'some.docker.com', file:'fig.yml')

        expect(lock).to receive(:system).with('sudo docker pull some.docker.com/atlas/api'){true}
        expect(lock).to receive(:`).with('sudo docker images some.docker.com/atlas/api'){docker_image_output}
        expect(File).to receive(:write).with('fig.lock', expected_fig_lock)

        lock.update
      end

      def expected_fig_lock
        <<-eos
---
web:
  image: some.docker.com/atlas/api:20140611142604
        eos
      end

      def docker_image_output
        <<-eos
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
some.docker.com/atlas/api         20140611142604      784dfb100eb0        4 hours ago         376.4 MB
        eos
      end

      def yaml
        <<-eos
---
web:
  image: some.docker.com/atlas/api
        eos
      end
    end
  end
end
