class IndrelController < ApplicationController
  before_filter :authorize_indrel, :only => :indrel_db
  
  [:index, :contact_us].each {|a| caches_action a, :layout => false}
  
  def index
    @indrel_officers = Committeeship.current.committee("indrel").officers.map{|x|x.person}
    @officers_count = Committeeship.current.officers.count
  end

  def contact_us
    @indrel_officers = Committeeship.current.committee("indrel").officers.map{|x|x.person}
  end

  def infosessions_registration
    @fields = {}
  end

  def infosessions_registration_post
    @fields = params
    required_fields = %w[
      company_name
      address1
      city
      state
      zip_code
      name
      phone
      email
    ]

    @errors = []
    required_fields.each do |field|
      if params[field].blank?
        @errors << "#{field.capitalize.gsub(/_/, ' ')} cannot be blank."
      end
    end

    @errors << "Phone is not well-formatted." if params['phone'].match(/[a-zA-Z]/)
    @errors << "Email is not well-formatted." unless params['email'].match(/.*@.*\..*/)

    unless @errors.empty?
      render :action => :infosessions_registration and return
    end

    IndrelMailer.infosession_registration(@fields, request.host).deliver
  end

  def resume_books_order
    @fields = {}
  end

  def resume_books_order_post
    @fields = params
    required_fields = %w[
      company_name
      address1
      city
      state
      zip_code
      name
      phone
      email
    ]

    @errors = []
    required_fields.each do |field|
      if params[field].blank?
        @errors << "#{field.capitalize.gsub(/_/, ' ')} cannot be blank."
      end
    end

    @errors << "Phone is not well-formatted." if params['phone'].match(/[a-zA-Z]/)
    @errors << "Email is not well-formatted." unless params['email'].match(/.*@.*\..*/)

    unless @errors.empty?
      render :action => :resume_books_order and return
    end

    IndrelMailer.resume_book_order(@fields, request.host).deliver
  end
end
