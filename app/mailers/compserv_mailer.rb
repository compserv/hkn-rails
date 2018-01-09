class CompservMailer < ActionMailer::Base
  def problem_report(problem)
    @problem = problem
    @traceback = caller

    mail(
      from: "no-reply@hkn.eecs.berkeley.edu",
      # TODO: Change to compserv@
      to: "jvperrin@hkn.eecs.berkeley.edu",
      subject: "[hkn-rails] Problem report: #{problem}"
    )
  end
end
