# file: notion_helpers.rb

# frozen_string_literal: true

module NotionHelpers
    def self.search_page(notion, commit)
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
