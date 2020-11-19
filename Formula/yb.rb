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
  url "https://github.com/yourbase/yb/archive/v0.5.3.tar.gz"
  sha256 "bba370c1bd102b94daf7c7f2e5ff9e97b5d1a39cd95188a1ad0d8dd915b26eb5"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git"

  depends_on "go" => :build
  depends_on "docker" => :optional

  def install
    ENV["VERSION"] = "v" + version.to_s
    ENV["CHANNEL"] = version.to_s.include?("-") ? "preview" : "stable"
    ENV["GITHUB_SHA"] = "2952aa8363218bea589c07c68bcd3f190e902a18"
    ENV["GO111MODULE"] = "on"
    system "release/build.sh", bin/"yb"
  end

  test do
    version_info = shell_output("#{bin}/yb version")
    assert_match "0.5.3", version_info
    assert_match /stable|preview/, version_info
  end
end
