require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class LoginController < Rho::RhoController
  include BrowserHelper
  
  def index
    puts "Login index controller"
    redirect :action => :login
  end
  
  def login
    @msg = @params['msg']
    render :action => :login, :back => '/app'
  end

  def do_login
    if @params['login']
      begin
        Rho::AsyncHttp.get(
          :url => 'http://www.edsiok.com/test.json',
          :body => 'test',
          :callback => (url_for :action => :login_callback),
          :callback_param => "" )
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        render :action => :login
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      render :action => :login
    end
  end
  
  def login_callback
    puts "Got a response #{@params}"
    @@get_result = @params['body']
    WebView.navigate ( url_for :action => :response )
  end
  
  def get_res
    @@get_result    
  end
  
end