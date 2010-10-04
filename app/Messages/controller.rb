require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class MessagesController < Rho::RhoController
  include BrowserHelper

  
  def index
    @tabs = [ 
      { :label => "Show All",  :action => '/app/Messages/showall'},
      { :label => "Write", :action => '/app/Messages/write' }
    ]
    
    NativeBar.create(Rho::RhoApplication::TABBAR_TYPE, @tabs)
    
    puts "Login index controller for user: #{@params['user']}"
    
    @@user = @params['login']
    Rho::AsyncHttp.post(
      :url => 'http://kata.slalomdemo.com:60577/UserMessageService.asmx/GetAllMessages',
      #:body => "{ 'winUserId' : '#{@params['user']}'}",
      :headers => {"Authorization" => "Basic d2VidXNlcjpQYXNzQHdvcmQh",
                  "Content-Type" => "application/json; charset=utf-8"},
      :callback => (url_for :action => :message_callback),
      :callback_param => "" )
    
    render :action => :index, :back => '/app'
  end
  
  def message_callback
    puts "Message callback with response: #{@params}"
    @@messages = @params['body']['d']
    puts"Got the following messages: #{@@messages}"
    WebView.navigate ( url_for :action => :showall )
  end
  
  def showall
    @messages = @@messages
    render :action=>:showall
  end
  
  def get_messages
    @@messages
  end
  
  def write
    render :action=>:write
  end
  
end