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

class Yb < Formula
  desc "Build tool optimized for local + remote development"
  homepage "https://yourbase.io/"
  url "https://github.com/yourbase/yb/archive/v0.6.3.tar.gz"
  sha256 "638bbaea7ccdef3a12175c1011e9fee30759d788ad8174bf33f1f4c00be86ac6"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git", branch: "main"

  depends_on "go" => :build
  depends_on "docker" => :optional

  conflicts_with "yb-preview", because: "yb-preview and yb both provide a yb binary"

  def install
    ENV["VERSION"] = "v" + version.to_s
    ENV["CHANNEL"] = version.to_s.include?("-") ? "preview" : "stable"
    ENV["GITHUB_SHA"] = "f67a51bb0e7178fa3d5d53718ddbc699b9bcb781"
    ENV["GO111MODULE"] = "on"
    system "release/build.sh", bin/"yb"
    mkdir bash_completion
    system bin/"yb", "gen-complete", "-o", bash_completion/"yb", "bash"
    mkdir zsh_completion
    system bin/"yb", "gen-complete", "-o", zsh_completion/"_yb", "zsh"
  end

  test do
    version_info = shell_output("#{bin}/yb version")
    assert_match(/stable|preview/, version_info)
  end
end
