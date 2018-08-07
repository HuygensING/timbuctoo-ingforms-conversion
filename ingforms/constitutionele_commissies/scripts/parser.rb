require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,outputfilename,resource,names,tel_ident)
	listener = MyListener.new(outputfilename,resource,names,tel_ident)
	source = File.new File.expand_path(inputfilename)
	Document.parse_stream(source, listener)
	listener.closing_lines
	source.close
	[listener.comm_name,listener.comm_id]
    end

    def Parser.parseString(id,xml,output_file)
	listener = MyListener.new(output_file,"",{},0)
	Document.parse_stream(xml, listener)
    end

end


class MyListener
    include StreamListener

    def initialize(outputfile,resource,names={},tel_ident)
	@resource = resource
	@names = names
	@output = outputfile
	@comm_id = sprintf("C%02d",tel_ident)
	@comm_name = ""
	@in_name_comm = false

	rdf_rdf =<<EOF
    <rdf:Description
	rdf:about="#{@resource}/fc/#{@comm_id}">
        <rdf:type rdf:resource="#{@resource}/fc"/>
EOF
	@output.puts rdf_rdf
	@tags = Array.new
	@current_tag = ""
	@text = ""
	@indent = "  "
	@current_name_id = ""
	@in_name = false
    end

    def closing_lines
	rdf_rdf =<<EOF
  </rdf:Description>

EOF
	@output.puts rdf_rdf
	@output.puts
#	@output.puts "</rdf:RDF>"
	@output.puts
    end

    def comm_id
	@comm_id
    end

    def comm_name
	@comm_name
    end

    def outputfile
	return @output
    end

    def tags
	return @tags
    end

    def factsheetcommissie_start attrs
    end

    def factsheetcommissie_end
    end

    def samenstelling_start attrs
	@indent += "  "
	@output.puts "#{@indent}<fc:samenstelling>"
	@indent += "  "
	@output.puts "#{@indent}<rdf:Seq>"
    end

    def samenstelling_end
	@output.puts "#{@indent}</rdf:Seq>"
	@indent = @indent[0..-3]
	@output.puts "#{@indent}</fc:samenstelling>"
	@indent = @indent[0..-3]
    end

    def persoon_start attrs
	@indent += "  "
	@output.puts "#{@indent}<fc:persoon>"
	@indent += "  "
	@output.puts "#{@indent}<rdf:Description>"
    end

    def persoon_end
	@output.puts "#{@indent}</rdf:Description>"
	@indent = @indent[0..-3]
	@output.puts "#{@indent}</fc:persoon>"
	@indent = @indent[0..-3]
    end

    def functies_start attrs
	@indent += "  "
	@output.puts "#{@indent}<fc:functies>"
	@indent += "  "
	@output.puts "#{@indent}<rdf:Seq>"
    end

    def functies_end
	@output.puts "#{@indent}</rdf:Seq>"
	@indent = @indent[0..-3]
	@output.puts "#{@indent}</fc:functies>"
	@indent = @indent[0..-3]
    end

    def naam_start attrs
	@indent += "  "
#	@output.write "#{@indent}<fc:naam>"
	@in_name = true
    end

    def naam_end
	@output.puts "#{@indent}<person:naam rdf:resource=\"#{@resource}/person/#{@current_name_id}\" />"
	@indent = @indent[0..-3]
	@in_name = false
    end

    def naam_voorzitter_start attrs
	@output.write "<fc:naam_voorzitter>"
	@in_name_comm = true
    end

    def naam_voorzitter_end
	@output.puts "</fc:naam_voorzitter>"
	@in_name_comm = false
    end

    def literal name
	@output.puts "<fc:#{name} rdf:parseType=\"Literal\">"
    end

    def verslagen_start attrs
	literal "verslagen"
    end

    def subcommissies_start attrs
	literal "subcommissies"
    end

    def literatuur_start attrs
	literal "literatuur"
    end

    def opmerkingen_start attrs
	literal "opmerkingen"
    end

    def av_bronnen_start attrs
	literal "av_bronnen"
    end

    def aantekeningen_start attrs
	literal "aantekeningen"
    end

    def tag_start(name,attrs)
	begin
	    result = self.send( "#{name}_start", attrs )
	    rescue => detail
		@indent += "  "
		@current_tag = "#{@indent}<fc:#{name}>"
#		@output.write "<#{name}>"
		@tags << name if !@tags.include?(name)
		puts "#{detail}\nin #{name}" if name.eql?("naam")
	    end
	return result
    end

    def text( text )
	unless text.empty?
	    unless @current_tag.empty?
		@output.write @current_tag unless @in_name
		@current_tag = ""
	    end
	    @output.write "#{text.strip}" unless @in_name
	    if @in_name_comm
		@comm_name = text.strip
	    end
	    if @in_name
		name = text.strip
		if @names.has_key?(name)
		    @current_name_id = @names[name]
		else
		    @current_name_id = "N000"
		    @names[name] = @current_name_id
		    STDERR.puts "not found: #{name}"
		end
	    end
	end
	@text << text if !text.strip.empty?
    end

    def tag_end(name)
	begin
	    result = self.send( "#{name}_end" )
	    rescue => detail
		unless @current_tag.empty?
		    @output.puts "#{@indent}<fc:#{name} />"
		else
		    @output.puts "</fc:#{name}>"
		end
		@indent = @indent[0..-3]
		@current_tag = ""
