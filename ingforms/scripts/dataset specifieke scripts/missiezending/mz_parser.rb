require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,outputfilename,collection,afk,number)
	begin
        listener = MyListener.new(outputfilename,collection,afk,number)
        source = File.new File.expand_path(inputfilename)
        Document.parse_stream(source, listener)
        listener.closing_lines
        source.close
	rescue => any
#	    STDERR.puts any
	    STDERR.puts "FOUT in:"
	    STDERR.puts inputfilename
#	    exit 1
	end
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
    end

    def naam_start attrs
	if @level==2
	    put_out "\n#{@indent}<schema:name>"
	else
	    put_out "\n#{@indent}<#{@afk}:naam>"
	end
    end

    def naam_end
	if @level==3
  	    put_out "</schema:name>"
	else
	    put_out "</#{@afk}:naam>"
	end
    end

    def alternatieve_namen_start attrs
        put_out "\n#{@indent}<#{@afk}:alternatieve_namen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def alternatieve_namen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:alternatieve_namen>"
    end

    def namen_start attrs
        put_out "\n#{@indent}<#{@afk}:namen rdf:parseType=\"Resource\">"
    end

    def namen_end
        put_out "</#{@afk}:namen>"
    end

    def periode_start attrs
        put_out "\n#{@indent}<#{@afk}:periode>"
    end

    def periode_end
        put_out "</#{@afk}:periode>"
    end

    def denominatie_start attrs
        put_out "\n#{@indent}<#{@afk}:denominatie>"
    end

    def denominatie_end
        put_out "</#{@afk}:denominatie>"
    end

    def korte_geschiedenis_start attrs
        put_out "\n#{@indent}<#{@afk}:korte_geschiedenis rdf:parseType=\"Literal\">"
    end

    def korte_geschiedenis_end
        put_out "</#{@afk}:korte_geschiedenis>"
    end

    def korte_geschiedenis_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:korte_geschiedenis_eng rdf:parseType=\"Literal\">"
    end

    def korte_geschiedenis_eng_end
        put_out "</#{@afk}:korte_geschiedenis_eng>"
    end

    def organisatie_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie rdf:parseType=\"Literal\">"
    end

    def organisatie_end
        put_out "</#{@afk}:organisatie>"
    end

    def organisatie_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie_eng rdf:parseType=\"Literal\">"
    end

    def organisatie_eng_end
        put_out "</#{@afk}:organisatie_eng>"
    end

    def taken_activiteiten_start attrs
        put_out "\n#{@indent}<#{@afk}:taken_activiteiten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def taken_activiteiten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:taken_activiteiten>"
    end

    def taak_activiteit_start attrs
        put_out "\n#{@indent}<#{@afk}:taak_activiteit>"
    end

    def taak_activiteit_end
        put_out "</#{@afk}:taak_activiteit>"
    end

    def voorloper_start attrs
        put_out "\n#{@indent}<#{@afk}:voorloper>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def voorloper_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:voorloper>"
    end

    def voorlopers_start attrs
        put_out "\n#{@indent}<#{@afk}:voorlopers rdf:parseType=\"Resource\">"
    end

    def voorlopers_end
        put_out "</#{@afk}:voorlopers>"
    end

    def opvolger_start attrs
        put_out "\n#{@indent}<#{@afk}:opvolger>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def opvolger_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:opvolger>"
    end

    def opvolgers_start attrs
        put_out "\n#{@indent}<#{@afk}:opvolgers rdf:parseType=\"Resource\">"
    end

    def opvolgers_end
        put_out "</#{@afk}:opvolgers>"
    end

    def doelstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:doelstelling rdf:parseType=\"Literal\">"
    end

    def doelstelling_end
        put_out "</#{@afk}:doelstelling>"
    end

    def continenten_start attrs
        put_out "\n#{@indent}<#{@afk}:continenten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def continenten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:continenten>"
    end

    def continent_start attrs
        put_out "\n#{@indent}<#{@afk}:continent>"
    end

    def continent_end
        put_out "</#{@afk}:continent>"
    end

    def lokatie_activiteiten_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_activiteiten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def lokatie_activiteiten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:lokatie_activiteiten>"
    end

    def Lokatie_start attrs
        put_out "\n#{@indent}<#{@afk}:Lokatie rdf:parseType=\"Resource\">"
    end

    def Lokatie_end
        put_out "</#{@afk}:Lokatie>"
    end

    def lokatie_1_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_1>"
    end

    def lokatie_1_end
        put_out "</#{@afk}:lokatie_1>"
    end

    def lokatie_2a_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2a>"
    end

    def lokatie_2a_end
        put_out "</#{@afk}:lokatie_2a>"
    end

    def lokatie_2b_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2b>"
    end

    def lokatie_2b_end
        put_out "</#{@afk}:lokatie_2b>"
    end

    def lokatie_2c_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2c>"
    end

    def lokatie_2c_end
        put_out "</#{@afk}:lokatie_2c>"
    end

    def lokatie_2d_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2d>"
    end

    def lokatie_2d_end
        put_out "</#{@afk}:lokatie_2d>"
    end

    def lokatie_2e_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2e>"
    end

    def lokatie_2e_end
        put_out "</#{@afk}:lokatie_2e>"
    end

    def lokatie_2f_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2f>"
    end

    def lokatie_2f_end
        put_out "</#{@afk}:lokatie_2f>"
    end

    def lokatie_2g_start attrs
        put_out "\n#{@indent}<#{@afk}:lokatie_2g>"
    end

    def lokatie_2g_end
        put_out "</#{@afk}:lokatie_2g>"
    end

    def literatuurlijst_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuurlijst>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def literatuurlijst_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:literatuurlijst>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Resource\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def ppn_start attrs
        put_out "\n#{@indent}<#{@afk}:ppn>"
    end

    def ppn_end
        put_out "</#{@afk}:ppn>"
    end

    def title_start attrs
        put_out "\n#{@indent}<#{@afk}:title>"
    end

    def title_end
        put_out "</#{@afk}:title>"
    end

    def author_start attrs
        put_out "\n#{@indent}<#{@afk}:author>"
    end

    def author_end
        put_out "</#{@afk}:author>"
    end

    def published_in_start attrs
        put_out "\n#{@indent}<#{@afk}:published_in>"
    end

    def published_in_end
        put_out "</#{@afk}:published_in>"
    end

    def series_start attrs
        put_out "\n#{@indent}<#{@afk}:series>"
    end

    def series_end
        put_out "</#{@afk}:series>"
    end

    def paginering_start attrs
        put_out "\n#{@indent}<#{@afk}:paginering>"
    end

    def paginering_end
        put_out "</#{@afk}:paginering>"
    end

    def publisher_start attrs
        put_out "\n#{@indent}<#{@afk}:publisher>"
    end

    def publisher_end
        put_out "</#{@afk}:publisher>"
    end

    def year_start attrs
        put_out "\n#{@indent}<#{@afk}:year>"
    end

    def year_end
        put_out "</#{@afk}:year>"
    end

    def url_start attrs
        put_out "\n#{@indent}<#{@afk}:url>"
    end

    def url_end
        put_out "</#{@afk}:url>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def protected_start attrs
        put_out "\n#{@indent}<#{@afk}:protected>"
    end

    def protected_end
        put_out "</#{@afk}:protected>"
    end

    def bronnenpublicatie_start attrs
        put_out "\n#{@indent}<#{@afk}:bronnenpublicatie>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def bronnenpublicatie_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:bronnenpublicatie>"
    end

    def bron_start attrs
        put_out "\n#{@indent}<#{@afk}:bron rdf:parseType=\"Resource\">"
    end

    def bron_end
        put_out "</#{@afk}:bron>"
    end

    def periodieken_start attrs
        put_out "\n#{@indent}<#{@afk}:periodieken>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def periodieken_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:periodieken>"
    end

    def periodiek_start attrs
        put_out "\n#{@indent}<#{@afk}:periodiek rdf:parseType=\"Resource\">"
    end

    def periodiek_end
        put_out "</#{@afk}:periodiek>"
    end

    def kommissie_memmoires_start attrs
        put_out "\n#{@indent}<#{@afk}:kommissie_memmoires rdf:parseType=\"Literal\">"
    end

    def kommissie_memmoires_end
        put_out "</#{@afk}:kommissie_memmoires>"
    end

    def archieven_start attrs
        put_out "\n#{@indent}<#{@afk}:archieven>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def archieven_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:archieven>"
    end

    def archief_start attrs
        put_out "\n#{@indent}<#{@afk}:archief rdf:parseType=\"Resource\">"
    end

    def archief_end
        put_out "</#{@afk}:archief>"
    end

    def beschrijving_start attrs
        put_out "\n#{@indent}<#{@afk}:beschrijving rdf:parseType=\"Literal\">"
    end

    def beschrijving_end
        put_out "</#{@afk}:beschrijving>"
    end

    def beschrijving_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:beschrijving_eng rdf:parseType=\"Literal\">"
    end

    def beschrijving_eng_end
        put_out "</#{@afk}:beschrijving_eng>"
    end

    def bewaarplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:bewaarplaats>"
    end

    def bewaarplaats_end
        put_out "</#{@afk}:bewaarplaats>"
    end

    def periode_archief_start attrs
        put_out "\n#{@indent}<#{@afk}:periode_archief>"
    end

    def periode_archief_end
        put_out "</#{@afk}:periode_archief>"
    end

    def openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid>"
    end

    def openbaarheid_end
        put_out "</#{@afk}:openbaarheid>"
    end

    def opm_openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:opm_openbaarheid rdf:parseType=\"Literal\">"
    end

    def opm_openbaarheid_end
        put_out "</#{@afk}:opm_openbaarheid>"
    end

    def omvang_start attrs
        put_out "\n#{@indent}<#{@afk}:omvang>"
    end

    def omvang_end
        put_out "</#{@afk}:omvang>"
    end

    def toegang_soort_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang_soort>"
    end

    def toegang_soort_end
        put_out "</#{@afk}:toegang_soort>"
    end

    def opm_toegang_soort_start attrs
        put_out "\n#{@indent}<#{@afk}:opm_toegang_soort>"
    end

    def opm_toegang_soort_end
        put_out "</#{@afk}:opm_toegang_soort>"
    end

    def toegang_titel_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang_titel>"
    end

    def toegang_titel_end
        put_out "</#{@afk}:toegang_titel>"
    end

    def subarchief_van_start attrs
        put_out "\n#{@indent}<#{@afk}:subarchief_van rdf:parseType=\"Literal\">"
    end

    def subarchief_van_end
        put_out "</#{@afk}:subarchief_van>"
    end

    def relevantie_start attrs
        put_out "\n#{@indent}<#{@afk}:relevantie rdf:parseType=\"Literal\">"
    end

    def relevantie_end
        put_out "</#{@afk}:relevantie>"
    end

    def av_mat_start attrs
        put_out "\n#{@indent}<#{@afk}:av_mat rdf:parseType=\"Literal\">"
    end

    def av_mat_end
        put_out "</#{@afk}:av_mat>"
    end

    def websites_start attrs
        put_out "\n#{@indent}<#{@afk}:websites rdf:parseType=\"Literal\">"
    end

    def websites_end
        put_out "</#{@afk}:websites>"
    end

    def bronnen_verslaglegging_start attrs
        put_out "\n#{@indent}<#{@afk}:bronnen_verslaglegging rdf:parseType=\"Literal\">"
    end

    def bronnen_verslaglegging_end
        put_out "</#{@afk}:bronnen_verslaglegging>"
    end

    def nadere_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:nadere_toegang rdf:parseType=\"Literal\">"
    end

    def nadere_toegang_end
        put_out "</#{@afk}:nadere_toegang>"
    end

    def verwijzing_start attrs
        put_out "\n#{@indent}<#{@afk}:verwijzing rdf:parseType=\"Literal\">"
    end

    def verwijzing_end
        put_out "</#{@afk}:verwijzing>"
    end

    def losse_archiefstukken_start attrs
        put_out "\n#{@indent}<#{@afk}:losse_archiefstukken rdf:parseType=\"Literal\">"
    end

    def losse_archiefstukken_end
        put_out "</#{@afk}:losse_archiefstukken>"
    end

    def verwijzing_link_start attrs
        put_out "\n#{@indent}<#{@afk}:verwijzing_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verwijzing_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verwijzing_link>"
    end

    def relation_start attrs
        put_out "\n#{@indent}<#{@afk}:relation>"
    end

    def relation_end
        put_out "</#{@afk}:relation>"
    end

    def bewerkers_start attrs
        put_out "\n#{@indent}<#{@afk}:bewerkers>"
    end

    def bewerkers_end
        put_out "</#{@afk}:bewerkers>"
    end

    def informatiewaarde_start attrs
        put_out "\n#{@indent}<#{@afk}:informatiewaarde>"
    end

    def informatiewaarde_end
        put_out "</#{@afk}:informatiewaarde>"
    end

    def datum_laatste_wijziging_start attrs
        put_out "\n#{@indent}<#{@afk}:datum_laatste_wijziging>"
    end

    def datum_laatste_wijziging_end
        put_out "</#{@afk}:datum_laatste_wijziging>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon>"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def biografie_start attrs
        put_out "\n#{@indent}<#{@afk}:biografie rdf:parseType=\"Literal\">"
    end

    def biografie_end
        put_out "</#{@afk}:biografie>"
    end

    def biografie_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:biografie_eng rdf:parseType=\"Literal\">"
    end

    def biografie_eng_end
        put_out "</#{@afk}:biografie_eng>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def titel_end
        put_out "</schema:title>"
    end

    def tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:tekst rdf:parseType=\"Literal\">"
    end

    def tekst_end
        put_out "</#{@afk}:tekst>"
    end

    def annotatie_start attrs
        put_out "\n#{@indent}<#{@afk}:annotatie>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def annotatie_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:annotatie>"
    end

    def anno_start attrs
        put_out "\n#{@indent}<#{@afk}:anno rdf:parseType=\"Resource\">"
    end

    def anno_end
        put_out "</#{@afk}:anno>"
    end

    def ankernaam_start attrs
        put_out "\n#{@indent}<#{@afk}:ankernaam>"
    end

    def ankernaam_end
        put_out "</#{@afk}:ankernaam>"
    end

    def annotatie_tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:annotatie_tekst rdf:parseType=\"Literal\">"
    end

    def annotatie_tekst_end
        put_out "</#{@afk}:annotatie_tekst>"
    end

    def table
       	{"Naam"=>{3=>"namen"}, "voorloper"=>{3=>"voorlopers"}, "opvolger"=>{3=>"opvolgers"}, "literatuur"=>{2=>"literatuurlijst"}, "archief"=>{2=>"archieven"}}
    end

    def tag_start(name,attrs)
        if table.has_key? name
            name = table[name][@level] if table[name].has_key?(@level)
        end
        if table.has_key? name
            name = table[name][0] if table[name][1]==@level
        end
        if @level==1
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
            put_out "#{text.strip}"
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

