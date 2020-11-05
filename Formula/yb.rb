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
  url "https://github.com/yourbase/yb/archive/v0.4.4.tar.gz"
  sha256 "492d7f260c39a25f48fb8087f42e14ccf0af25625eb05413a6034fcf6a9b9ac4"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git"

  depends_on "go" => :build
  depends_on "docker" => :optional

  def install
    ENV["VERSION"] = "v" + version.to_s
    ENV["CHANNEL"] = version.to_s.include?("-") ? "preview" : "stable"
    ENV["GITHUB_SHA"] = "3cbe9146014d292995f2aaa8310147fab28e9abc"
    ENV["GO111MODULE"] = "on"
    system "release/build.sh", bin/"yb"
  end

  test do
    version_info = shell_output("#{bin}/yb version")
    assert_match "0.4.4", version_info
    assert_match /stable|preview/, version_info
  end
end
