require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML

@@p_or_i = ""

class Parser

    def Parser.parseFile(inputfilename,outputfile,names,tel_ident,type,commissies,resource)
	listener = MyListener.new(outputfile,names,tel_ident,type,commissies,resource)
	source = File.new File.expand_path(inputfilename)
	Document.parse_stream(source, listener)
	source.close
	listener.close_lines
	return [listener.names,listener.teller]
    end

#   def Parser.parseString(id,xml,names,tel_ident,type,outputfilename)
#	listener = MyListener.new(outputfilename,names,tel_ident,type)
#	Document.parse_stream(xml, listener)
#   end

end


class MyListener
    include StreamListener

    def initialize(output,names,tel_ident,type,commissies,resource)
	@output = output
	@type = type
	@names = names
	@commissies = commissies
	@resource = resource
	@current_tag = ""
	@text = ""
	@indent = "  "
	@tel_ident = tel_ident
	@current_name_id = sprintf("%s%03d",@type,@tel_ident)
	@in_name = false
	@current_commissie_id = ""
	@in_commissie = false
	line =<<EOF
  <rdf:Description rdf:about="#{resource}/#{@@p_or_i}/#{@current_name_id}">
    <rdf:type rdf:resource="#{resource}/#{@@p_or_i}"/>
EOF
	@output.puts line
    end

    def close_lines
	@output.puts "  </rdf:Description>"
	@output.puts
    end

    def outputfile
	return @output
    end

    def teller
	return @tel_ident
    end

    def names
	return @names
    end

    def factsheetpersoon_start attrs
    end

    def factsheetpersoon_end
    end

    def factsheetinstelling_start attrs
    end

    def factsheetinstelling_end
    end

    def zitting_in_start attrs
    end

    def zitting_in_end
    end

    def betrokken_bij_start attrs
    end

    def betrokken_bij_end
    end

    def commissie_start attrs
	@indent += "  "
#	@output.write "#{@indent}<#{@@p_or_i}:naam>"
	@in_commissie = true
    end

    def commissie_end
	@output.puts "\n#{@indent}<#{@@p_or_i}:commissie rdf:resource=\"#{@resource}/fc/#{@current_commissie_id}\" />"
	@indent = @indent[0..-3]
	@in_commissie = false
    end

    def naam_start attrs
	@indent += "  "
	@output.write "#{@indent}<#{@@p_or_i}:naam>"
	@in_name = true

    end

    def naam_end
	@output.puts "</#{@@p_or_i}:naam>"
	@indent = @indent[0..-3]
	@in_name = false
    end

    def zitting_start attrs
	@indent += "  "
	@output.puts "#{@indent}<#{@@p_or_i}:zitting>"
	@indent += "  "
	@output.write "#{@indent}<rdf:Seq>"
    end

    def zitting_end
	@output.puts "#{@indent}</rdf:Seq>"
	@indent = @indent[0..-3]
	@output.puts "#{@indent}</#{@@p_or_i}:zitting>"
	@indent = @indent[0..-3]
    end

    def betrokken_start attrs
	@indent += "  "
	@output.puts "#{@indent}<#{@@p_or_i}:betrokken>"
	@indent += "  "
	@output.write "#{@indent}<rdf:Seq>"
    end

    def betrokken_end
	@output.puts "#{@indent}</rdf:Seq>"
	@indent = @indent[0..-3]
	@output.puts "#{@indent}</#{@@p_or_i}:betrokken>"
	@indent = @indent[0..-3]
    end

    def literal name
	@output.puts "<#{@@p_or_i}:#{name} rdf:parseType=\"Literal\">"
    end

    def aantekeningen_start attrs
	literal "aantekeningen"
    end

    def biografische_gegevens_in_start attrs
	literal "biografische_gegevens_in"
    end

    def inhoud_start attrs
	literal "inhoud"
    end

    def literatuur_start attrs
	literal "literatuur"
    end

    def literatuur_in_lijst_start attrs
	literal "literatuur_in_lijst"
    end

    def opmerkingen_start attrs
	literal "opmerkingen"
    end

    def opmerkingen_archivalia_start attrs
	literal "opmerkingen_archivalia"
    end

    def opmerkingen_overig_start attrs
	literal "opmerkingen_overig"
    end

    def organisatie_start attrs
	literal "organisatie"
    end

    def taken_start attrs
	literal "taken"
    end

    def tag_start(name,attrs)
	begin
	    result = self.send( "#{name}_start", attrs )
	    rescue => detail
		@indent += "  "
		@output.write "#{@indent}<#{@@p_or_i}:#{name}>"
