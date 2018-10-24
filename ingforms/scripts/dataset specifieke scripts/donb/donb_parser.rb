require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,outputfilename,collection,afk,number)
        listener = MyListener.new(outputfilename,collection,afk,number)
        source = File.new File.expand_path(inputfilename)
        Document.parse_stream(source, listener)
        listener.closing_lines
        source.close
    end

    def Parser.parseString(id,xml,output_file,collection,afk)
        listener = MyListener.new(output_file,collection,afk,1)
        Document.parse_stream(xml, listener)
    end

end


class MyListener
    include StreamListener

    def closing_lines
        rdf_rdf =<<EOF
  </rdf:Description>

EOF
#        @output.puts rdf_rdf
#        @output.puts
    end

    def initialize(outputfile,collection,afk,number)
        @output = outputfile
        @level = 1
        @indent = ""
        @collection = collection
        @afk = afk
        @number = number
        @seq = ""
        @in_datum = false
        @in_dag = false
        @dag = ""
        @in_maand = false
        @maand = ""
        @in_jaar = false
        @jaar = ""
	@in_vertaling = false
	@in_oorkonde = false
	@in_nummer = false
	@nummer = ""
    end

    def vertaling_start attrs
        put_out "\n#{@indent}<#{@afk}:vertaling>"
    end

    def vertaling_end
        put_out "</#{@afk}:vertaling>"
    end

    def oorkonde_start attrs
        put_out "\n#{@indent}<#{@afk}:oorkonde>"
    end

    def oorkonde_end
        put_out "</#{@afk}:oorkonde>"
    end

    def vertaling_start attrs
        put_out "\n#{@indent}<#{@afk}:vertaling>"
    end

    def vertaling_end
        put_out "</#{@afk}:vertaling>"
    end

    def nummer_start attrs
        put_out "\n#{@indent}<#{@afk}:nummer>"
	@in_nummer = true
	@nummer = ""
    end

    def nummer_end
        put_out "</#{@afk}:nummer>"
	put_out "\n#{@indent}<schema:title>#{@nummer}</schema:title>"
	@in_nummer = false
	@nummer = ""
    end

    def uitgave_start attrs
        put_out "\n#{@indent}<#{@afk}:uitgave rdf:parseType=\"Literal\">"
    end

    def uitgave_end
        put_out "</#{@afk}:uitgave>"
    end

    def regest_start attrs
        put_out "\n#{@indent}<#{@afk}:regest rdf:parseType=\"Literal\">"
    end

    def regest_end
        put_out "</#{@afk}:regest>"
    end

    def tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:tekst rdf:parseType=\"Literal\">"
    end

    def tekst_end
        put_out "</#{@afk}:tekst>"
    end

    def vertaling_start attrs
        put_out "\n#{@indent}<#{@afk}:vertaling rdf:parseType=\"Literal\">"
    end

    def vertaling_end
        put_out "</#{@afk}:vertaling>"
    end

    def noten_start attrs
        put_out "\n#{@indent}<#{@afk}:noten rdf:parseType=\"Literal\">"
    end

    def noten_end
        put_out "</#{@afk}:noten>"
    end

    def logo_start attrs
        put_out "\n#{@indent}<#{@afk}:logo rdf:parseType=\"Literal\">"
    end

    def logo_end
        put_out "</#{@afk}:logo>"
    end

    def afbeelding_start attrs
	if @in_vertaling
	    put_out "\n#{@indent}<#{@afk}:afbeelding>"
	else
	    put_out "\n#{@indent}<#{@afk}:afbeeldingen>"
	    put_out "\n#{@indent}<rdf:Seq>"
	end
    end

    def afbeelding_end
	if @in_vertaling
	    put_out "</#{@afk}:afbeelding>"
	else
  	    @output.puts "\n#{@indent}</rdf:Seq>"
	    indent = "  " * (@level - 1)
	    put_out "#{indent}"
	    put_out "</#{@afk}:afbeeldingen>"
	end
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def bewerker_start attrs
        put_out "\n#{@indent}<#{@afk}:bewerker>"
    end

    def bewerker_end
        put_out "</#{@afk}:bewerker>"
    end

    def publicatie_start attrs
        put_out "\n#{@indent}<#{@afk}:publicatie>"
    end

    def publicatie_end
        put_out "</#{@afk}:publicatie>"
    end

    def aantekening_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekening rdf:parseType=\"Literal\">"
    end

    def aantekening_end
        put_out "</#{@afk}:aantekening>"
    end

    def oorkonde_start attrs
        put_out "\n#{@indent}<#{@afk}:oorkonde>"
    end

    def oorkonde_end
        put_out "</#{@afk}:oorkonde>"
    end

    def datum_start attrs
        put_out "\n#{@indent}<#{@afk}:datum rdf:parseType=\"Literal\">"
    end

    def datum_end
        put_out "</#{@afk}:datum>"
    end

    def plaats_start attrs
        put_out "\n#{@indent}<#{@afk}:plaats rdf:parseType=\"Literal\">"
    end

    def plaats_end
        put_out "</#{@afk}:plaats>"
    end

    def origineel_start attrs
        put_out "\n#{@indent}<#{@afk}:origineel rdf:parseType=\"Literal\">"
    end

    def origineel_end
        put_out "</#{@afk}:origineel>"
    end

    def originelen_start attrs
        put_out "\n#{@indent}<#{@afk}:originelen rdf:parseType=\"Literal\">"
    end

    def originelen_end
        put_out "</#{@afk}:originelen>"
    end

    def sorigineel_start attrs
        put_out "\n#{@indent}<#{@afk}:sorigineel rdf:parseType=\"Literal\">"
    end

    def sorigineel_end
        put_out "</#{@afk}:sorigineel>"
    end

    def dorsalens_start attrs
        put_out "\n#{@indent}<#{@afk}:dorsalens>"
    end

    def dorsalens_end
        put_out "</#{@afk}:dorsalens>"
    end

    def afschrift_start attrs
        put_out "\n#{@indent}<#{@afk}:afschrift rdf:parseType=\"Literal\">"
    end

    def afschrift_end
        put_out "</#{@afk}:afschrift>"
    end

    def afschriften_start attrs
        put_out "\n#{@indent}<#{@afk}:afschriften rdf:parseType=\"Literal\">"
    end

    def afschriften_end
        put_out "</#{@afk}:afschriften>"
    end

    def deperditum_start attrs
        put_out "\n#{@indent}<#{@afk}:deperditum rdf:parseType=\"Literal\">"
    end

    def deperditum_end
        put_out "</#{@afk}:deperditum>"
    end

    def uitgaven_start attrs
        put_out "\n#{@indent}<#{@afk}:uitgaven rdf:parseType=\"Literal\">"
    end

    def uitgaven_end
        put_out "</#{@afk}:uitgaven>"
    end

    def regesten_start attrs
        put_out "\n#{@indent}<#{@afk}:regesten rdf:parseType=\"Literal\">"
    end

    def regesten_end
        put_out "</#{@afk}:regesten>"
    end

    def regesten2_start attrs
        put_out "\n#{@indent}<#{@afk}:regesten2 rdf:parseType=\"Literal\">"
    end

    def regesten2_end
        put_out "</#{@afk}:regesten2>"
    end

    def onechtheid_start attrs
        put_out "\n#{@indent}<#{@afk}:onechtheid rdf:parseType=\"Literal\">"
    end

    def onechtheid_end
        put_out "</#{@afk}:onechtheid>"
    end

    def overlevering_start attrs
        put_out "\n#{@indent}<#{@afk}:overlevering rdf:parseType=\"Literal\">"
    end

    def overlevering_end
        put_out "</#{@afk}:overlevering>"
    end

    def dateverv_start attrs
        put_out "\n#{@indent}<#{@afk}:dateverv rdf:parseType=\"Literal\">"
    end

    def dateverv_end
        put_out "</#{@afk}:dateverv>"
    end

    def samenhang_start attrs
        put_out "\n#{@indent}<#{@afk}:samenhang rdf:parseType=\"Literal\">"
    end

    def samenhang_end
        put_out "</#{@afk}:samenhang>"
    end

    def tekstuitgave_start attrs
        put_out "\n#{@indent}<#{@afk}:tekstuitgave rdf:parseType=\"Literal\">"
    end

    def tekstuitgave_end
        put_out "</#{@afk}:tekstuitgave>"
    end

    def ontstaan_start attrs
        put_out "\n#{@indent}<#{@afk}:ontstaan rdf:parseType=\"Literal\">"
    end

    def ontstaan_end
        put_out "</#{@afk}:ontstaan>"
    end

    def ontstaan_uitgave_start attrs
        put_out "\n#{@indent}<#{@afk}:ontstaan_uitgave rdf:parseType=\"Literal\">"
    end

    def ontstaan_uitgave_end
        put_out "</#{@afk}:ontstaan_uitgave>"
    end

    def ontstaan_algemeen_start attrs
        put_out "\n#{@indent}<#{@afk}:ontstaan_algemeen rdf:parseType=\"Literal\">"
    end

    def ontstaan_algemeen_end
        put_out "</#{@afk}:ontstaan_algemeen>"
    end

    def lokalisering_start attrs
        put_out "\n#{@indent}<#{@afk}:lokalisering rdf:parseType=\"Literal\">"
    end

    def lokalisering_end
        put_out "</#{@afk}:lokalisering>"
    end

    def datering_start attrs
        put_out "\n#{@indent}<#{@afk}:datering rdf:parseType=\"Literal\">"
    end

    def datering_end
        put_out "</#{@afk}:datering>"
    end

    def transfix_start attrs
        put_out "\n#{@indent}<#{@afk}:transfix>"
    end

    def transfix_end
        put_out "</#{@afk}:transfix>"
    end

    def Afbeelding_start attrs
        put_out "\n#{@indent}<#{@afk}:Afbeelding rdf:parseType=\"Resource\">"
    end

    def Afbeelding_end
        put_out "</#{@afk}:Afbeelding>"
    end

    def bestand_start attrs
        put_out "\n#{@indent}<#{@afk}:bestand>"
    end

    def bestand_end
        put_out "</#{@afk}:bestand>"
    end

    def meta_start attrs
        put_out "\n#{@indent}<#{@afk}:meta>"
    end

    def meta_end
        put_out "</#{@afk}:meta>"
    end

    def opname_start attrs
        put_out "\n#{@indent}<#{@afk}:opname>"
    end

    def opname_end
        put_out "</#{@afk}:opname>"
    end

    def transcriptie_start attrs
        put_out "\n#{@indent}<#{@afk}:transcriptie rdf:parseType=\"Literal\">"
    end

    def transcriptie_end
        put_out "</#{@afk}:transcriptie>"
    end

    def retro_start attrs
        put_out "\n#{@indent}<#{@afk}:retro>"
    end

    def retro_end
        put_out "</#{@afk}:retro>"
    end

    def namen_start attrs
        put_out "\n#{@indent}<#{@afk}:namen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def namen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:namen>"
    end

    def naam_start attrs
        put_out "\n#{@indent}<#{@afk}:naam>"
    end

    def naam_end
        put_out "</#{@afk}:naam>"
    end

    def table
       	{}
    end

    def tag_start(name,attrs)
        if table.has_key? name
            name = table[name][@level] if table[name].has_key?(@level)
        end
        if table.has_key? name
            name = table[name][0] if table[name][1]==@level
        end
        if @level==1
	    @in_vertaling = true if name.eql?("vertaling")
	    @in_oorkonde = true if name.eql?("oorkonde")
