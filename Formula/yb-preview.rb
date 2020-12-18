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
  url "https://github.com/yourbase/yb/archive/v0.6.0-beta1.tar.gz"
  sha256 "98efb88ef74b85ad0aded32b75222f7bcd915056f0da4cefdad50b1bd8ccfddf"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git", :branch => "main"

  depends_on "go" => :build
  depends_on "docker" => :optional

  conflicts_with "yb", because: "yb-preview and yb both provide a yb binary"

  def install
    ENV["VERSION"] = "v" + version.to_s
    ENV["CHANNEL"] = version.to_s.include?("-") ? "preview" : "stable"
    ENV["GITHUB_SHA"] = "a60e009a7951b08aa21410ceda7a4fab6686a232"
    ENV["GO111MODULE"] = "on"
    system "release/build.sh", bin/"yb"
  end

  test do
    version_info = shell_output("#{bin}/yb version")
    assert_match /stable|preview/, version_info
  end
end
