class ErrorMailer < ActionMailer::Base
  def problem_report(problem)
    @problem = problem
    @traceback = caller

    mail(
      from: "no-reply@hkn.eecs.berkeley.edu",
      to: "website-errors@hkn.eecs.berkeley.edu",
      subject: "[hkn-rails] Problem report: #{problem}"
    )
  end
end