#            code = "#{name[0].upcase}#{@number}"
            code = sprintf("%s%06d",name[0].upcase,@number)
        lines =<<EOF


  <rdf:Description rdf:about="https://resource.huygens.knaw.nl/ingforms/#{@collection}/#{name}/#{code}">
    <rdf:type rdf:resource="https://resource.huygens.knaw.nl/ingforms/#{@collection}/#{name}" />
EOF
            put_out lines
        else
            begin
                result = self.send( "#{name}_start", attrs )
                rescue => detail
#                    STDERR.puts "#{detail}\nin #{name}"
                end
#            return result
        end
        @level += 1
        @indent = "  " * @level
    end

    def text( text )
        unless text.strip.empty?
	    text.gsub!(/&nbsp;/,"&#160;")
	    text.gsub!(/(\s)&(\s)/,"\\1&amp;\\2")
	    text.gsub!(/([a-zA-Z])&([a-zA-Z])/,"\\1&amp;\\2")
	    text.gsub!(/&amp;amp;/,"&amp;")
	    text.gsub!(/<br ([^>]*)>/,"<br \\1/>")
	    text.gsub!("//>","/>")
	    text.gsub!("<","&lt;")
	    text.gsub!(">","&gt;")
	    text.gsub!(/&lt;(\/?)p&gt;/,"<\\1p>")
