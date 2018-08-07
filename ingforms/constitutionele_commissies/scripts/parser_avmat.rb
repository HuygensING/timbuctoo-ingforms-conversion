require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,outputfile,keywords,personen,commissies,resource,teller)
	listener = MyListener.new(outputfile,keywords,personen,commissies,resource,teller)
	source = File.new File.expand_path(inputfilename)
	Document.parse_stream(source, listener)
	source.close
	listener.close_lines
	listener.teller
    end

    def Parser.parseString(id,xml,output_file)
	listener = MyListener.new(output_file,"",{},0)
	Document.parse_stream(xml, listener)
    end

end


class MyListener
    include StreamListener

    def initialize(output,keywords,personen,commissies,resource,teller)
	@output = output
	@keywords = keywords
	@names = personen
	@commissies = commissies
	@resource = resource
	@teller = teller
	@in_thema = false
	@text = ""
	@indent = "  "
	@current_tag = ""
	@tags = Array.new
	@teller = teller + 1
	@current_name_id = sprintf("A%03d",@teller)
	@in_name = false
	@current_commissie_id = ""
	@in_commissie = false
	@in_persoon = false
	@zitting_in = Array.new
	@new_line = false
	line =<<EOF
  <rdf:Description rdf:about="#{resource}/avmat/#{@current_name_id}">
    <rdf:type rdf:resource="#{resource}/avmat" />
EOF
	@output.puts line
    end

    def close_lines
	@output.puts "  </rdf:Description>"
	@output.puts
    end

    def teller
	@teller
    end

    def current
	@tags.last
    end

    def parent
	@tags[-2]
    end

    def grandparent
	@tags[-3]
    end

    def find_person person
	return @names[person] if @names.has_key?(person)
	return nil
	# al dat moeilijke gedoe om toch nog een persoon terug te vinden gebruikrn we
	# (voorlopig) niet meer:
	@names.each do |name,id|
	    return id if name.downcase.match(person.downcase) || person.downcase.match(name.downcase)
	    last,first = name.split(/,/)
	    naam = "#{first.strip} #{last}"
	    return id if naam.downcase.match(person.downcase) || person.downcase.match(naam.downcase)
	    return id if last.downcase.match(person.downcase) || person.downcase.match(last.downcase)
	end
	return nil
    end

    def avmat_start attrs
    end

    def avmat_end
    end

    def commissie_start attrs
	@in_commissie = true
    end

    def commissie_end
	if parent.eql?("avmat")
	    if @zitting_in.empty?
		@output.puts "#{indent}<avmat:commissies />"
	    else
		@output.puts "#{indent}<avmat:commissies>"
		@output.puts "#{indent}  <rdf:Seq>"
		@zitting_in.each do |comm|
		    @output.puts "#{indent}    <avmat:commissie rdf:resource=\"#{@resource}/fc/#{comm}\" />"
		end
		@output.puts "#{indent}  </rdf:Seq>"
		@output.puts "#{indent}</avmat:commissies>"
		@new_line = true
	    end
	    @in_commissie = false
	end
    end

    def personen_start attrs
	@in_persoon = true
	@personen = Array.new
    end

    def personen_end
	if @personen.empty?
	    @output.puts "#{indent}<avmat:personen />"
	else
	    @output.puts "#{indent}<avmat:personen>"
	    @output.puts "#{indent}  <rdf:Seq>"
	    @personen.each do |pers,opm|
		if pers.eql?("P000")
		    persoon = ""
		else
		    persoon = "#{indent}      <avmat:naam rdf:resource=\"#{@resource}/person/#{pers}\" />\n"
		end
		if opm.empty?
		    opmerking = "#{indent}      <avmat:opmerkingen rdf:parseType=\"Literal\" />"
		else
		    opmerking = "#{indent}      <avmat:opmerkingen rdf:parseType=\"Literal\">#{opm}</avmat:opmerkingen>"
		end
		output =<<EOF
#{indent}    <avmat:persoon>
#{persoon}#{opmerking}
#{indent}    </avmat:persoon>
EOF
		@output.puts output
	    end
	    @output.puts "#{indent}  </rdf:Seq>"
	    @output.puts "#{indent}</avmat:personen>"
	    @new_line = true
	end
	@in_persoon = false
    end

    def thema_start attrs
	@current_tag = "#{@indent}<avmat:#{name}>"
	@in_thema = true
    end

#    def thema_end
#	unless @current_tag.empty?
#	    @output.puts "#{@indent}<fc:#{name} />"
#	else
#	    @output.puts "</avmat:#{name}>"
#	end
#	@indent = @indent[0..-3]
#	@current_tag = ""
#	@in_thema = false
#    end

    def subthema_start attrs
	@current_tag = "#{@indent}<avmat:#{name}>"
	@in_thema = true
    end

