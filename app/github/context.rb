require "json"
require "English"

class Context
    def initialize
        @payload = {}
        if ENV["GITHUB_EVENT_PATH"]
            if File.exist?(ENV["GITHUB_EVENT_PATH"])
                @payload = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"], encoding: "utf-8"))
            else
                path = ENV["GITHUB_EVENT_PATH"]
                $stdout.write("GITHUB_EVENT_PATH #{path} does not exist#{$INPUT_RECORD_SEPARATOR}")
            end
        end
        @event_name = ENV["GITHUB_EVENT_NAME"]
        @sha = ENV["GITHUB_SHA"]
        @ref = ENV["GITHUB_REF"]
        @workflow = ENV["GITHUB_WORKFLOW"]
        @action = ENV["GITHUB_ACTION"]
        @actor = ENV["GITHUB_ACTOR"]
        @job = ENV["GITHUB_JOB"]
        @run_number = ENV["GITHUB_RUN_NUMBER"].to_i
        @run_id = ENV["GITHUB_RUN_ID"].to_i
        @api_url = ENV["GITHUB_API_URL"] || "https://api.github.com"
        @server_url = ENV["GITHUB_SERVER_URL"] || "https://github.com"
        @graphql_url = ENV["GITHUB_GRAPHQL_URL"] || "https://api.github.com/graphql"
    end

    def issue
        payload = @payload
        {
            owner: repo[:owner],
            repo: repo[:repo],
            number: (payload["issue"] || payload["pull_request"] || payload)["number"]
        }
    end

    def repo
        if ENV["GITHUB_REPOSITORY"]
            owner, repo = ENV["GITHUB_REPOSITORY"].split("/")
            { owner: owner, repo: repo }
        elsif @payload["repository"]
            {
                owner: @payload["repository"]["owner"]["login"],
                repo: @payload["repository"]["name"]
            }
        else
            raise "context.repo requires a GITHUB_REPOSITORY environment variable like 'owner/repo'"
        end
    end

    attr_reader :payload, :event_name, :sha, :ref, :workflow, :action, :actor, :job,
                :run_number, :run_id, :api_url, :server_url, :graphql_url
end
