#!/usr/bin/env ruby -wKU

require ENV['TM_BUNDLE_SUPPORT']+'/lib/c_env'

class PrintSelection
  
  def self.generate(output_method)

    line_number = ENV['TM_LINE_NUMBER'].to_i-1

    class_name = File.basename(ENV['TM_FILENAME'],".as")
    doc = STDIN.read.split("\n")

    constructor_regexp = /\bfunction\b\s+(\w+)\s*\(.*\)(\s+)?$/
    function_regexp = /\bfunction\b\s+(\w+)\s*\(.*\).*\b\w+/
    accessor_regexp = /\bfunction\b\s+(get|set)\s+(\w+)\s*\(.*\).*\b\w+/

    method_name = ""

    while line_number > 0

        txt = doc[line_number].to_s

        m = function_regexp.match(txt) 
        method_name = m[1] unless m == nil

        m = accessor_regexp.match(txt)
        method_name = m[1] + " " + m[2] unless m == nil

        m = constructor_regexp.match(txt)
        method_name = m[1] unless m == nil

        break if method_name != ""

        line_number -= 1

    end

    line_idx = ENV['TM_CURRENT_LINE']
    line_idx = line_idx.length+1

    line_number = ENV['TM_LINE_NUMBER'].to_i
    current_word = ENV['TM_SELECTED_TEXT'].to_s;

    # if(current_word == "")
    #      TextMate.exit_show_tool_tip("Nothing selected.")
    #    end

    next_line = doc[line_number].to_s

    trace_str = ""

    if(next_line.index("{"))
      line_number += 1
      trace_str = "\n\t"
    elsif(doc[line_number - 1].to_s.index("case"))
        trace_str = "\n\t"
    elsif(current_word != "")
      trace_str = "\n"
    end

    TextMate.go_to(:line => line_number, :column => line_idx)

    trace_str += output_method;

    if(current_word == "")
      trace_str += '("' + class_name + ' > ' + method_name + '");'
    else
      trace_str += '("' + class_name + ' > ' + method_name + ' > ' + current_word + ' : " + ' + current_word + ');'
    end

    print trace_str
    
  end
  
end