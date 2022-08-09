import { Client } from "@notionhq/client";
import "dotenv/config";

const core = require("@actions/core");
const github = require("@actions/github");
const { GitHub } = require("@actions/github/lib/utils");

const databaseId = process.env.NOTION_DATABASE_ID;
const notionVersion = "2022-06-28"

async function createCommit(notion, commits) {
    commits.forEach((commit) => {

        const task = commit.message.substring(commit.message.indexOf("atnt:") + 6);

        // search for a page in the Notion database "Tasks" given the task name
        const page = notion.pages.filter(
            (page) => page.properties.title === task
        )[0];

        var headers = new Headers();
        headers.append("Notion-Version", notionVersion);
        headers.append("Authorization", `Bearer ${core.getInput("notion_secret")}`);
        headers.append("Content-Type", `application/json`);


        var raw = JSON.stringify({
            "parent": {
                "page_id": page.page_id
            },
            "rich_text": [
                {
                    [core.getInput("commit_url")]: {
                        "text": {
                            "content": commit.url
                        }
                    }
                }
            ]
        });

        var requestOptions = {
            method: 'POST',
            headers: headers,
            body: raw,
            redirect: 'follow'
        };

        fetch("https://api.notion.com/v1/comments", requestOptions)
            .then(response => response.text())
            .then(result => console.log(result))
            .catch(error => console.log('error', error));
    });
}

(async () => {
    try {
        const notion = new Client({ auth: core.getInput(`notion_secret`) });
        createCommit(notion, github.context.payload.commits);
    } catch (error) {
        core.setFailed(error.message);
    }
})();