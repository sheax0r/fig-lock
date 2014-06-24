$:.unshift(File.join(__dir__, '..', '..', '..', 'spec'))
require 'json'
require 'fig/spec_helper'

class Fig::Lock
  describe DockerClient do

    context 'with basic auth' do
      let (:auth) {
        {'some.repo.com' => {'auth'=> Base64.encode64('user:password')}}
      }

      it 'should retrieve tags' do
        expect(ENV).to receive(:[]).with('HOME'){'/path/to/home'}
        expect(File).to receive(:read).with('/path/to/home/.dockercfg'){auth.to_json}
        expect(RestClient::Resource).to receive(:new).with('https://user:password@some.repo.com'){resource}
        client = DockerClient.new
        expect(client.tags('some.repo.com/repo/name:latest')).to eq tags
      end
    end

    context 'without basic auth' do
      let (:auth) { {} }

      it 'should retrieve tags' do
        expect(ENV).to receive(:[]).with('HOME'){'/path/to/home'}
        expect(File).to receive(:read).with('/path/to/home/.dockercfg'){auth.to_json}
        expect(RestClient::Resource).to receive(:new).with('https://some.repo.com'){resource}
        client = DockerClient.new
        expect(client.tags('some.repo.com/repo/name:latest')).to eq tags
      end

    end

    private

    def resource
      @resource ||= double('resource').tap do |r|
        allow(r).to receive_message_chain(:[], :[], :[], :[], :[], :get, :body){tags.to_json}
      end
    end

    def tags
      {
        'latest' => 'some_hash',
        'some_other_tag' => 'some_hash'
      }
    end

  end
end

