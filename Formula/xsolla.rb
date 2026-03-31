# typed: false
# frozen_string_literal: true

class Xsolla < Formula
  desc "Xsolla CLI - manage Xsolla services from the command line"
  homepage "https://developers.xsolla.com/doc/cli"
  url "https://github.com/xsolla/xsolla-cli.git", tag: "v0.2.0", using: :git
  version "0.2.0"
  license "MIT"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/xsolla/xsolla-cli/cmd.version=#{version}
      -X github.com/xsolla/xsolla-cli/cmd.commit=#{Utils.git_head}
      -X github.com/xsolla/xsolla-cli/cmd.date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    system "#{bin}/xsolla", "version"
  end
end
