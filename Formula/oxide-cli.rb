class OxideCli < Formula
  desc "CLI for the Oxide rack"
  homepage "https://github.com/wfchandler/oxide.rs"
  version "0.99.0+20250704.0.2"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.2/oxide-cli-aarch64-apple-darwin.tar.xz"
      sha256 "722772900d1bf5412f5df622882ad0f3a56510f22bedc4b31cfbe4780715fbba"
    end
    if Hardware::CPU.intel?
      url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.2/oxide-cli-x86_64-apple-darwin.tar.xz"
      sha256 "61c023a5a6154fd0055e7f2936410fc1b04cb1bc08af74bdf13e06d96c83b5b1"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.2/oxide-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "c5981391c97e74d0fc176c562e14a72c33dcd246ba18ee5786a15ec6cff0ba61"
  end
  license "MPL-2.0"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":              {},
    "x86_64-apple-darwin":               {},
    "x86_64-pc-windows-gnu":             {},
    "x86_64-unknown-linux-gnu":          {},
    "x86_64-unknown-linux-musl-dynamic": {},
    "x86_64-unknown-linux-musl-static":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "oxide" if OS.mac? && Hardware::CPU.arm?
    bin.install "oxide" if OS.mac? && Hardware::CPU.intel?
    bin.install "oxide" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!
    generate_completions_from_executable(
      bin/"oxide",
      "completion",
      shell_parameter_format: :arg,
      shells:                 [:bash, :fish, :pwsh, :zsh],
    )

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
