class OxideCli < Formula
  desc "CLI for the Oxide rack"
  homepage "https://github.com/oxidecomputer/oxide.rs"
  version "0.99.0+20250704.0.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/oxide.rs/releases/download/v0.99.0+20250704.0.0/oxide-cli-aarch64-apple-darwin.tar.xz"
      sha256 "43995eea1afd88fcae9c548428f0c732445bf416d6c2acb86a79fe9972f53e58"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/oxide.rs/releases/download/v0.99.0+20250704.0.0/oxide-cli-x86_64-apple-darwin.tar.xz"
      sha256 "6b2c92fe0d96814044c0d7dd620cfb180b103b869b615eccbb14dcce0097ca19"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/oxide.rs/releases/download/v0.99.0+20250704.0.0/oxide-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "1f72e71f46596e07f3d94c0c1dba8201a051f8dc7a837f50204ccf0198b0c6e0"
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
