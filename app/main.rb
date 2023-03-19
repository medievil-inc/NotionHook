require 'octokit'

github_token = ENV['PERSONAL_ACCESS_TOKEN']
notion_secret = ENV['NOTION_SECRET']

puts 'STARTING'
puts ENV["GITHUB_EVENT_NAME"]
puts ENV["GITHUB_SHA"]
puts ENV["GITHUB_REF"]
puts ENV["GITHUB_WORKFLOW"]
puts ENV["GITHUB_ACTION"]
puts ENV["GITHUB_ACTOR"]
puts ENV["GITHUB_JOB"]
puts 'ENDING'


client = Octokit::Client.new(:access_token => github_token)

user = client.user
user.login