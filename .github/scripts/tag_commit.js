// Copyright 2020 YourBase Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

module.exports = async ({github, context}) => {
  const query = `query($tagName: String!) {
    repository(owner: "yourbase", name: "yb") {
      release(tagName: $tagName) {
        tag {
          target {
            __typename
            ... on Commit { oid }
            ... on Tag { target { oid } }
          }
        }
      }
    }
  }`;
  const variables = {
    tagName: context.payload.inputs.tag
  };
  console.log('Searching for ' + variables.tagName);
  const result = await github.graphql(query, variables);
  const target = result.repository.release.tag.target;
  if (target.__typename === 'Tag') {
    return target.target.oid;
  }
  return result.oid;
};
