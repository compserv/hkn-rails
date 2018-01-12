Rails.application.config.assets.precompile += %w(
    application.js piglatin.js moonspeak.js acid.js b.js kappa.js
    application.scss mirror.css print.css *.pdf
)

# These are per-controller stylesheets or javascripts
Rails.application.config.assets.precompile += %w(
    candidates.css coursechart.css coursechart.js coursesurveys.css
    eligibilities.css events.css exams.css home.css.erb indrel.css
    people.css.erb static.scss resume_books.css tutor.css.erb
    courseguide.js.erb coursesurveys.js.erb tutor.js
)
