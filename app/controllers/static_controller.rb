class StaticController < ApplicationController
  before_action :authenticate_user!, only: [:distribution]

  def error_404
    @title        = '404'
    @description  = 'The page you were looking for doesn\'t exist. You may have mistyped the address or the page may have moved.'

    render 'static/error', layout: 'devise', status: 404, formats: [:html]
  end

  def error_500
    @title        = '500'
    @description  = 'We\'re sorry, but something went wrong.'

    render 'static/error', layout: 'devise', status: 500, formats: [:html]
  end

  def distribution
    render 'distribution', layout: 'application'
  end
end
