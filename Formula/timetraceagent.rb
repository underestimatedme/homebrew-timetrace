class Timetraceagent < Formula
  include Language::Python::Virtualenv

  desc "Runner for TimeTrace configuration, delegation, checks, and delivery"
  homepage "https://github.com/underestimatedme/TimeTraceAgent"
  url "https://github.com/underestimatedme/TimeTraceAgent/archive/refs/tags/v0.5.7.tar.gz"
  sha256 "c6f689d74de84942f3f847931c7ce58a99914b15c7a392d5d5b3ee7041b27dce"
  license "Apache-2.0"

  depends_on :macos
  depends_on "python@3.12"

  resource "typing_extensions" do
    url "https://files.pythonhosted.org/packages/f6/cc/6253133b5bb138fc3306cebfbda2c520f545d36b5be2c7255cc528bb45d6/typing_extensions-4.16.0.tar.gz"
    sha256 "dc983d19a509c94dba722ee6abd33940f7c05a89e243c47e907eb4db6f1a43e5"
  end

  resource "pyee" do
    url "https://files.pythonhosted.org/packages/8b/04/e7c1fe4dc78a6fdbfd6c337b1c3732ff543b8a397683ab38378447baa331/pyee-13.0.1.tar.gz"
    sha256 "0b931f7c14535667ed4c7e0d531716368715e860b988770fc7eb8578d1f67fc8"
  end

  resource "greenlet" do
    url "https://files.pythonhosted.org/packages/3e/6e/0091f175ccd02b02bc8811bbcbcc6ac2e980be116e3b2f7a736ca322bf84/greenlet-3.5.6.tar.gz"
    sha256 "8e67c43bdfc88d5fee6db0d3e40175b362fc95fb85f0412d233b9b203c53a575"
  end

  resource "playwright" do
    url "https://files.pythonhosted.org/packages/b9/54/6ad97b08b2ca1dfcb4fbde4536c4f45c0d9d8b1857a2d20e7bbfdf43bf15/playwright-1.56.0-py3-none-macosx_11_0_universal2.whl"
    sha256 "0ef7e6fd653267798a8a968ff7aa2dcac14398b7dd7440ef57524e01e0fbbd65"
  end

  def install
    venv = virtualenv_create(libexec, "python3.12")
    resources.reject { |r| r.name == "playwright" }.each { |r| venv.pip_install r }
    # Playwright ships platform wheels, not an sdist. Preserve the wheel name
    # rather than treating its unpacked contents as a source project.
    wheel = buildpath/"playwright-1.56.0-py3-none-macosx_11_0_universal2.whl"
    cp resource("playwright").cached_download, wheel
    venv.pip_install wheel
    venv.pip_install_and_link buildpath
    # Keep the stable opt/ launcher in launchd across brew upgrades.
    (bin/"timetrace").unlink
    (bin/"tta").unlink
    (bin/"timetrace").write <<~SH
      #!/bin/sh
      export TIMETRACE_LAUNCHER="#{opt_bin}/timetrace"
      PYTHONUNBUFFERED=1 exec "#{opt_libexec}/bin/python" -I -m timetrace "$@"
    SH
    chmod 0755, bin/"timetrace"
    bin.install_symlink "timetrace" => "tta"
  end

  def caveats
    <<~EOS
      First install: timetrace setup
      Upgrade: timetrace agent install && timetrace agent doctor
      Existing pairing and project settings remain in ~/.timetrace.
      Browser checks download Chromium on first use.
    EOS
  end

  test do
    assert_match "timetrace #{version}", shell_output("#{bin}/tta --version")
    assert_match "release", shell_output("#{bin}/timetrace release --help")
    system libexec/"bin/python", "-I", "-c", "import playwright.sync_api"
  end
end
