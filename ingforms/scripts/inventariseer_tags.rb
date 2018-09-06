require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'

include REXML

class Tag
    def initialize parent,name,level
	@occurrences = 1
	@parent = parent
	@name = name
	@level = level
	@children = Hash.new
	@path = []
	@literal = false
    end

    def add_child child
	if has_child? child.get_name
	    old_child = @children[child.get_name]
	    old_child.inc_occurrences
	    return old_child
	else
	    @children[child.get_name] = child
	    return child
	end
    end

    def add_path path
	@path << path if !@path.include? path
    end

    def get_child name
	@children[name]
    end

    def get_children
	@children
    end

    def get_level
	@level
    end

    def get_literal
	@literal
    end

    def get_name
	@name
    end

    def get_occurrences
	@occurrences
    end

    def get_parent
	@parent
    end

    def has_child? child
	@children.keys.include? child
    end

    def has_parent?
	return !@parent.nil?
    end

    def inc_occurrences
	@occurrences += 1
    end

    def merge tag
	return false if !tag.get_name.eql?(get_name)
	if tag.get_parent.nil? && get_parent.nil?
	    # OK
	else
	    return false if tag.get_parent.nil? || get_parent.nil?
	    return false if tag.get_parent.get_name != get_parent.get_name
	end
	if get_occurrences < tag.get_occurrences
	    @occurrences = tag.get_occurrences
	end
	tag.get_children.each do |k,v|
	    if !has_child? k
		add_child v
	    else
		get_child(k).merge v
	    end
	end
	set_literal (get_literal || tag.get_literal)
	return true
    end

    def roots_and_locations
	path = "  #{@path.join(',')}" unless @path.empty?
	"<#{@name}> :\n\t#{path}\n"
    end

    def set_literal value
	@literal = value
    end

    def to_s
	result = ""
	indent = "  " * @level
	occurrences = ""
	occurrences = " (#{get_occurrences})" #unless @level==0
	literal = ""
	literal = " (literal)" if @literal
	result += "#{indent}<#{@name}>#{occurrences}#{literal}\n"
	@children.values.each do |child|
	    result += child.to_s
	end
	result
    end

end

class Parser

    def Parser.parseFile(inputfilename,outputfile,tags)
	listener = MyListener.new(outputfile,tags)
	begin 
	source = File.new File.expand_path(inputfilename)
	Document.parse_stream(source, listener)
	source.close
	listener.return_value.add_path(File.expand_path(File.dirname(inputfilename)))
	listener.return_value
	rescue => any
	    STDERR.puts any
	    STDERR.puts inputfilename
	end
	listener.return_value
    end

    def Parser.parseString(xml,output_file,tags)
	listener = MyListener.new(output_file,tags)
	Document.parse_stream(xml, listener)
	listener.return_value
    end

end


class MyListener
    include StreamListener

    def initialize(output,tags)
	@output = output
	@tags = tags
	@current_tag = nil
	@return_value = nil
	@level = 0
	@parent = ""
	@stack = []
    end

    def tags
	@tags
    end

    def current_tag
	@current_tag
    end

    def return_value
	@return_value
    end

    def tag_start(name,attrs) 
	@current_tag = Tag.new(@current_tag,name,@level)
	@level += 1
    end

    def text( text )
	text.strip!
	unless text.empty?
	    @current_tag.set_literal true if text.match(/<[^>]*>/)
	end
    end

    def tag_end(name)
	if !@current_tag.get_parent.nil?
	    @current_tag.get_parent.add_child @current_tag
	end
	if @current_tag.get_parent.nil?
	    @return_value = @current_tag
	end
	@current_tag = @current_tag.get_parent unless @current_tag.get_parent.nil?
	@level -= 1
    end

end

if __FILE__ == $0

    STDERR.puts "inventariseer alle tags en maak een hiërarchisch overzicht"
#   bijvoorbeeld (declercq):
    #   <page>
    #     <ingevoerd_door>
    #     <jaar>
    #     <scannummer>
    #     <url>
    #     <links_of_rechts>
    #     <paginanummer>
    #     <transcriptie>
    #     <opmerkingen>
    #   met aantallen (binnen de 'parent'), locaties (voor de 'roots')
    #   'literal'-inhouden

    inputfile = ""
    directory = ""
    outputfilename = ""

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    when '-d' then begin directory = ARGV[i+1] end
	    when '-o' then begin outputfilename = ARGV[i+1] end
	    when '-h' then
		begin
		    STDERR.puts "use: ruby parser -d directory [-o outputfile]"
		    exit(0)
		end
	    end
    end

    if directory.empty? || !File.directory?(directory)
	STDERR.puts "use: ruby parser -d directory [-o outputfile]"
	exit(1)
    end

    if outputfilename.empty?
	output = STDOUT
    else
	output = File.new(outputfilename,"w")
    end

    tags = Hash.new
    wd = Dir.getwd
    Dir.chdir(directory)
    file_list = Dir.glob("**/*.xml")
    file_list.each do |filename|
	result = Parser.parseFile(filename,output,tags)
	if result.nil?
	    STDERR.puts "nil result: #{filename}"
	else
	    if tags.has_key?(result.get_name)
		tags[result.get_name].merge result
		tags[result.get_name].inc_occurrences
	    else
		tags[result.get_name] = result
	    end
	end
    end

    tags.values.each do |t|
	output.puts t.roots_and_locations
    end

    output.puts

    tags.values.each do |t|
	output.puts t
    end

end

