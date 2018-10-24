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
    end

    def instelling_start attrs
        put_out "\n#{@indent}<#{@afk}:instelling>"
    end

    def instelling_end
        put_out "</#{@afk}:instelling>"
    end

    def naam_archiefvormer_start attrs
        put_out "\n#{@indent}<schema:name>"
    end

    def naam_archiefvormer_end
        put_out "</schema:name>"
    end

    def naam_varianten_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_varianten rdf:parseType=\"Literal\">"
    end

    def naam_varianten_end
        put_out "</#{@afk}:naam_varianten>"
    end

    def naam_varianten_link_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_varianten_link>"
    end

    def naam_varianten_link_end
        put_out "</#{@afk}:naam_varianten_link>"
    end

    def land_herkomst_start attrs
        put_out "\n#{@indent}<#{@afk}:land_herkomst>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def land_herkomst_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:land_herkomst>"
    end

    def land_start attrs
        put_out "\n#{@indent}<#{@afk}:land>"
    end

    def land_end
        put_out "</#{@afk}:land>"
    end

    def periode_van_bestaan_start attrs
        put_out "\n#{@indent}<#{@afk}:periode_van_bestaan>"
    end

    def periode_van_bestaan_end
        put_out "</#{@afk}:periode_van_bestaan>"
    end

    def organisatie_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie rdf:parseType=\"Literal\">"
    end

    def organisatie_end
        put_out "</#{@afk}:organisatie>"
    end

    def organisatie_link_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def organisatie_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:organisatie_link>"
    end

    def relation_start attrs
        put_out "\n#{@indent}<#{@afk}:relation>"
    end

    def relation_end
        put_out "</#{@afk}:relation>"
    end

    def taak_start attrs
        put_out "\n#{@indent}<#{@afk}:taak rdf:parseType=\"Literal\">"
    end

    def taak_end
        put_out "</#{@afk}:taak>"
    end

    def taak_link_start attrs
        put_out "\n#{@indent}<#{@afk}:taak_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def taak_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:taak_link>"
    end

    def voorloper_start attrs
        put_out "\n#{@indent}<#{@afk}:voorloper rdf:parseType=\"Literal\">"
    end

    def voorloper_end
        put_out "</#{@afk}:voorloper>"
    end

    def voorloper_link_start attrs
        put_out "\n#{@indent}<#{@afk}:voorloper_link>"
    end

    def voorloper_link_end
        put_out "</#{@afk}:voorloper_link>"
    end

    def opvolger_start attrs
        put_out "\n#{@indent}<#{@afk}:opvolger rdf:parseType=\"Literal\">"
    end

    def opvolger_end
        put_out "</#{@afk}:opvolger>"
    end

    def opvolger_link_start attrs
        put_out "\n#{@indent}<#{@afk}:opvolger_link>"
    end

    def opvolger_link_end
        put_out "</#{@afk}:opvolger_link>"
    end

    def typering_instelling_start attrs
        put_out "\n#{@indent}<#{@afk}:typering_instelling>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def typering_instelling_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:typering_instelling>"
    end

    def typering_start attrs
        put_out "\n#{@indent}<#{@afk}:typering>"
    end

    def typering_end
        put_out "</#{@afk}:typering>"
    end

    def typering_taken_start attrs
        put_out "\n#{@indent}<#{@afk}:typering_taken>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def typering_taken_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:typering_taken>"
    end

    def zuil_start attrs
        put_out "\n#{@indent}<#{@afk}:zuil>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def zuil_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:zuil>"
    end

    def kerk_start attrs
        put_out "\n#{@indent}<#{@afk}:kerk>"
    end

    def kerk_end
        put_out "</#{@afk}:kerk>"
    end

    def doelgroepen_start attrs
        put_out "\n#{@indent}<#{@afk}:doelgroepen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def doelgroepen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:doelgroepen>"
    end

    def doelgroep_start attrs
        put_out "\n#{@indent}<#{@afk}:doelgroep>"
    end

    def doelgroep_end
        put_out "</#{@afk}:doelgroep>"
    end

    def andere_archiefvormers_start attrs
        put_out "\n#{@indent}<#{@afk}:andere_archiefvormers rdf:parseType=\"Literal\">"
    end

    def andere_archiefvormers_end
        put_out "</#{@afk}:andere_archiefvormers>"
    end

    def andere_archiefvormers_link_start attrs
        put_out "\n#{@indent}<#{@afk}:andere_archiefvormers_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def andere_archiefvormers_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:andere_archiefvormers_link>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Literal\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def literatuur_link_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur_link>"
    end

    def literatuur_link_end
        put_out "</#{@afk}:literatuur_link>"
    end

    def archieven_start attrs
        put_out "\n#{@indent}<#{@afk}:archieven rdf:parseType=\"Literal\">"
    end

    def archieven_end
        put_out "</#{@afk}:archieven>"
    end

    def archieven_link_start attrs
        put_out "\n#{@indent}<#{@afk}:archieven_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def archieven_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:archieven_link>"
    end

    def periode_archief_start attrs
        put_out "\n#{@indent}<#{@afk}:periode_archief rdf:parseType=\"Literal\">"
    end

    def periode_archief_end
        put_out "</#{@afk}:periode_archief>"
    end

    def periode_archief_link_start attrs
        put_out "\n#{@indent}<#{@afk}:periode_archief_link>"
    end

    def periode_archief_link_end
        put_out "</#{@afk}:periode_archief_link>"
    end

    def vindplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:vindplaats rdf:parseType=\"Literal\">"
    end

    def vindplaats_end
        put_out "</#{@afk}:vindplaats>"
    end

    def vindplaats_link_start attrs
        put_out "\n#{@indent}<#{@afk}:vindplaats_link>"
    end

    def vindplaats_link_end
        put_out "</#{@afk}:vindplaats_link>"
    end

    def openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid rdf:parseType=\"Literal\">"
    end

    def openbaarheid_end
        put_out "</#{@afk}:openbaarheid>"
    end

    def openbaarheid_link_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid_link>"
    end

    def openbaarheid_link_end
        put_out "</#{@afk}:openbaarheid_link>"
    end

    def omvang_invnr_start attrs
        put_out "\n#{@indent}<#{@afk}:omvang_invnr rdf:parseType=\"Literal\">"
    end

    def omvang_invnr_end
        put_out "</#{@afk}:omvang_invnr>"
    end

    def omvang_invnr_link_start attrs
        put_out "\n#{@indent}<#{@afk}:omvang_invnr_link>"
    end

    def omvang_invnr_link_end
        put_out "</#{@afk}:omvang_invnr_link>"
    end

    def informatiedrager_start attrs
        put_out "\n#{@indent}<#{@afk}:informatiedrager>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def informatiedrager_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:informatiedrager>"
    end

    def drager_start attrs
        put_out "\n#{@indent}<#{@afk}:drager>"
    end

    def drager_end
        put_out "</#{@afk}:drager>"
    end

    def vernietigd_start attrs
        put_out "\n#{@indent}<#{@afk}:vernietigd rdf:parseType=\"Literal\">"
    end

    def vernietigd_end
        put_out "</#{@afk}:vernietigd>"
    end

    def vernietigd_link_start attrs
        put_out "\n#{@indent}<#{@afk}:vernietigd_link>"
    end

    def vernietigd_link_end
        put_out "</#{@afk}:vernietigd_link>"
    end

    def toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang rdf:parseType=\"Literal\">"
    end

    def toegang_end
        put_out "</#{@afk}:toegang>"
    end

    def toegang_link_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang_link>"
    end

    def toegang_link_end
        put_out "</#{@afk}:toegang_link>"
    end

    def kenmerk_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:kenmerk_toegang rdf:parseType=\"Literal\">"
    end

    def kenmerk_toegang_end
        put_out "</#{@afk}:kenmerk_toegang>"
    end

    def kenmerk_toegang_link_start attrs
        put_out "\n#{@indent}<#{@afk}:kenmerk_toegang_link>"
    end

    def kenmerk_toegang_link_end
        put_out "</#{@afk}:kenmerk_toegang_link>"
    end

    def indices_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:indices_toegang rdf:parseType=\"Literal\">"
    end

    def indices_toegang_end
        put_out "</#{@afk}:indices_toegang>"
    end

    def indices_toegang_link_start attrs
        put_out "\n#{@indent}<#{@afk}:indices_toegang_link>"
    end

    def indices_toegang_link_end
        put_out "</#{@afk}:indices_toegang_link>"
    end

    def originele_archivalia_ander_start attrs
        put_out "\n#{@indent}<#{@afk}:originele_archivalia_ander rdf:parseType=\"Literal\">"
    end

    def originele_archivalia_ander_end
        put_out "</#{@afk}:originele_archivalia_ander>"
    end

    def originele_archivalia_ander_link_start attrs
        put_out "\n#{@indent}<#{@afk}:originele_archivalia_ander_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def originele_archivalia_ander_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:originele_archivalia_ander_link>"
    end

    def originele_archivalia_deze_start attrs
        put_out "\n#{@indent}<#{@afk}:originele_archivalia_deze rdf:parseType=\"Literal\">"
    end

    def originele_archivalia_deze_end
        put_out "</#{@afk}:originele_archivalia_deze>"
    end

    def originele_archivalia_deze_link_start attrs
        put_out "\n#{@indent}<#{@afk}:originele_archivalia_deze_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def originele_archivalia_deze_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:originele_archivalia_deze_link>"
    end

    def opmerkingen_archief_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_archief rdf:parseType=\"Literal\">"
    end

    def opmerkingen_archief_end
        put_out "</#{@afk}:opmerkingen_archief>"
    end

    def opmerkingen_archief_link_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_archief_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def opmerkingen_archief_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:opmerkingen_archief_link>"
    end

    def seriele_bescheiden_start attrs
        put_out "\n#{@indent}<#{@afk}:seriele_bescheiden rdf:parseType=\"Literal\">"
    end

    def seriele_bescheiden_end
        put_out "</#{@afk}:seriele_bescheiden>"
    end

    def seriele_bescheiden_link_start attrs
        put_out "\n#{@indent}<#{@afk}:seriele_bescheiden_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def seriele_bescheiden_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:seriele_bescheiden_link>"
    end

    def statistische_gegevens_start attrs
        put_out "\n#{@indent}<#{@afk}:statistische_gegevens rdf:parseType=\"Literal\">"
    end

    def statistische_gegevens_end
        put_out "</#{@afk}:statistische_gegevens>"
    end

    def statistische_gegevens_link_start attrs
        put_out "\n#{@indent}<#{@afk}:statistische_gegevens_link>"
    end

    def statistische_gegevens_link_end
        put_out "</#{@afk}:statistische_gegevens_link>"
    end

    def verw_wetten_ned_start attrs
        put_out "\n#{@indent}<#{@afk}:verw_wetten_ned>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verw_wetten_ned_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verw_wetten_ned>"
    end

    def wet_start attrs
        put_out "\n#{@indent}<#{@afk}:wet>"
    end

    def wet_end
        put_out "</#{@afk}:wet>"
    end

    def verw_wetten_bilateraal_start attrs
        put_out "\n#{@indent}<#{@afk}:verw_wetten_bilateraal>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verw_wetten_bilateraal_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verw_wetten_bilateraal>"
    end

    def verw_wetten_multilateraal_start attrs
        put_out "\n#{@indent}<#{@afk}:verw_wetten_multilateraal>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verw_wetten_multilateraal_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verw_wetten_multilateraal>"
    end

    def verw_wetten_start attrs
        put_out "\n#{@indent}<#{@afk}:verw_wetten rdf:parseType=\"Literal\">"
    end

    def verw_wetten_end
        put_out "</#{@afk}:verw_wetten>"
    end

    def verw_wetten_link_start attrs
        put_out "\n#{@indent}<#{@afk}:verw_wetten_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verw_wetten_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verw_wetten_link>"
    end

    def inhoud_overig_start attrs
        put_out "\n#{@indent}<#{@afk}:inhoud_overig rdf:parseType=\"Literal\">"
    end

    def inhoud_overig_end
        put_out "</#{@afk}:inhoud_overig>"
    end

    def inhoud_overig_link_start attrs
        put_out "\n#{@indent}<#{@afk}:inhoud_overig_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def inhoud_overig_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:inhoud_overig_link>"
    end

    def bestemmings_landen_start attrs
        put_out "\n#{@indent}<#{@afk}:bestemmings_landen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def bestemmings_landen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:bestemmings_landen>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def opmerkingen_link_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def opmerkingen_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:opmerkingen_link>"
    end

    def datum_laatste_verandering_start attrs
        put_out "\n#{@indent}<#{@afk}:datum_laatste_verandering>"
    end

    def datum_laatste_verandering_end
        put_out "</#{@afk}:datum_laatste_verandering>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def autopsie_start attrs
        put_out "\n#{@indent}<#{@afk}:autopsie>"
    end

    def autopsie_end
        put_out "</#{@afk}:autopsie>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def titel_end
        put_out "</schema:title>"
    end

    def text_start attrs
        put_out "\n#{@indent}<#{@afk}:text rdf:parseType=\"Literal\">"
    end

    def text_end
        put_out "</#{@afk}:text>"
    end

    def archief_start attrs
        put_out "\n#{@indent}<#{@afk}:archief>"
    end

    def archief_end
        put_out "</#{@afk}:archief>"
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon>"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def periode_start attrs
        put_out "\n#{@indent}<#{@afk}:periode>"
    end

    def periode_end
        put_out "</#{@afk}:periode>"
    end

    def biografie_start attrs
        put_out "\n#{@indent}<#{@afk}:biografie rdf:parseType=\"Literal\">"
    end

    def biografie_end
        put_out "</#{@afk}:biografie>"
    end

    def biografie_link_start attrs
        put_out "\n#{@indent}<#{@afk}:biografie_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def biografie_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:biografie_link>"
    end

    def functies_start attrs
        put_out "\n#{@indent}<#{@afk}:functies rdf:parseType=\"Literal\">"
    end

    def functies_end
        put_out "</#{@afk}:functies>"
    end

    def functies_link_start attrs
        put_out "\n#{@indent}<#{@afk}:functies_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def functies_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:functies_link>"
    end

    def typering_persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:typering_persoon>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def typering_persoon_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:typering_persoon>"
    end

    def kerkgenootschap_start attrs
        put_out "\n#{@indent}<#{@afk}:kerkgenootschap>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def kerkgenootschap_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:kerkgenootschap>"
    end

    def tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:tekst>"
    end

    def tekst_end
        put_out "</#{@afk}:tekst>"
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
       	{"kerk"=>{2=>"kerkgenootschap"}}
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
	    if @in_jaar
		@jaar = text.strip
	    elsif @in_maand
		@maand = text.strip
	    elsif @in_dag
		@dag = text.strip
	    else
		put_out "#{text.strip}"
	    end
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
    xmlns:schema="http://schema.org/"
    xmlns:fc="https://resource.huygens.knaw.nl/constitutionele_commissies/fc"
    xmlns:person="https://resource.huygens.knaw.nl/constitutionele_commissies/person">
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