#    def subthema_end
#	unless @current_tag.empty?
#	    @output.puts "#{@indent}<fc:#{name} />"
#	else
#	    @output.puts "</avmat:#{name}>"
#	end
#	@indent = @indent[0..-3]
#	@current_tag = ""
#	@in_thema = false
#    end

    def matsoort_start attrs
	@output.puts "#{indent}<avmat:matsoort>"
	@tags.push "rdf:Seq"
	@newline = true
	@output.puts "#{indent}<rdf:Seq>"
    end

    def matsoort_end
	@output.puts "#{indent}</rdf:Seq>"
	@tags.pop
	@newline = true
	@output.puts "#{indent}</avmat:matsoort>"
    end

    def literal name
	@output.write "#{@indent}<avmat:#{name} rdf:parseType=\"Literal\">"
	@new_line = false
    end

    def aantekeningen_start attrs
	literal "aantekeningen"
    end

    def beschrijving_start attrs
	literal "beschrijving"
    end

    def kosten_start attrs
	literal "kosten"
    end

    def maker_start attrs
	literal "maker"
    end

    def naambestand_start attrs
	literal "naambestand"
    end

    def opmerkingen_start attrs
	literal "opmerkingen" unless @in_persoon
    end

    def indent
	@new_line ? @indent = "  " * (@tags.size) : @indent = ""
    end

    def tag_start(name,attrs)
	@tags.push name
	begin
	    result = self.send( "#{name}_start", attrs )
	    rescue => detail
	#	STDERR.puts "rescue start: #{detail}" if name.match(/perso/)
		unless @current_tag.empty? || @in_persoon
		    @output.puts @current_tag
		    @new_line = true
		    @current_tag = ""
		end
		if @current_tag.empty?
		    @current_tag = "#{indent}<avmat:#{name}>" unless @in_persoon
		end
	    end
	return result
    end

    def text( text )
	text.strip!
	unless text.empty?
	    if @in_commissie
		commissie = text
		if @commissies.has_key?(commissie)
		    @zitting_in << @commissies[commissie]
		else
		    @zitting_in << "C00"
		    STDERR.puts "not found: #{commissie}"
		end
	    elsif @in_persoon
		if current.eql?("persoon")
		    person = find_person text
		  if !person.nil?
		      @personen << [person,""]
		  else
		      @personen << ["P000","<p>#{text}</p>"]
		  end
		elsif current.eql?("opmerkingen")
		    persoon,tekst = @personen.pop
		    text = "#{tekst}#{text}" if !tekst.empty?
		    @personen << [persoon,text]
		end
	    else
		if !@current_tag.empty?
		    @output.write @current_tag
		    @new_line = false
		    @current_tag = ""
		end
		@output.write "#{text.strip}"
		@new_line = false
	    end
	end
	@text << text if !text.strip.empty?
    end

    def tag_end(name)
	begin
	    result = self.send( "#{name}_end" )
	rescue => detail
	    STDERR.puts "rescue end: #{detail}" if name.match(/commissie/)
	    if !@in_persoon
		if !@current_tag.empty?
		    @output.puts "#{indent}<fc:#{name} />"
		else
		    @output.puts "#{indent}</avmat:#{name}>"
		end
	    end
	    @new_line = true
	end
	@tags.pop
#	@output.write "#{indent}" unless @text.empty?
	@current_tag = ""
	@text = ""
	return result
    end

    def put_out( arg )
	arg
    end

end

def read_commissies
    names = Hash.new
    File.open("commissies.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    line.strip!
	    if !line.empty?
		name,id = line.split(/: /)
		names[name] = id.strip
	    end
	end
    end
    names
end

def read_personen
    names = Hash.new
    File.open("personen.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    line.strip!
	    if !line.empty?
		name,id = line.split(/: /)
		names[name] = id.strip
	    end
	end
    end
    names
end

def read_keywords
    names = Hash.new
    File.open("keywords.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    line.strip!
	    if !line.empty?
		name,id = line.split(/: /)
		names[name] = id.strip
	    end
	end
    end
    names
end

if __FILE__ == $0

    STDERR.puts "parser voor avmat en, later, formulierselectie (deelproject3)"
    STDERR.puts "deze beiden bevatten keywords (thema's en subthema's"
    
    inputfile = ""
    directory = ""
    resource = "https://resource.huygens.knaw.nl/ingforms/const_comm"
    outputfilename = ""

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    when '-i' then begin inputfile = ARGV[i+1] end
	    when '-d' then begin directory = ARGV[i+1] end
	    when '-o' then begin outputfilename = ARGV[i+1] end
	    when '-r' then begin resource = ARGV[i+1] end
	    when '-h' then
		begin
		    STDERR.puts "use: ruby parser [-i input|-d directory] -o output"
		    exit(0)
		end
	    end
    end

    if (inputfile.empty? && directory.empty?) || outputfilename.empty?
	STDERR.puts "use: ruby parser [-i input|-d directory] -o output"
	exit(1)
    end

    keywords = read_keywords
    personen = read_personen
    commissies = read_commissies
    outputfile = File.new(outputfilename,"w")

    if directory.empty?
	Parser.parseFile(inputfile,output,names,1)
    else
	if File.directory?(directory)
	    rdf_rdf =<<EOF
<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:fc="https://resource.huygens.knaw.nl/constitutionele_commissies/fc"
    xmlns:person="https://resource.huygens.knaw.nl/constitutionele_commissies/person"
    xmlns:keyword="https://resource.huygens.knaw.nl/constitutionele_commissies/keyword"
    xmlns:avmat="https://resource.huygens.knaw.nl/constitutionele_commissies/avmat">

EOF
	    outputfile.puts rdf_rdf
	    teller = 0 
	    wd = Dir.getwd
	    Dir.chdir(directory)
	    file_list = Dir.glob("**/*.xml")
	    file_list.each do |filename|
#		STDERR.puts filename
		teller = Parser.parseFile(filename,outputfile,keywords,personen,commissies,resource,teller)
	    end
	    Dir.chdir(wd)

	end
    end

    outputfile.puts "\n</rdf:RDF>"

end