#		puts "end: #{detail}\nin #{name}" #if detail.to_s.match(/nil/)
	    end
	return result
    end

    def put_out( arg )
	@teller += 1
#	arg = clear_text arg
	arg
    end

end

def clear_text line
    line.gsub!(/-<\/i><i>/,"")
    line.gsub!(/<\/i><i>/," ")
    line.gsub!(/ <\/i>/,"</i> ")
    line.gsub!(/ - /," &GED+ ")
    line.gsub!(/-/,"&KOP+")
    line.gsub!(/(\d)&KOP\+(\d)/,"\\1-\\2")
    line.gsub!(/([a-z])'([a-z])/,"\\1&APO+\\2")
    line.gsub!(/'([^']*)'/,"@\\1#")
    line.gsub!(/}{/,"")
    line.gsub!(/\\line/,"")
    line
end

def regel_aanpassen line
    line.gsub!(/&KOP\+/,"KOPPELTEKEN")
    line.gsub!(/&WEG\+/,"WEGSTREEPJE")
    line.gsub!(/&GED\+/,"GEDACHTESTREEPJE")
    line.gsub!(/&APO\+/,"APOSTROPH")
    line.gsub!(/\(/,"HAAKJELINKS")
    line.gsub!(/\)/,"HAAKJERECHTS")
    line.gsub!(/\\/,"BACKSLASH")
    line.gsub!(/\//,"FORWARDSLASH")
    line.gsub!(/\[/,"BLOKHAAKLINKS")
    line.gsub!(/\]/,"BLOKHAAKRECHTS")
    line.gsub!("^","CIRCONFLEX")
    line.gsub!("*","ASTERIX")
    line.gsub!("?","VRAAGTEKEN")
    line.gsub!("%","PROCENT")
    line
end

def regel_herstellen line
    line.gsub!("KOPPELTEKEN","&KOP+")
    line.gsub!("WEGSTREEPJE","&WEG+")
    line.gsub!("GEDACHTESTREEPJE","&GED+")
    line.gsub!("APOSTROPH","&APO+")
    line.gsub!("HAAKJELINKS","(")
    line.gsub!("HAAKJERECHTS",")")
    line.gsub!("BACKSLASH","\\")
    line.gsub!("FORWARDSLASH","/")
    line.gsub!("BLOKHAAKLINKS","[")
    line.gsub!("BLOKHAAKRECHTS","]")
    line.gsub!("CIRCONFLEX","^")
    line.gsub!("ASTERIX","*")
    line.gsub!("VRAAGTEKEN","?")
    line.gsub!("PROCENT","%")
    line
end

def read_names
    names = Hash.new
    File.open("personen.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    if !line.empty?
		name,id = line.split(/: /)
		names[name] = id.strip
	    end
	end
    end
    names
end

if __FILE__ == $0

    inputfile = ""
    directory = ""
    outputfile = ""
    resource = "https://resource.huygens.knaw.nl/ingforms/const_comm"

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    # voeg start en stop tags toe
	    when '-i' then begin inputfile = ARGV[i+1] end
	    when '-d' then begin directory = ARGV[i+1] end
	    when '-o' then begin outputfile = ARGV[i+1] end
	    when '-r' then begin resource = ARGV[i+1] end
	    when '-h' then
		begin
		    STDERR.puts "use: ruby parser -i input -o output"
		    exit(0)
		end
	    end
    end

    if (inputfile.empty? && directory.empty?) || outputfile.empty?
	STDERR.puts "use: ruby parser -i input -o output"
	exit(1)
    end

    names = read_names

    output = File.new(outputfile,"w")
    rdf_rdf =<<EOF
<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:fc="https://resource.huygens.knaw.nl/constitutionele_commissies/fc"
    xmlns:person="https://resource.huygens.knaw.nl/constitutionele_commissies/person">
EOF

    output.puts rdf_rdf

    commissies = Hash.new
    if directory.empty?
	Parser.parseFile(inputfile,output,names,1)
    else
#	STDERR.puts directory
	if File.directory?(directory)
	    teller = 0 
	    wd = Dir.getwd
	    Dir.chdir(directory)
	    file_list = Dir.glob("**/00_factsheet*.xml")
	    file_list.each do |filename|
		teller += 1
		STDERR.puts filename
		comm_name,comm_id = Parser.parseFile(filename,output,resource,names,teller)
		commissies[comm_name] = comm_id
	    end

	end
    end
    
    rdf_rdf =<<EOF

</rdf:RDF>

EOF

    output.puts rdf_rdf

    commissies.each do |name,id|
	puts "#{name}: #{id}"
    end

end

