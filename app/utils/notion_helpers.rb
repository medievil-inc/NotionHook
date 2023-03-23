# file: notion_helpers.rb

# frozen_string_literal: true

module NotionHelpers
    module_function

    def create_comment_by_commit(notion, payload, commit)
        page = search_page(notion, commit)

        return if page.nil?

        options = {
            parent: {
                page_id: page.id
            },
            rich_text: [
                create_comment_title(content: '💬 Commit: '),
                create_comment_description(content: "#{commit.message.gsub(/(\r\n|\n|\r)/, ' ')}\n"),
                create_comment_title(content: '👀 Branch: '),
                create_comment_description(
                    content: "#{payload.ref}\n",
                    color: 'purple'
                ),
                create_comment_title(content: '🐣 Author: '),
                create_comment_description(
                    content: "#{commit.author.name}\n",
                    color: 'yellow',
                    code: true
                ),
                create_comment_title(content: '📫 URL: '),
                create_comment_description(
                    content: commit.url.to_s,
                    color: 'blue',
                    url: commit.url
                )
            ]
        }

        notion.create_comment(options) do |result|
            puts JSON.pretty_generate(result)
        end
    rescue StandardError => e
        puts e.message
        exit 1
    end

    def create_comment_by_pr(notion, payload, pull_request)
        # your code here
    end

    def create_comment_title(content, color: 'gray')
        {
            text: {
                content:
            },
            annotations: {
                color:
            }
        }
    end

    def create_comment_description(content, color, code: false, url: nil)
        {
            text: {
                content:,
                link: {
                    url:
                }
            },
            annotations: {
                code:,
                color:
            }
        }
    end

    def search_page(notion, commit)
        regex = '(?=(?:.*?[A-Za-z]))(?=(?:.*?[0-9]))[A-Za-z0-9]{32}'
        query = commit.message.match(regex)&.[](0)

        response = notion.search(
            query:,
            filter: {
                property: 'object',
                value: 'page'
            }
        )

        response.results&.[](0)
    end
end
