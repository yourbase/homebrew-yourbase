# Copyright 2020 YourBase Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

class YbPreview < Formula
  desc "Build tool optimized for local + remote development"
  homepage "https://yourbase.io/"
  url "https://github.com/yourbase/yb/archive/v0.5.5.tar.gz"
  sha256 "aae1cb023ff9007a688b2e02bd2f64973a9a40f6b96e0e308fcb1e9c3b0b6891"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git", :branch => "main"

  depends_on "go" => :build
  depends_on "docker" => :optional

  conflicts_with "yb", because: "yb-preview and yb both provide a yb binary"

  def install
    ENV["VERSION"] = "v" + version.to_s
    ENV["CHANNEL"] = version.to_s.include?("-") ? "preview" : "stable"
    ENV["GITHUB_SHA"] = "c938fb23296035da37aa96d854cbeea57a81a199"
    ENV["GO111MODULE"] = "on"
    system "release/build.sh", bin/"yb"
  end

  test do
    version_info = shell_output("#{bin}/yb version")
    assert_match "0.5.5", version_info
    assert_match /stable|preview/, version_info
  end
end
