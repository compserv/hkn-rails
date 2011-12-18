SimpleCov.start 'rails' do
  add_filter '.bundle'
  add_filter 'vendor'
end if ENV['COVERAGE']