#	    text.gsub!(/&lt;([^&]*)&gt;/,"<\\1>")
	    if @in_jaar
		@jaar = text.strip
	    elsif @in_maand
		@maand = text.strip
	    elsif @in_dag
		@dag = text.strip
	    else
		put_out "#{text.strip}"
	    end
	    @nummer = text.strip if @in_nummer
#            @text << text
        end
    end

    def tag_end(name)
        if table.has_key? name
            name = table[name][@level-1] if table[name].has_key?(@level-1)
        end
        if @level==2
            @output.puts "\n  </rdf:Description>"
        else
            begin
                result = self.send( "#{name}_end" )
                rescue => detail
#                    STDERR.puts "end: #{detail}\nin #{name}"
                end
#            return result
        end
        @level -= 1
        @indent = "  " * @level
    end

    def put_out( arg )
        @output.write arg
        arg
    end

    def verwerk_datum
        if !@maand.empty?
 	    maand = sprintf("-%02d",@maand.to_i)
        end
        if !@dag.empty?
 	    dag = sprintf("-%02d",@dag.to_i)
        end
        return "#{@jaar}#{maand}#{dag}"
    end

end

def help_message
    STDERR.puts "use: ruby parser -d directory -c collection -o output"
    exit(0)
end

if __FILE__ == $0

    inputfile = ""
    directory = ""
    outputfile = ""
    collection = ""
    # evt aanpassen:
    resource = "https://resource.huygens.knaw.nl/ingforms/const_comm"

    (0..(ARGV.size-1)).each do |i|
        case ARGV[i]
            # voeg start en stop tags toe
            when '-i' then begin inputfile = ARGV[i+1] end
            when '-d' then begin directory = ARGV[i+1] end
            when '-c' then begin collection = ARGV[i+1] end
            when '-o' then begin outputfile = ARGV[i+1] end
            when '-r' then begin resource = ARGV[i+1] end
            when '-h' then begin help_message end
        end
    end

    if directory.empty? || outputfile.empty? || collection.empty?
        help_message
    end

    afk = collection[0]
    output = File.new(outputfile,"w")
    # aanpassen:
    rdf_rdf =<<EOF
<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:#{afk}="https://resource.huygens.knaw.nl/#{collection}/#{afk}"
    xmlns:schema="http://schema.org/">
EOF

    output.puts rdf_rdf

    if File.directory?(directory)
        number = 1
        wd = Dir.getwd
        Dir.chdir(directory)
        file_list = Dir.glob("**/*.xml")
        file_list.each do |filename|
            #STDERR.puts filename
            Parser.parseFile(filename,output,collection,afk,number)
            number += 1
        end

    end
    
    rdf_rdf =<<EOF

</rdf:RDF>

EOF

    output.puts rdf_rdf
    
end

