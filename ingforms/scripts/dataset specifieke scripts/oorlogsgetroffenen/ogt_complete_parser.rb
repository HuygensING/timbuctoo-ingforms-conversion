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
	@in_arch = false
	@in_vraag = false
	@vraag = ""
    end

    def archiefvormer_start attrs
        put_out "\n#{@indent}<#{@afk}:archiefvormer>"
    end

    def archiefvormer_end
        put_out "</#{@afk}:archiefvormer>"
    end

    def naam_instelling_persoon_start attrs
        put_out "\n#{@indent}<schema:name>"
    end

    def naam_instelling_persoon_end
        put_out "</schema:name>"
    end

    def naamsvariant_start attrs
        put_out "\n#{@indent}<#{@afk}:naamsvariant>"
    end

    def naamsvariant_end
        put_out "</#{@afk}:naamsvariant>"
    end

    def naamsafkorting_start attrs
        put_out "\n#{@indent}<#{@afk}:naamsafkorting>"
    end

    def naamsafkorting_end
        put_out "</#{@afk}:naamsafkorting>"
    end

    def voorloper_start attrs
        put_out "\n#{@indent}<#{@afk}:voorloper rdf:parseType=\"Literal\">"
    end

    def voorloper_end
        put_out "</#{@afk}:voorloper>"
    end

    def opvolger_start attrs
        put_out "\n#{@indent}<#{@afk}:opvolger rdf:parseType=\"Literal\">"
    end

    def opvolger_end
        put_out "</#{@afk}:opvolger>"
    end

    def oprichtings_geboortedatum_start attrs
        put_out "\n#{@indent}<#{@afk}:oprichtings_geboortedatum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def oprichtings_geboortedatum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:oprichtings_geboortedatum>"
    end

    def year_start attrs
	@in_jaar = true
    end

    def year_end
	@in_jaar = false
    end

    def month_start attrs
	@in_maand = true
    end

    def month_end
	@in_maand = false
    end

    def day_start attrs
	@in_dag = true
    end

    def day_end
	@in_dag = false
    end

    def opheffings_sterfdatum_start attrs
        put_out "\n#{@indent}<#{@afk}:opheffings_sterfdatum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def opheffings_sterfdatum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:opheffings_sterfdatum>"
    end

    def opmerkingen_periode_bestaan_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_periode_bestaan rdf:parseType=\"Literal\">"
    end

    def opmerkingen_periode_bestaan_end
        put_out "</#{@afk}:opmerkingen_periode_bestaan>"
    end

    def oprichters_start attrs
        put_out "\n#{@indent}<#{@afk}:oprichters rdf:parseType=\"Literal\">"
    end

    def oprichters_end
        put_out "</#{@afk}:oprichters>"
    end

    def aanleiding_voor_oprichting_start attrs
        put_out "\n#{@indent}<#{@afk}:aanleiding_voor_oprichting rdf:parseType=\"Literal\">"
    end

    def aanleiding_voor_oprichting_end
        put_out "</#{@afk}:aanleiding_voor_oprichting>"
    end

    def rechtsvorm_start attrs
        put_out "\n#{@indent}<#{@afk}:rechtsvorm rdf:parseType=\"Literal\">"
    end

    def rechtsvorm_end
        put_out "</#{@afk}:rechtsvorm>"
    end

    def inrichting_organisatie_start attrs
        put_out "\n#{@indent}<#{@afk}:inrichting_organisatie rdf:parseType=\"Literal\">"
    end

    def inrichting_organisatie_end
        put_out "</#{@afk}:inrichting_organisatie>"
    end

    def organisatie_bevoegheden_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie_bevoegheden rdf:parseType=\"Literal\">"
    end

    def organisatie_bevoegheden_end
        put_out "</#{@afk}:organisatie_bevoegheden>"
    end

    def positie_organisatie_start attrs
        put_out "\n#{@indent}<#{@afk}:positie_organisatie rdf:parseType=\"Literal\">"
    end

    def positie_organisatie_end
        put_out "</#{@afk}:positie_organisatie>"
    end

    def geografische_verwijzigingen_start attrs
        put_out "\n#{@indent}<#{@afk}:geografische_verwijzigingen rdf:parseType=\"Literal\">"
    end

    def geografische_verwijzigingen_end
        put_out "</#{@afk}:geografische_verwijzigingen>"
    end

    def geografische_trefwoorden_start attrs
        put_out "\n#{@indent}<#{@afk}:geografische_trefwoorden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def geografische_trefwoorden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:geografische_trefwoorden>"
    end

    def geografische_trefwoord_start attrs
        put_out "\n#{@indent}<#{@afk}:geografische_trefwoord>"
    end

    def geografische_trefwoord_end
        put_out "</#{@afk}:geografische_trefwoord>"
    end

    def andere_geografische_trefwoorden_start attrs
        put_out "\n#{@indent}<#{@afk}:andere_geografische_trefwoorden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def andere_geografische_trefwoorden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:andere_geografische_trefwoorden>"
    end

    def anders_geografische_trefwoorden_start attrs
        put_out "\n#{@indent}<#{@afk}:anders_geografische_trefwoorden rdf:parseType=\"Resource\">"
    end

    def anders_geografische_trefwoorden_end
        put_out "</#{@afk}:anders_geografische_trefwoorden>"
    end

    def organisatie_karakter_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie_karakter rdf:parseType=\"Literal\">"
    end

    def organisatie_karakter_end
        put_out "</#{@afk}:organisatie_karakter>"
    end

    def biografie_start attrs
        put_out "\n#{@indent}<#{@afk}:biografie rdf:parseType=\"Literal\">"
    end

    def biografie_end
        put_out "</#{@afk}:biografie>"
    end

    def taak_activiteiten_start attrs
        put_out "\n#{@indent}<#{@afk}:taak_activiteiten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def taak_activiteiten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:taak_activiteiten>"
    end

    def typeringen_start attrs
        put_out "\n#{@indent}<#{@afk}:typeringen>"
    end

    def typeringen_end
        put_out "</#{@afk}:typeringen>"
    end

    def doelstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:doelstelling rdf:parseType=\"Literal\">"
    end

    def doelstelling_end
        put_out "</#{@afk}:doelstelling>"
    end

    def programmapunt_start attrs
        put_out "\n#{@indent}<#{@afk}:programmapunt rdf:parseType=\"Literal\">"
    end

    def programmapunt_end
        put_out "</#{@afk}:programmapunt>"
    end

    def functies_persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:functies_persoon rdf:parseType=\"Literal\">"
    end

    def functies_persoon_end
        put_out "</#{@afk}:functies_persoon>"
    end

    def header_instelling_persoon_richtte_start attrs
        put_out "\n#{@indent}<#{@afk}:header_instelling_persoon_richtte>"
    end

    def header_instelling_persoon_richtte_end
        put_out "</#{@afk}:header_instelling_persoon_richtte>"
    end

    def verzet_lijst_start attrs
        put_out "\n#{@indent}<#{@afk}:verzet_lijst>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verzet_lijst_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verzet_lijst>"
    end

    def verzet_start attrs
        put_out "\n#{@indent}<#{@afk}:verzet>"
    end

    def verzet_end
        put_out "</#{@afk}:verzet>"
    end

    def verzet_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:verzet_overige>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verzet_overige_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verzet_overige>"
    end

    def overige_start attrs
        put_out "\n#{@indent}<#{@afk}:overige rdf:parseType=\"Resource\">"
    end

    def overige_end
        put_out "</#{@afk}:overige>"
    end

    def other_start attrs
        put_out "\n#{@indent}<#{@afk}:other>"
    end

    def other_end
        put_out "</#{@afk}:other>"
    end

    def vervolging_start attrs
        put_out "\n#{@indent}<#{@afk}:vervolging>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def vervolging_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:vervolging>"
    end

    def vervolgingsslachtoffers_start attrs
        put_out "\n#{@indent}<#{@afk}:vervolgingsslachtoffers>"
    end

    def vervolgingsslachtoffers_end
        put_out "</#{@afk}:vervolgingsslachtoffers>"
    end

    def vervolging_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:vervolging_overige>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def vervolging_overige_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:vervolging_overige>"
    end

    def burgers_start attrs
        put_out "\n#{@indent}<#{@afk}:burgers>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def burgers_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:burgers>"
    end

    def burger_start attrs
        put_out "\n#{@indent}<#{@afk}:burger>"
    end

    def burger_end
        put_out "</#{@afk}:burger>"
    end

    def burgers_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:burgers_overige>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def burgers_overige_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:burgers_overige>"
    end

    def krijgsgevangenen_start attrs
        put_out "\n#{@indent}<#{@afk}:krijgsgevangenen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def krijgsgevangenen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:krijgsgevangenen>"
    end

    def krijgsgevangene_start attrs
        put_out "\n#{@indent}<#{@afk}:krijgsgevangene>"
    end

    def krijgsgevangene_end
        put_out "</#{@afk}:krijgsgevangene>"
    end

    def krijgsgevangenen_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:krijgsgevangenen_overige>"
    end

    def krijgsgevangenen_overige_end
        put_out "</#{@afk}:krijgsgevangenen_overige>"
    end

    def ned_indie_lijst_start attrs
        put_out "\n#{@indent}<#{@afk}:ned_indie_lijst>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def ned_indie_lijst_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:ned_indie_lijst>"
    end

    def ned_indie_start attrs
        put_out "\n#{@indent}<#{@afk}:ned_indie>"
    end

    def ned_indie_end
        put_out "</#{@afk}:ned_indie>"
    end

    def ned_indie_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:ned_indie_overige>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def ned_indie_overige_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:ned_indie_overige>"
    end

    def zeelieden_start attrs
        put_out "\n#{@indent}<#{@afk}:zeelieden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def zeelieden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:zeelieden>"
    end

    def zeelied_start attrs
        put_out "\n#{@indent}<#{@afk}:zeelied>"
    end

    def zeelied_end
        put_out "</#{@afk}:zeelied>"
    end

    def zeelieden_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:zeelieden_overige>"
    end

    def zeelieden_overige_end
        put_out "</#{@afk}:zeelieden_overige>"
    end

    def tweedegen_start attrs
        put_out "\n#{@indent}<#{@afk}:tweedegen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def tweedegen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:tweedegen>"
    end

    def tweede_gen_start attrs
        put_out "\n#{@indent}<#{@afk}:tweede_gen>"
    end

    def tweede_gen_end
        put_out "</#{@afk}:tweede_gen>"
    end

    def tweedegen_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:tweedegen_overige>"
    end

    def tweedegen_overige_end
        put_out "</#{@afk}:tweedegen_overige>"
    end

    def foutened_start attrs
        put_out "\n#{@indent}<#{@afk}:foutened>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def foutened_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:foutened>"
    end

    def foute_ned_start attrs
        put_out "\n#{@indent}<#{@afk}:foute_ned>"
    end

    def foute_ned_end
        put_out "</#{@afk}:foute_ned>"
    end

    def foutened_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:foutened_overige>"
    end

    def foutened_overige_end
        put_out "</#{@afk}:foutened_overige>"
    end

    def militairen_start attrs
        put_out "\n#{@indent}<#{@afk}:militairen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def militairen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:militairen>"
    end

    def militair_start attrs
        put_out "\n#{@indent}<#{@afk}:militair>"
    end

    def militair_end
        put_out "</#{@afk}:militair>"
    end

    def militairen_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:militairen_overige>"
    end

    def militairen_overige_end
        put_out "</#{@afk}:militairen_overige>"
    end

    def repatrianten_start attrs
        put_out "\n#{@indent}<#{@afk}:repatrianten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def repatrianten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:repatrianten>"
    end

    def repatriant_start attrs
        put_out "\n#{@indent}<#{@afk}:repatriant>"
    end

    def repatriant_end
        put_out "</#{@afk}:repatriant>"
    end

    def repatrianten_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:repatrianten_overige>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def repatrianten_overige_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:repatrianten_overige>"
    end

    def header_einde_instelling_persoon_richtte_start attrs
        put_out "\n#{@indent}<#{@afk}:header_einde_instelling_persoon_richtte>"
    end

    def header_einde_instelling_persoon_richtte_end
        put_out "</#{@afk}:header_einde_instelling_persoon_richtte>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Literal\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def website_start attrs
        put_out "\n#{@indent}<#{@afk}:website rdf:parseType=\"Literal\">"
    end

    def website_end
        put_out "</#{@afk}:website>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def archieven_start attrs
        put_out "\n#{@indent}<#{@afk}:archieven rdf:parseType=\"Literal\">"
    end

    def archieven_end
        put_out "</#{@afk}:archieven>"
    end

    def subthema_tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:subthema_tekst rdf:parseType=\"Literal\">"
    end

    def subthema_tekst_end
        put_out "</#{@afk}:subthema_tekst>"
    end

    def aangemaakt_door_start attrs
        put_out "\n#{@indent}<#{@afk}:aangemaakt_door>"
    end

    def aangemaakt_door_end
        put_out "</#{@afk}:aangemaakt_door>"
    end

    def gewijzigd_door_start attrs
        put_out "\n#{@indent}<#{@afk}:gewijzigd_door>"
    end

    def gewijzigd_door_end
        put_out "</#{@afk}:gewijzigd_door>"
    end

    def gewijzigd_op_start attrs
        put_out "\n#{@indent}<#{@afk}:gewijzigd_op>"
    end

    def gewijzigd_op_end
        put_out "</#{@afk}:gewijzigd_op>"
    end

    def aantekeningen_start attrs
	if @in_arch
	    put_out "\n#{@indent}<#{@afk}:aantekeningen>"
  	    put_out "\n#{@indent}<rdf:Seq>"
	else
	    put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
	end
    end

    def aantekeningen_end
	if @in_arch
	    @output.puts "\n#{@indent}</rdf:Seq>"
	    indent = "  " * (@level - 1)
	    put_out "\n#{indent}</#{@afk}:aantekeningen>"
	else
	    put_out "</#{@afk}:aantekeningen>"
	end
    end

    def aantekening_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekening rdf:parseType=\"Resource\">"
    end

    def aantekening_end
        put_out "</#{@afk}:aantekening>"
    end

    def name_start attrs
        put_out "\n#{@indent}<#{@afk}:name>"
    end

    def name_end
        put_out "</#{@afk}:name>"
    end

    def datum_start attrs
        put_out "\n#{@indent}<#{@afk}:datum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def datum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:datum>"
    end

    def notes_start attrs
        put_out "\n#{@indent}<#{@afk}:notes rdf:parseType=\"Literal\">"
    end

    def notes_end
        put_out "</#{@afk}:notes>"
    end

    def archief_start attrs
        put_out "\n#{@indent}<#{@afk}:archief>"
    end

    def archief_end
        put_out "</#{@afk}:archief>"
    end

    def naamcollectie_start attrs
        put_out "\n#{@indent}<schema:name>"
    end

    def naamcollectie_end
        put_out "</schema:name>"
    end

    def beginjaar_start attrs
        put_out "\n#{@indent}<#{@afk}:beginjaar>"
    end

    def beginjaar_end
        put_out "</#{@afk}:beginjaar>"
    end

    def eindjaar_start attrs
        put_out "\n#{@indent}<#{@afk}:eindjaar>"
    end

    def eindjaar_end
        put_out "</#{@afk}:eindjaar>"
    end

    def vindplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:vindplaats rdf:parseType=\"Literal\">"
    end

    def vindplaats_end
        put_out "</#{@afk}:vindplaats>"
    end

    def lengte_start attrs
        put_out "\n#{@indent}<#{@afk}:lengte>"
    end

    def lengte_end
        put_out "</#{@afk}:lengte>"
    end

    def aantal_inventarisnummers_start attrs
        put_out "\n#{@indent}<#{@afk}:aantal_inventarisnummers>"
    end

    def aantal_inventarisnummers_end
        put_out "</#{@afk}:aantal_inventarisnummers>"
    end

    def toegangen_start attrs
        put_out "\n#{@indent}<#{@afk}:toegangen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def toegangen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:toegangen>"
    end

    def toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang>"
    end

    def toegang_end
        put_out "</#{@afk}:toegang>"
    end

    def toelichting_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:toelichting_toegang rdf:parseType=\"Literal\">"
    end

    def toelichting_toegang_end
        put_out "</#{@afk}:toelichting_toegang>"
    end

    def kenmerk_start attrs
        put_out "\n#{@indent}<#{@afk}:kenmerk rdf:parseType=\"Literal\">"
    end

    def kenmerk_end
        put_out "</#{@afk}:kenmerk>"
    end

    def index_start attrs
        put_out "\n#{@indent}<#{@afk}:index rdf:parseType=\"Literal\">"
    end

    def index_end
        put_out "</#{@afk}:index>"
    end

    def openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def openbaarheid_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:openbaarheid>"
    end

    def Openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:Openbaarheid>"
    end

    def Openbaarheid_end
        put_out "</#{@afk}:Openbaarheid>"
    end

    def openbaarheid_toelichting_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid_toelichting rdf:parseType=\"Literal\">"
    end

    def openbaarheid_toelichting_end
        put_out "</#{@afk}:openbaarheid_toelichting>"
    end

    def archiefordening_start attrs
        put_out "\n#{@indent}<#{@afk}:archiefordening>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def archiefordening_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:archiefordening>"
    end

    def Archiefordening_start attrs
        put_out "\n#{@indent}<#{@afk}:Archiefordening>"
    end

    def Archiefordening_end
        put_out "</#{@afk}:Archiefordening>"
    end

    def archiefordening_extra_start attrs
        put_out "\n#{@indent}<#{@afk}:archiefordening_extra rdf:parseType=\"Literal\">"
    end

    def archiefordening_extra_end
        put_out "</#{@afk}:archiefordening_extra>"
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

    def Informatiedrager_start attrs
        put_out "\n#{@indent}<#{@afk}:Informatiedrager>"
    end

    def Informatiedrager_end
        put_out "</#{@afk}:Informatiedrager>"
    end

    def informatiedrager_extra_start attrs
        put_out "\n#{@indent}<#{@afk}:informatiedrager_extra rdf:parseType=\"Literal\">"
    end

    def informatiedrager_extra_end
        put_out "</#{@afk}:informatiedrager_extra>"
    end

    def inhoud_separator_start attrs
        put_out "\n#{@indent}<#{@afk}:inhoud_separator>"
    end

    def inhoud_separator_end
        put_out "</#{@afk}:inhoud_separator>"
    end

    def analytische_beschrijving_start attrs
        put_out "\n#{@indent}<#{@afk}:analytische_beschrijving rdf:parseType=\"Literal\">"
    end

    def analytische_beschrijving_end
        put_out "</#{@afk}:analytische_beschrijving>"
    end

    def notulen_start attrs
        put_out "\n#{@indent}<#{@afk}:notulen rdf:parseType=\"Literal\">"
    end

    def notulen_end
        put_out "</#{@afk}:notulen>"
    end

    def jaarverslagen_start attrs
        put_out "\n#{@indent}<#{@afk}:jaarverslagen rdf:parseType=\"Literal\">"
    end

    def jaarverslagen_end
        put_out "</#{@afk}:jaarverslagen>"
    end

    def brievencollectie_start attrs
        put_out "\n#{@indent}<#{@afk}:brievencollectie rdf:parseType=\"Literal\">"
    end

    def brievencollectie_end
        put_out "</#{@afk}:brievencollectie>"
    end

    def financien_start attrs
        put_out "\n#{@indent}<#{@afk}:financien rdf:parseType=\"Literal\">"
    end

    def financien_end
        put_out "</#{@afk}:financien>"
    end

    def persoonsdossiers_start attrs
        put_out "\n#{@indent}<#{@afk}:persoonsdossiers rdf:parseType=\"Literal\">"
    end

    def persoonsdossiers_end
        put_out "</#{@afk}:persoonsdossiers>"
    end

    def inhoud_overig_start attrs
        put_out "\n#{@indent}<#{@afk}:inhoud_overig rdf:parseType=\"Literal\">"
    end

    def inhoud_overig_end
        put_out "</#{@afk}:inhoud_overig>"
    end

    def documentatie_start attrs
        put_out "\n#{@indent}<#{@afk}:documentatie rdf:parseType=\"Literal\">"
    end

    def documentatie_end
        put_out "</#{@afk}:documentatie>"
    end

    def archivalia_andere_archieven_start attrs
        put_out "\n#{@indent}<#{@afk}:archivalia_andere_archieven rdf:parseType=\"Literal\">"
    end

    def archivalia_andere_archieven_end
        put_out "</#{@afk}:archivalia_andere_archieven>"
    end

    def andere_archieven_start attrs
        put_out "\n#{@indent}<#{@afk}:andere_archieven rdf:parseType=\"Literal\">"
    end

    def andere_archieven_end
        put_out "</#{@afk}:andere_archieven>"
    end

    def verloren_start attrs
        put_out "\n#{@indent}<#{@afk}:verloren rdf:parseType=\"Literal\">"
    end

    def verloren_end
        put_out "</#{@afk}:verloren>"
    end

    def vernietigd_start attrs
        put_out "\n#{@indent}<#{@afk}:vernietigd rdf:parseType=\"Literal\">"
    end

    def vernietigd_end
        put_out "</#{@afk}:vernietigd>"
    end

    def wetten_start attrs
        put_out "\n#{@indent}<#{@afk}:wetten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def wetten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:wetten>"
    end

    def wet_start attrs
        put_out "\n#{@indent}<#{@afk}:wet>"
    end

    def wet_end
        put_out "</#{@afk}:wet>"
    end

    def wetten_extra_start attrs
        put_out "\n#{@indent}<#{@afk}:wetten_extra rdf:parseType=\"Literal\">"
    end

    def wetten_extra_end
        put_out "</#{@afk}:wetten_extra>"
    end

    def verwijzingen_start attrs
        put_out "\n#{@indent}<#{@afk}:verwijzingen rdf:parseType=\"Literal\">"
    end

    def verwijzingen_end
        put_out "</#{@afk}:verwijzingen>"
    end

    def bronnen_start attrs
        put_out "\n#{@indent}<#{@afk}:bronnen rdf:parseType=\"Literal\">"
    end

    def bronnen_end
        put_out "</#{@afk}:bronnen>"
    end

    def avmat_start attrs
        put_out "\n#{@indent}<#{@afk}:avmat>"
    end

    def avmat_end
        put_out "</#{@afk}:avmat>"
    end

    def nr_start attrs
        put_out "\n#{@indent}<#{@afk}:nr>"
    end

    def nr_end
        put_out "</#{@afk}:nr>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def titel_end
        put_out "</schema:title>"
    end

    def bijschrift_start attrs
        put_out "\n#{@indent}<#{@afk}:bijschrift rdf:parseType=\"Literal\">"
    end

    def bijschrift_end
        put_out "</#{@afk}:bijschrift>"
    end

    def matsoort_start attrs
        put_out "\n#{@indent}<#{@afk}:matsoort>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def matsoort_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:matsoort>"
    end

    def mat_start attrs
        put_out "\n#{@indent}<#{@afk}:mat>"
    end

    def mat_end
        put_out "</#{@afk}:mat>"
    end

    def matsoort_anders_start attrs
        put_out "\n#{@indent}<#{@afk}:matsoort_anders>"
    end

    def matsoort_anders_end
        put_out "</#{@afk}:matsoort_anders>"
    end

    def locatie_start attrs
        put_out "\n#{@indent}<#{@afk}:locatie>"
    end

    def locatie_end
        put_out "</#{@afk}:locatie>"
    end

    def documentnr_start attrs
        put_out "\n#{@indent}<#{@afk}:documentnr>"
    end

    def documentnr_end
        put_out "</#{@afk}:documentnr>"
    end

    def rechhebbenden_start attrs
        put_out "\n#{@indent}<#{@afk}:rechhebbenden>"
    end

    def rechhebbenden_end
        put_out "</#{@afk}:rechhebbenden>"
    end

    def maker_start attrs
        put_out "\n#{@indent}<#{@afk}:maker>"
    end

    def maker_end
        put_out "</#{@afk}:maker>"
    end

    def trefwoorden_start attrs
        put_out "\n#{@indent}<#{@afk}:trefwoorden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def trefwoorden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:trefwoorden>"
    end

    def trefwoord_start attrs
        put_out "\n#{@indent}<#{@afk}:trefwoord rdf:parseType=\"Resource\">"
    end

    def trefwoord_end
        put_out "</#{@afk}:trefwoord>"
    end

    def keyword_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword>"
    end

    def keyword_end
        put_out "</#{@afk}:keyword>"
    end

    def geografisch_trefwoord_start attrs
        put_out "\n#{@indent}<#{@afk}:geografisch_trefwoord>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def geografisch_trefwoord_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:geografisch_trefwoord>"
    end

    def organisatie_format_start attrs
        put_out "\n#{@indent}<#{@afk}:organisatie_format rdf:parseType=\"Literal\">"
    end

    def organisatie_format_end
        put_out "</#{@afk}:organisatie_format>"
    end

    def personen_start attrs
        put_out "\n#{@indent}<#{@afk}:personen>"
    end

    def personen_end
        put_out "</#{@afk}:personen>"
    end

    def onderdeel_start attrs
        put_out "\n#{@indent}<#{@afk}:onderdeel>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def onderdeel_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:onderdeel>"
    end

    def gidsonderdeel_start attrs
        put_out "\n#{@indent}<#{@afk}:gidsonderdeel>"
    end

    def gidsonderdeel_end
        put_out "</#{@afk}:gidsonderdeel>"
    end

    def kopie_start attrs
        put_out "\n#{@indent}<#{@afk}:kopie>"
    end

    def kopie_end
        put_out "</#{@afk}:kopie>"
    end

    def geselecteerd_start attrs
        put_out "\n#{@indent}<#{@afk}:geselecteerd>"
    end

    def geselecteerd_end
        put_out "</#{@afk}:geselecteerd>"
    end

    def besteld_start attrs
        put_out "\n#{@indent}<#{@afk}:besteld>"
    end

    def besteld_end
        put_out "</#{@afk}:besteld>"
    end

    def rechten_start attrs
        put_out "\n#{@indent}<#{@afk}:rechten>"
    end

    def rechten_end
        put_out "</#{@afk}:rechten>"
    end

    def binnen_start attrs
        put_out "\n#{@indent}<#{@afk}:binnen>"
    end

    def binnen_end
        put_out "</#{@afk}:binnen>"
    end

    def bij_format_start attrs
        put_out "\n#{@indent}<#{@afk}:bij_format>"
    end

    def bij_format_end
        put_out "</#{@afk}:bij_format>"
    end

    def naambestand_start attrs
        put_out "\n#{@indent}<#{@afk}:naambestand rdf:parseType=\"Literal\">"
    end

    def naambestand_end
        put_out "</#{@afk}:naambestand>"
    end

    def begrip_start attrs
        put_out "\n<schema:title>"
    end

    def begrip_end
        put_out "</schema:title>"
    end

    def begrip_overige_start attrs
        put_out "\n#{@indent}<#{@afk}:begrip_overige>"
    end

    def begrip_overige_end
        put_out "</#{@afk}:begrip_overige>"
    end

    def omschrijving_start attrs
        put_out "\n#{@indent}<#{@afk}:omschrijving rdf:parseType=\"Literal\">"
    end

    def omschrijving_end
        put_out "</#{@afk}:omschrijving>"
    end

    def bron_start attrs
        put_out "\n#{@indent}<#{@afk}:bron rdf:parseType=\"Literal\">"
    end

    def bron_end
        put_out "</#{@afk}:bron>"
    end

    def gidsen_start attrs
        put_out "\n#{@indent}<#{@afk}:gidsen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def gidsen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:gidsen>"
    end

    def gids_start attrs
        put_out "\n#{@indent}<#{@afk}:gids>"
    end

    def gids_end
        put_out "</#{@afk}:gids>"
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

    def begrippen_start attrs
        put_out "\n#{@indent}<#{@afk}:begrippen rdf:parseType=\"Literal\">"
    end

    def begrippen_end
        put_out "</#{@afk}:begrippen>"
    end

    def avmat_start attrs
        put_out "\n#{@indent}<#{@afk}:avmat rdf:parseType=\"Literal\">"
    end

    def avmat_end
        put_out "</#{@afk}:avmat>"
    end

    def status_start attrs
        put_out "\n#{@indent}<#{@afk}:status>"
    end

    def status_end
        put_out "</#{@afk}:status>"
    end

    def auteur_start attrs
        put_out "\n#{@indent}<#{@afk}:auteur>"
    end

    def auteur_end
        put_out "</#{@afk}:auteur>"
    end

    def va_start attrs
        put_out "\n#{@indent}<#{@afk}:va>"
    end

    def va_end
        put_out "</#{@afk}:va>"
    end

    def vraag_start attrs
        put_out "\n#{@indent}<#{@afk}:vraag rdf:parseType=\"Literal\">"
	@in_vraag = true
    end

    def vraag_end
        put_out "</#{@afk}:vraag>"
	@vraag.gsub!(/<[^>]*\/?>/,"")
	put_out "\n#{@indent}<schema:title>#{@vraag}</schema:title>"
	@in_vraag = false
	@vraag = ""
    end

    def antwoord_start attrs
        put_out "\n#{@indent}<#{@afk}:antwoord rdf:parseType=\"Literal\">"
    end

    def antwoord_end
        put_out "</#{@afk}:antwoord>"
    end

    def formats_start attrs
        put_out "\n#{@indent}<#{@afk}:formats>"
    end

    def formats_end
        put_out "</#{@afk}:formats>"
    end

    def table
       	{"geografische_trefwoorden"=>{3=>"geografische_trefwoord",4=>"geografische_trefwoord"}, "verzet"=>{2=>"verzet_lijst"}, "burgers"=>{3=>"burger"}, "krijgsgevangenen"=>{3=>"krijgsgevangene"}, "ned_indie"=>{2=>"ned_indie_lijst"}, "aantekeningen"=>{3=>"aantekening"}, "toegang"=>{2=>"toegangen"}, "wetten"=>{3=>"wet"}, "trefwoord"=>{2=>"trefwoorden", 4=>"keyword"}, "gids"=>{2=>"gidsen"}}
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
	    @in_arch = true if name.eql?("archief")
	    @in_arch = true if name.eql?("archiefvormer")
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
		@vraag = text.strip if @in_vraag
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

