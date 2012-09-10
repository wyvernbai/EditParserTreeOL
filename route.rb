# encoding： UTF-8

require "sinatra/base"
require "rdiscount"
require "erb"
require "sinatra/flash"
require "./parserSetence.rb"

Sinatra::Base.set :markdown, :layout_engine => :erb
class TreeEditer < Sinatra::Base
	register Sinatra::Flash

 enable :sessions

  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new {File.join(root, "public")}
  set :views, Proc.new {File.join(root, "views")}
  
  set :files=>[]
=begin
  set :current_setence=>""
  set :current_index=>0
  set :setence_index=>[]
  set :current_file=>""
  set :setence_hash=>{}
  set :files=>[]
  set :text_area=>""
  set :graph_area=>""
=end

  view_path = root + "/views/"
  public_path = root + "/public/"
  layout 'background'

  configure do
  	settings.files = Dir["TreeBank/*\.fid"]
  end

  helpers do
  	def setence_segment content
  		setence_index = {}
  		index = 0
  		setence_regex = Regexp.new("<S[ ]*ID=([0-9]*)>([^<]*)<\/S>", Regexp::MULTILINE)
  		content.scan(setence_regex).each do |setence_item|
  			setence_index.store index, setence_item[1]
  			index += 1
  		end
  		setence_index
  	end
  	
  	def setence_segment_singleline content
		  	
  	end
  end
  
  def simple_loadfile filename
  		content = File.read(filename)
  		setence_hash = setence_segment content
  end
  
  def loadfile filename
  		content = File.read(filename)
  		setence_hash = setence_segment content
  		session[:current_file] = filename
  		session[:setence_index] = setence_hash.keys
  		setence_hash
  end
  
  get "/" do
  	@files = settings.files
  	if session[:current_file] == nil then
  		session[:current_file] = settings.files[0]
  		session[:current_index] = 0
  	end
  	setence_hash = loadfile session[:current_file]
  	current_setence = setence_hash[session[:current_index]]
  	@index = session[:setence_index]
  	@current_index = session[:current_index]
  	@current_file = session[:current_file]
  	
  	begin
  		session[:text_area], session[:graph_area] = parserSetence current_setence
  	rescue => e
  		puts e.message
  		puts e.backtrace
  	end	
  	
  	@setence = session[:text_area]
  	@graph_area = session[:graph_area]
  	erb :index, :layout => :background
  end
  
  post '/choose' do
  	if session[:current_file] != params[:treeBankFileName] then
  		session[:current_file] = params[:treeBankFileName]
  	end
  	
  	if params[:index] == nil then
  		session[:current_index] = 0
  	else
  		session[:current_index] = params[:index].to_i
  	end
  	redirect "/"
  end
  
  post '/nextfile' do
  
  	if session[:current_file] == "" then
  		session[:current_file] = settings.files[0]
  	end
  	session[:current_index] = 0
	 temp = settings.files.find_index(session[:current_file]) + 1
	 if temp < settings.files.size then
	 	session[:current_file] = settings.files[temp]
	 	@hasNextFile = ""
	 else
	 	@hasNextFile = "disabled"
	 end
	 redirect "/"
  end  
  
  post '/prefile' do
  	if session[:current_file] == "" then
  		session[:current_file] = settings.files[0]
  	end
  	session[:current_index] = 0
	 temp = settings.files.find_index(session[:current_file]) - 1
	 if temp >= 0 then
	 	session[:current_file] = settings.files[temp]
	 	@hasPreFile = ""
	 else
	 	@hasPreFile = "disabled"
	 end
	 redirect "/"
  end
  
  post '/presetence' do
  	if session[:current_index] - 1 < 0 then
  		@hasPreSetence = "disabled"
  	else
  		@hasPreSetence = ""
  		session[:current_index] -= 1
  	end
	 redirect "/"
  end
  
  post '/nextsetence' do
  	p session[:current_index]
  	if session[:current_index] + 1 >= session[:setence_index].size then
  		@hasPreSetence = "disabled"
  	else
  		@hasPreSetence = ""
  		session[:current_index] += 1
  	end
	 redirect "/"
  end
  
  post '/edit_tree' do
  	current_setence = params[:content]
  	begin
  		session[:text_area], session[:graph_area] = parserSetence current_setence
  	rescue => e
  		puts e.message
  		puts e.backtrace
  	end	
  	@setence = session[:text_area]
  	@graph_area = session[:graph_area]
  	
  	@files = settings.files
  	@index = session[:setence_index]
  	@current_index = session[:current_index]
  	@current_file = session[:current_file]

  	erb :index, :layout => :background
  end
  
  post '/write_file' do
  	setence_hash = loadfile session[:current_file]
  	setence_hash[session[:current_index]] = oneLine session[:text_area]
  	outstream = File.open(session[:current_file], "w")
  	setence_hash.each do |key, value|
  		outstream.write value
  	end
  end
  
  not_found do
    markdown File.read("#{public_path}not_found.md"), :layout => :background
  end

  run!
end

