class OxideCli < Formula
  desc "CLI for the Oxide rack"
  homepage "https://github.com/wfchandler/oxide.rs"
  version "0.99.0+20250704.0.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.1/oxide-cli-aarch64-apple-darwin.tar.xz"
      sha256 "0f732a18baea813a404d5c7d08428c4eafd0b826382cc27936f65c810cbdbdd7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.1/oxide-cli-x86_64-apple-darwin.tar.xz"
      sha256 "5e191b4669260fb7d71c0633eb91dffd7aa57a9e369f1880a7b3c5fb559a777e"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/wfchandler/oxide.rs/releases/download/v0.99.0+20250704.0.1/oxide-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "e2603c55119d56e03f40ce54cc2e0318757f491147bced81014314cdf99a4819"
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
    generate_completions_from_executable(bin/"oxide",
                                          "completion", shell_parameter_format: :arg, shells: [:bash, :fish, :pwsh, :zsh])

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
