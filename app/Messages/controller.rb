require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class MessagesController < Rho::RhoController
  include BrowserHelper

  
  def index
    @tabs = [ 
      { :label => "Show All",  :action => '/app/Messages/index'},
      { :label => "Write", :action => '/app/Messages/write' }
    ]
    
    NativeBar.create(Rho::RhoApplication::TABBAR_TYPE, @tabs)
    
    puts "Login index controller for user: #{@params['user']}"
    if @params['user']
      @@user = @params['user']
    end
    Rho::AsyncHttp.post(
      :url => 'http://kata.slalomdemo.com:60577/UserMessageService.asmx/GetAllMessages',
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
  
  def do_write
    puts "Writing with #{@params}"
    if @params['message']
      begin
        Rho::AsyncHttp.post(
          :url => 'http://kata.slalomdemo.com:60577/UserMessageService.asmx/SubmitUserMessage',
          :body => "{ 'winUserId' : '#{@@user}',
                      'msg' : '#{@params['message']}',
                      'tags' : '' }",
          :headers => {"Authorization" => "Basic d2VidXNlcjpQYXNzQHdvcmQh",
                      "Content-Type" => "application/json; charset=utf-8"},
          :callback => (url_for :action => :write_callback),
          :callback_param => "" )
        render :action => :wait
      rescue Rho::RhoError => e
        @msg = e.message
        WebView.navigate ( url_for :action => :write, :query => {:msg => @msg} )
      end
    else
      @msg = "Please write a message first!"
      WebView.navigate ( url_for :action => :write, :query => {:msg => @msg} )
    end
  end
  
  def write_callback
    if @params['error']
      @msg = "Error received!"
    else
      @msg = "Message submitted!"
    end
    WebView.navigate ( url_for :action => :write, :query => {:msg => @msg} )
  end
  
  def showall
    @messages = @@messages
    render :action=>:showall
  end
  
  def get_messages
    @@messages
  end
  
  def write
    @msg = @params['msg']
    render :action=>:write
  end
  
end