#		@tags << name if !@tags.include?(name)
	    end
	return result
    end

    def text( text )
	unless text.empty?
	    unless @current_tag.empty?
		@current_tag = ""
	    end
	    if @in_name
		name = text.strip
		@output.write name
		if !@names.has_key?(name)
		    @tel_ident += 1
		    @current_name_id = sprintf("%s%03d",@type,@tel_ident)
		    @names[name] = @current_name_id
		end
#		STDERR.puts text.strip
	    elsif @in_commissie
		commissie = text.strip
		if @commissies.has_key?(commissie)
		    @current_commissie_id = @commissies[commissie]
		else
		    @current_commissie_id = "N000"
		    @commissies[commissie] = @current_commissie_id
		    STDERR.puts "not found: #{commissie}"
		end
	    else
		text.strip!
		text = check_br text
		@output.write text unless text.empty?
	    end
	end
	@text << text if !text.strip.empty?
    end

    def check_br text
	re = /(<br[^\/]*)>/
	if md = text.match(re)
	    text = "#{md.pre_match}#{md[1]}/>#{md.post_match}"
	end
	text
    end

    def tag_end(name)
	begin
	    result = self.send( "#{name}_end" )
	    rescue => detail
		unless @current_tag.empty?
		    @output.puts "#{@indent}<#{@@p_or_i}:#{name} />"
		else
		    @output.puts "</#{@@p_or_i}:#{name}>"
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

def read_commissies
    names = Hash.new
    File.open("commissies.txt") do |file|
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
    outputfilename = ""
    resource = "https://resource.huygens.knaw.nl/ingforms/const_comm"
    type = ""

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    # voeg start en stop tags toe
	    when '-i' then begin inputfile = ARGV[i+1] end
	    when '-d' then begin directory = ARGV[i+1] end
	    when '-o' then begin outputfilename = ARGV[i+1] end
	    when '-t' then begin type = ARGV[i+1] end
	    when '-r' then begin resource = ARGV[i+1] end
	    when '-h' then
		begin
		    STDERR.puts "use: ruby parser -i input -d directory -o output"
		    exit(0)
		end
	    end
    end

    STDERR.puts inputfile.empty?
    STDERR.puts directory.empty?
    STDERR.puts outputfilename.empty?
    STDERR.puts inputfile
    STDERR.puts directory
    STDERR.puts outputfilename

    if (inputfile.empty? && directory.empty?) || outputfilename.empty? || type.empty?
	STDERR.puts "use: ruby parser -i input -o output -t [I|P]"
	exit(1)
    end

    if type.eql?('P')
	@@p_or_i = "person"
    else
	@@p_or_i = "institute"
    end

    commissies = read_commissies
    outputfile = File.new(outputfilename,"w")

    names = {}
    tel_ident = 0

    if directory.empty?
	names,tel_ident = Parser.parseFile(inputfile,outputfile,names,tel_ident,type,commissies)
    else
	STDERR.puts directory
	if File.directory?(directory)
	    rdf_rdf =<<EOF
<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:fc="https://resource.huygens.knaw.nl/constitutionele_commissies/fc"
    xmlns:person="https://resource.huygens.knaw.nl/constitutionele_commissies/person">

EOF
	    outputfile.puts rdf_rdf
	    wd = Dir.getwd
	    Dir.chdir(directory)
	    file_list = Dir.glob("**/00_factsheet*.xml")
	    file_list.each do |filename|
#		STDERR.puts filename
		names,tel_ident = Parser.parseFile(filename,outputfile,names,tel_ident,type,commissies,resource)
	    end
	    Dir.chdir(wd)
#	    Dir.foreach(directory) do |filename|
#	    end
	end
    end

    names.each do |id,name|
	puts "#{id}: #{name}"
    end

    outputfile.puts
    outputfile.puts "</rdf:RDF>"
    outputfile.puts

end


