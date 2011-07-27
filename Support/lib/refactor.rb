#!/usr/bin/env ruby -wKU
ENV['TM_BUNDLE_SUPPORT'] = "/Users/lazylady/Dropbox/Application\ Support/TextMate/Bundles/ActionScript3.tmbundle/Support"

require ENV['TM_BUNDLE_SUPPORT']+'/lib/c_env'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require "erb"

class Refactor

  def create_class
    
    class_builder_file = ENV['TM_BUNDLE_SUPPORT'] + "/lib/class.erb"
    
    project_dir = "#{ENV['TM_PROJECT_DIRECTORY']}"
    file_path = "#{ENV['TM_FILEPATH']}"
    
    # remove address until package
    default_package_path = file_path.gsub(project_dir, "")
    
    # if src remove
    default_package_path.gsub!(/(\bsrc\/\b*)/, "")
    
    # remove first '/'
    default_package_path.slice!(0)
    
    # Remove file name and ending
    default_package_path.gsub!(/\w+\.as$/, "")
    
    default_package_path.gsub!("/", ".")
    
    default_package_path += ENV["TM_CURRENT_WORD"]
    
    # puts default_package_path
    user_input = TextMate::UI.request_string(:title => "Refactor", :prompt => "Create Class", :default => default_package_path)
    
    TextMate.exit_discard if user_input.nil?
    
    class_name = user_input.match(/\w+$/).to_s
    # puts class_name
    package_path = user_input.gsub(/.\w+$/, "")
    
    b = binding
    d = File.read(class_builder_file)
    t = ERB.new(d)
    doc = t.result b
    
    package_path.gsub!(".", "/")
    file_name = class_name + ".as"
    
    # Hackish, but so be it. Add back src
    new_file =  project_dir + "/src/" + package_path + "/" + file_name
    
    File.open(new_file, 'a+') {|f| f.write(doc) }
    # %x[touch #{new_file}]
  end
  
  def extract_method
    
    user_input = TextMate::UI.request_string(:title => "Refactor", :prompt => "Extract Method to Clipboard")
    TextMate.exit_discard if user_input.nil?
    
    user_input = user_input.index("(") == nil ? user_input + "();" : user_input
    
    copy_to_clipboard(user_input)
    write_to_doc(user_input)
        
  end
  
  # TODO get promote variable command – ie Extract Local Variable
  def extract_local_variable
    
  end
  
  private
  
  def copy_to_clipboard user_input
    
    selected_text = ENV['TM_SELECTED_TEXT']
    cleaned_input = user_input.gsub(";", "")
    
    clipboard = "private function #{cleaned_input}:void \n{\n\t"
    
    # Trim indentation, must be a better way than this?
    selected_text.each do |line|
      if line =~ /^[\t\t]/
        line.slice!(0, 2)
      end
      clipboard += line
    end
    
    clipboard += "\n}"
    
    IO.popen("pbcopy", "w") { |copier| copier.puts clipboard }
    
  end
  
  def write_to_doc user_input
    
    args_start_index = user_input.index("(")
    
    if args_start_index.nil?
      print user_input
    else
      args_end_index = user_input.rindex(")")

      method_name = user_input.slice(0, args_start_index)
    
      args = user_input.slice(args_start_index + 1, args_end_index - (args_start_index + 1))
      args = args.split(",")

      stripped_args = []

      args.each do |arg|
        
        arg_end_index = arg.index(":")
        
        if arg_end_index.nil?
          TextMate.exit_show_tool_tip("No type set for argument:#{arg}")
        end
        
        arg = arg.slice(0, arg_end_index)
        
        if stripped_args.empty?
          stripped_args << arg
        else
          stripped_args << "," + arg
        end
      end
    
      stripped_func = "#{method_name}(#{stripped_args});"
      print stripped_func
      
    end    
    
  end
  
end
if __FILE__ == $0

  ENV['TM_ASDOC_GENERATION'] = "true"
  ENV['TM_FILENAME'] = "/test/path/to/src/DummyClass.as"
  ENV['TM_BUNDLE_SUPPORT'] = "/Users/lazylady/Dropbox/Application\ Support/TextMate/Bundles/ActionScript3.tmbundle/Support"

  r = Refactor.new
  # r.extract_method
  r.create_class
  
  # puts ENV['TM_PROJECT_DIRECTORY']
  # puts ENV['TM_FILEPATH']
  
  # str = "myFunc(x:int, m:Number);"
  # 
  # args_start_index = str.index("(")
  # args_end_index = str.rindex(")")
  # 
  # func_name = str.slice(0, args_start_index)
  # 
  # sum = args_end_index - args_start_index
  # 
  # args = str.slice(args_start_index + 1, args_end_index - (args_start_index + 1))
  # args = args.split(",")
  # 
  # stripped_args = []
  # 
  # args.each do |arg|
  #   arg = arg.slice(0, arg.index(":"))
  #   if stripped_args.empty?
  #     stripped_args << arg
  #   else
  #     stripped_args << "," + arg
  #   end
  # end
  # 
  # stripped_func = "#{func_name}(#{stripped_args});"
  # 
  # puts "func : #{func_name}, args : #{stripped_args}, nice: #{stripped_func}, sum: #{sum}"

end