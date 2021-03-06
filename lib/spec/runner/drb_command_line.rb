require "drb/drb"

# Monkeypatch to fix http://redmine.ruby-lang.org/issues/show/496
module DRb
  class << self
    alias orig_start_service start_service
  end
  
  def self.start_service(uri = nil, front = nil, config = nil)
    if uri.nil?
      orig_start_service("druby://localhost:0", front, config)
    else
      orig_start_service(uri, front, config)
   end
  end
end

module Spec
  module Runner
    # Facade to run specs by connecting to a DRB server
    class DrbCommandLine
      # Runs specs on a DRB server. Note that this API is similar to that of
      # CommandLine - making it possible for clients to use both interchangeably.
      def self.run(options)
        begin
          DRb.start_service
          spec_server = DRbObject.new_with_uri("druby://127.0.0.1:8989")
          spec_server.run(options.argv, options.error_stream, options.output_stream)
        rescue DRb::DRbConnError => e
          options.error_stream.puts "No server is running"
        end
      end
    end
  end
end
