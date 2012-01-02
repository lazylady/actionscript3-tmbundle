#!/usr/bin/env ruby -KU

require ENV['TM_BUNDLE_SUPPORT']+'/lib/c_env'

class PrintSelection
  
  def self.generate(output_method)

    lines_left = line_num = ENV['TM_SELECTION'].split(":")[0].to_i

    class_name = File.basename(ENV['TM_FILENAME'],".as")
    doc = STDIN.read.split("\n")

    constructor_regexp = /\bfunction\b\s+(\w+)\s*\(.*\)(\s+)?$/
    function_regexp = /\bfunction\b\s+(\w+)\s*\(.*\).*\b\w+/
    accessor_regexp = /\bfunction\b\s+(get|set)\s+(\w+)\s*\(.*\).*\b\w+/

    method_name = ""

    while lines_left > 0

        txt = doc[lines_left].to_s

        m = function_regexp.match(txt) 
        method_name = m[1] unless m == nil

        m = accessor_regexp.match(txt)
        method_name = m[1] + " " + m[2] unless m == nil

        m = constructor_regexp.match(txt)
        method_name = m[1] unless m == nil

        break if method_name != ""

        lines_left -= 1
    end
    
    end_of_line = ENV['TM_CURRENT_LINE'].to_i
    current_word = ENV['TM_SELECTED_TEXT'] || ""
    
    # TextMate.exit_show_tool_tip "line num : " + line_num.to_s
    
    next_line = doc[line_num].to_s

    trace_str = ""
    
    if(next_line.index("{"))
      line_num += 1
      trace_str = "\n\t"
    elsif(doc[line_num - 1].to_s.index("case"))
        trace_str = "\n\t"
    elsif(current_word != "")
      trace_str = "\n"
    end

    TextMate.go_to(:line => line_num, :column => end_of_line)
    trace_str += output_method;
    
    if(method_name == class_name)
      method_name = "constructor"
    end
    
    if(current_word == "")
      trace_str += '("' + class_name + ' > ' + method_name + '");'
    else
      trace_str += '("' + class_name + ' > ' + method_name + ' > ' + current_word + ' : " + ' + current_word + ');'
    end

    print trace_str
    
  end

end

if __FILE__ == $0
  
end