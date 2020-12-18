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
  const owner = 'yourbase';
  const repo = 'homebrew-yourbase';
  const tag = context.payload.inputs.tag;
  const branchRefPrefix = 'refs/heads/';
  if (!context.ref.startsWith(branchRefPrefix)) {
    throw new Error('Cannot create pull request for ' + context.ref);
  }
  const branchName = context.ref.substring(branchRefPrefix.length);
  const { data: createPrResult } = await github.pulls.create({
    owner,
    repo,
    head: 'bump-' + tag,
    base: branchName,
    title: 'Bump yb version to ' + tag,
    maintainer_can_modify: true
  });
  console.log('Created ' + createPrResult.html_url);

  await github.pulls.requestReviewers({
    owner,
    repo,
    pull_number: createPrResult.number,
    reviewers: ['zombiezen']
  });
};
