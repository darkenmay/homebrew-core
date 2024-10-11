class Aerleon < Formula
  include Language::Python::Virtualenv

  desc "Generate firewall configs for multiple firewall platforms"
  homepage "https://aerleon.readthedocs.io/en/latest/"
  url "https://files.pythonhosted.org/packages/ca/bd/87869c1cb33a2b4d269c6f66056c44453e643925731cb85e6861d1121be8/aerleon-1.9.0.tar.gz"
  sha256 "850cd621dda750263db313d4473302b48b82adaaa9220e6fd0677cb7900f95f6"
  license "Apache-2.0"
  head "https://github.com/aerleon/aerleon.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia:  "8035c20f4b232aa3430edbb35e8c55cbb972dd74c096f3009cbe4387f1d5f96b"
    sha256 cellar: :any,                 arm64_sonoma:   "66ed88e3888a7584e9574f20fda2afcd4535ce25c74d6694b1c1805502942cd8"
    sha256 cellar: :any,                 arm64_ventura:  "7974e30641c93665207c6d6775118347f8acc75899a96a0f6463fbaf680eeae6"
    sha256 cellar: :any,                 arm64_monterey: "31fbe5882a576becd288f72d63213654955713d4197621745a61bd995843d015"
    sha256 cellar: :any,                 sonoma:         "0b6c03084055867198bcb9e9d6e87d15969fe814a3c393b9d2ac378b9a18cfee"
    sha256 cellar: :any,                 ventura:        "b5fe4630ad59e7649acb26a635644428bf4c940e8f6435341782b135aaae174b"
    sha256 cellar: :any,                 monterey:       "161cb0611f0565b6fb1b289190e6611dbca52b232da72df9b7783216c5fadb38"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "970a29563825fa5b291db0f44c4ababfa3e3528aed7c3511d0640f273a9772d2"
  end

  depends_on "libyaml"
  depends_on "python@3.13"

  conflicts_with "cgrep", because: "both install `cgrep` binaries"

  resource "absl-py" do
    url "https://files.pythonhosted.org/packages/79/c9/45ecff8055b0ce2ad2bfbf1f438b5b8605873704d50610eda05771b865a0/absl-py-1.4.0.tar.gz"
    sha256 "d2c244d01048ba476e7c080bd2c6df5e141d211de80223460d5b3b8a2a58433d"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz"
    sha256 "d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/df/db/f35a00659bc03fec321ba8bce9420de607a1d37f8342eee1863174c69557/typing_extensions-4.12.2.tar.gz"
    sha256 "1a7ead55c7e559dd4dee8856e3a88b41225abfe1ce8df57b7c13915fe121ffb8"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"def/definitions.yaml").write <<~EOS
      networks:
        RFC1918:
          values:
            - address: 10.0.0.0/8
            - address: 172.16.0.0/12
            - address: 192.168.0.0/16
        WEB_SERVERS:
          values:
            - address: 10.0.0.1/32
              comment: Web Server 1
            - address: 10.0.0.2/32
              comment: Web Server 2
        MAIL_SERVERS:
          values:
            - address: 10.0.0.3/32
              comment: Mail Server 1
            - address: 10.0.0.4/32
              comment: Mail Server 2
        ALL_SERVERS:
          values:
            - WEB_SERVERS
            - MAIL_SERVERS
      services:
        HTTP:
          - protocol: tcp
            port: 80
        HTTPS:
          - protocol: tcp
            port: 443
        WEB:
          - HTTP
          - HTTPS
        HIGH_PORTS:
          - port: 1024-65535
            protocol: tcp
          - port: 1024-65535
            protocol: udp
    EOS

    (testpath/"policies/pol/example.pol.yaml").write <<~EOS
      filters:
      - header:
          comment: Example inbound
          targets:
            cisco: inbound extended
        terms:
          - name: accept-web-servers
            comment: Accept connections to our web servers.
            destination-address: WEB_SERVERS
            destination-port: WEB
            protocol: tcp
            action: accept
          - name: default-deny
            comment: Deny anything else.
            action: deny#{"  "}
    EOS

    assert_match "writing file: example.pol.acl", shell_output("#{bin}/aclgen 2>&1")
    assert_path_exists "example.pol.acl"
  end
end
