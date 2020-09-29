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
  url "https://github.com/yourbase/yb/archive/v0.3.0-beta3.tar.gz"
  sha256 "1c154b1e7c1195cb262dabbf21d2b31cd42f5c6a5c8f59d1d031e9290928714f"
  license "Apache-2.0"
  head "https://github.com/yourbase/yb.git"

  depends_on "go" => :build
  depends_on "docker" => :recommend

  def install
    ENV["GITHUB_SHA"] = "ece75fa01ca1635667f651a588af371b6baed352"
    ENV["VERSION"] = 'v' + version.to_s
    ENV["GO111MODULE"] = "on"
    system "./build.sh", bin/"yb"
  end

  test do
    assert_match "0.3.0", shell_output("#{bin}/yb --version")
  end
end
