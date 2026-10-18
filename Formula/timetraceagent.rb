class Timetraceagent < Formula
  desc "Runner that executes Claude Code and Codex tasks sent from the TimeTrace app"
  homepage "https://github.com/underestimatedme/TimeTraceAgent"
  url "https://github.com/underestimatedme/TimeTraceAgent/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "b806f84f9b991db5634153ffa851cab8578e7192837a147295fae38550c48eb9"
  license "Apache-2.0"

  depends_on :macos
  depends_on "python@3.12"

  def install
    libexec.install "timetrace"
    python = Formula["python@3.12"].opt_bin/"python3.12"
    # TIMETRACE_LAUNCHER tells `tta agent install` to write this opt/ path into the
    # LaunchAgent, so the background runner survives `brew upgrade`.
    (bin/"timetrace").write <<~SH
      #!/bin/sh
      export TIMETRACE_LAUNCHER="#{opt_bin}/timetrace"
      PYTHONUNBUFFERED=1 PYTHONPATH="#{opt_libexec}" exec "#{python}" -P -m timetrace "$@"
    SH
    chmod 0755, bin/"timetrace"
    bin.install_symlink "timetrace" => "tta"
  end

  def caveats
    <<~EOS
      Finish setup (check tools, register repositories, pair with the iPhone app,
      install the background runner):
        tta setup
    EOS
  end

  test do
    assert_match "timetrace #{version}", shell_output("#{bin}/tta --version")
    assert_match "timetrace #{version}", shell_output("#{bin}/timetrace --version")
  end
end
