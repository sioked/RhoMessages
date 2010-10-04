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
        @@user = @params['login']
        Rho::AsyncHttp.post(
          :url => 'http://kata.slalomdemo.com:60577/UserMessageService.asmx/ValidateUser',
          :body => "{ 'userId' : '#{@params['login']}'}",
          :headers => {"Authorization" => "Basic d2VidXNlcjpQYXNzQHdvcmQh",
                      "Content-Type" => "application/json; charset=utf-8"},
          :callback => (url_for :action => :login_callback),
          :callback_param => "" )
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        render :action => :login
      end
    else
      @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
      WebView.navigate( url_for :action=>:login, :query => {:msg => @msg} )
    end
  end
  
  def login_callback
    puts "Got a response #{@params}"
    if @params['status'] == "ok"
      @@get_result = @params['body']
      if @@get_result['d'] == true
        WebView.navigate( url_for :controller=>:Messages, :action=>:index, :query => {:user => @@user} )
      else
        @msg = "Login not recognized. Please try again"
        WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
      end
    else
      @msg = "Error connecting to authentication service"
      WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    end
  end
  
  def get_res
    @@get_result    
  end
  
end