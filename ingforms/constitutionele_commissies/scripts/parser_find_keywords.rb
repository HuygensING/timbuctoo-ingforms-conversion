require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,keywords,teller,tags)
	listener = MyListener.new(keywords,teller,tags)
	source = File.new File.expand_path(inputfilename)
	Document.parse_stream(source, listener)
	source.close
	[listener.keywords,listener.teller,listener.tags]
    end

    def Parser.parseString(id,xml,output_file)
	listener = MyListener.new(output_file,"",{},0)
	Document.parse_stream(xml, listener)
    end

end


class MyListener
    include StreamListener

    def initialize(keywords,teller,tags)
	@keywords = keywords
	@teller = teller
	@in_thema = false
	@tags = tags
	@root = ""
    end

    def keywords
	@keywords
    end

    def teller
	@teller
    end

    def tags
	@tags
    end

    def thema_start attrs
	@in_thema = true
    end

    def thema_end
	@in_thema = false
    end

    def subthema_start attrs
	@in_thema = true
    end

    def subthema_end
	@in_thema = false
    end

    def tag_start(name,attrs)
	begin
	    result = self.send( "#{name}_start", attrs )
	    rescue => detail
		if @root.empty?
		    @root = name
		end
#		@output.write "<#{name}>"
#		@tags << name if !@tags.include?(name)
	    end
	return result
    end

    def text( text )
	text.strip!
	unless text.empty?
	    if @in_thema
		thema = text.strip
		if !@keywords.has_key?(thema)
		    @teller += 1
		    thema_id = sprintf("K%003d",@teller)
		    @keywords[thema] = thema_id
		    @tags << @root unless @tags.include?(@root)
#		    STDERR.puts "not found: #{thema}"
		end
	    end
	end
#	@text << text if !text.strip.empty?
    end

    def tag_end(name)
	begin
	    result = self.send( "#{name}_end" )
	    rescue => detail
	    end
	return result
    end

    def put_out( arg )
	arg
    end

end

if __FILE__ == $0

    inputfile = ""
    directory = ""
    resource = "https://resource.huygens.knaw.nl/ingforms/const_comm"

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    # voeg start en stop tags toe
	    when '-i' then begin inputfile = ARGV[i+1] end
	    when '-d' then begin directory = ARGV[i+1] end
	    when '-r' then begin resource = ARGV[i+1] end
	    when '-h' then
		begin
		    STDERR.puts "use: ruby parser -i input -o output"
		    exit(0)
		end
	    end
    end

    if (inputfile.empty? && directory.empty?)
	STDERR.puts "use: ruby parser -i input"
	exit(1)
    end

    keywords = Hash.new
    tags = Array.new

    if directory.empty?
	Parser.parseFile(inputfile,output,names,1)
    else
#	STDERR.puts directory
	if File.directory?(directory)
	    teller = 0 
	    wd = Dir.getwd
	    Dir.chdir(directory)
	    file_list = Dir.glob("**/*.xml")
	    file_list.each do |filename|
#		STDERR.puts filename
		keywords,teller,tags = Parser.parseFile(filename,keywords,teller,tags)
	    end
	    Dir.chdir(wd)

	end
    end

    keywords.each do |name,id|
	puts "#{name}: #{id}"
    end

    puts "tags:"
    tags.each do |tag|
	puts tag
    end

    output = File.new("keywords.xml","w")
    start_lines =<<EOF
<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:keyword="https://resource.huygens.knaw.nl/constitutionele_commissies/keyword">
EOF

    output.write start_lines
    keywords.each do |name,id|
	item_lines =<<EOF

  <rdf:Description rdf:about="https://resource.huygens.knaw.nl/ingforms/const_comm/keyword/#{id}">
    <rdf:type rdf:resource="https://resource.huygens.knaw.nl/ingforms/const_comm/keyword"/>
    <keyword:naam>#{name}</keyword:naam>
  </rdf:Description>
EOF
	output.puts item_lines
    end

    output.puts "\n</rdf:RDF>"

end

