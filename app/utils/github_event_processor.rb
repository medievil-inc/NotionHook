# frozen_string_literal: true

require 'json'

module GitHubEventProcessor
    module_function

    def load_payload
        return {} unless ENV['GITHUB_EVENT_PATH']

        if File.exist?(ENV['GITHUB_EVENT_PATH'])
            JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
        else
            path = ENV['GITHUB_EVENT_PATH']
            puts "GITHUB_EVENT_PATH #{path} does not exist"
            {}
        end
    end
end
