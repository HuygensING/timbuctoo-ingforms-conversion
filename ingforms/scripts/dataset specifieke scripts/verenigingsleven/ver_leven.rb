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

    def tekst_start attrs
        put_out "\n#{@indent}<#{@afk}:tekst>"
    end

    def tekst_end
        put_out "</#{@afk}:tekst>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<#{@afk}:titel>"
    end

    def titel_end
        put_out "</#{@afk}:titel>"
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

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def vereniging_start attrs
        put_out "\n#{@indent}<#{@afk}:vereniging>"
    end

    def vereniging_end
        put_out "</#{@afk}:vereniging>"
    end

    def plaats_start attrs
        put_out "\n#{@indent}<#{@afk}:plaats>"
    end

    def plaats_end
        put_out "</#{@afk}:plaats>"
    end

    def gemeente_start attrs
        put_out "\n#{@indent}<#{@afk}:gemeente>"
    end

    def gemeente_end
        put_out "</#{@afk}:gemeente>"
    end

    def provincies_start attrs
        put_out "\n#{@indent}<#{@afk}:provincies>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def provincies_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:provincies>"
    end

    def provincie_start attrs
        put_out "\n#{@indent}<#{@afk}:provincie>"
    end

    def provincie_end
        put_out "</#{@afk}:provincie>"
    end

    def bisdommen_start attrs
        put_out "\n#{@indent}<#{@afk}:bisdommen rdf:parseType=\"Resource\">"
    end

    def bisdommen_end
        put_out "</#{@afk}:bisdommen>"
    end

    def bisdom_start attrs
        put_out "\n#{@indent}<#{@afk}:bisdom>"
    end

    def bisdom_end
        put_out "</#{@afk}:bisdom>"
    end

    def naam_start attrs
        put_out "\n#{@indent}<#{@afk}:naam>"
    end

    def naam_end
        put_out "</#{@afk}:naam>"
    end

    def opm_naam_start attrs
        put_out "\n#{@indent}<#{@afk}:opm_naam>"
    end

    def opm_naam_end
        put_out "</#{@afk}:opm_naam>"
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

    def Naam_start attrs
        put_out "\n#{@indent}<#{@afk}:Naam rdf:parseType=\"Resource\">"
    end

    def Naam_end
        put_out "</#{@afk}:Naam>"
    end

    def doelstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:doelstelling rdf:parseType=\"Literal\">"
    end

    def doelstelling_end
        put_out "</#{@afk}:doelstelling>"
    end

    def begindatum_start attrs
        put_out "\n#{@indent}<#{@afk}:begindatum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
	@jaar = ""
	@maand = ""
	@dag = ""
    end

    def begindatum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:begindatum>"
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

    def begindatum_soort_start attrs
        put_out "\n#{@indent}<#{@afk}:begindatum_soort>"
    end

    def begindatum_soort_end
        put_out "</#{@afk}:begindatum_soort>"
    end

    def kb_start attrs
        put_out "\n#{@indent}<#{@afk}:kb>"
    end

    def kb_end
        put_out "</#{@afk}:kb>"
    end

    def einddatum_start attrs
        put_out "\n#{@indent}<#{@afk}:einddatum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
	@jaar = ""
	@maand = ""
	@dag = ""
    end

    def einddatum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:einddatum>"
    end

    def einddatum_soort_start attrs
        put_out "\n#{@indent}<#{@afk}:einddatum_soort>"
    end

    def einddatum_soort_end
        put_out "</#{@afk}:einddatum_soort>"
    end

    def werkingsgebieden_start attrs
        put_out "\n#{@indent}<#{@afk}:werkingsgebieden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def werkingsgebieden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:werkingsgebieden>"
    end

    def werkingsgebied_start attrs
        put_out "\n#{@indent}<#{@afk}:werkingsgebied>"
    end

    def werkingsgebied_end
        put_out "</#{@afk}:werkingsgebied>"
    end

    def parochie_start attrs
        put_out "\n#{@indent}<#{@afk}:parochie rdf:parseType=\"Literal\">"
    end

    def parochie_end
        put_out "</#{@afk}:parochie>"
    end

    def grondslag_start attrs
        put_out "\n#{@indent}<#{@afk}:grondslag rdf:parseType=\"Literal\">"
    end

    def grondslag_end
        put_out "</#{@afk}:grondslag>"
    end

    def activiteit_start attrs
        put_out "\n#{@indent}<#{@afk}:activiteit rdf:parseType=\"Literal\">"
    end

    def activiteit_end
        put_out "</#{@afk}:activiteit>"
    end

    def sport_start attrs
        put_out "\n#{@indent}<#{@afk}:sport>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def sport_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:sport>"
    end

    def soort_sport_start attrs
        put_out "\n#{@indent}<#{@afk}:soort_sport>"
    end

    def soort_sport_end
        put_out "</#{@afk}:soort_sport>"
    end

    def landelijke_bond_start attrs
        put_out "\n#{@indent}<#{@afk}:landelijke_bond>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def landelijke_bond_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:landelijke_bond>"
    end

    def Landelijke_bond_start attrs
        put_out "\n#{@indent}<#{@afk}:Landelijke_bond rdf:parseType=\"Resource\">"
    end

    def Landelijke_bond_end
        put_out "</#{@afk}:Landelijke_bond>"
    end

    def regionale_bond_start attrs
        put_out "\n#{@indent}<#{@afk}:regionale_bond>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def regionale_bond_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:regionale_bond>"
    end

    def Regionale_bond_start attrs
        put_out "\n#{@indent}<#{@afk}:Regionale_bond rdf:parseType=\"Resource\">"
    end

    def Regionale_bond_end
        put_out "</#{@afk}:Regionale_bond>"
    end

    def speeldag_start attrs
        put_out "\n#{@indent}<#{@afk}:speeldag>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def speeldag_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:speeldag>"
    end

    def dag_start attrs
        put_out "\n#{@indent}<#{@afk}:dag>"
    end

    def dag_end
        put_out "</#{@afk}:dag>"
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

    def richtgroepen_start attrs
        put_out "\n#{@indent}<#{@afk}:richtgroepen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def richtgroepen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:richtgroepen>"
    end

    def richtgroep_start attrs
        put_out "\n#{@indent}<#{@afk}:richtgroep>"
    end

    def richtgroep_end
        put_out "</#{@afk}:richtgroep>"
    end

    def soort_politieke_vereniging_start attrs
        put_out "\n#{@indent}<#{@afk}:soort_politieke_vereniging>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def soort_politieke_vereniging_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:soort_politieke_vereniging>"
    end

    def politiek_start attrs
        put_out "\n#{@indent}<#{@afk}:politiek>"
    end

    def politiek_end
        put_out "</#{@afk}:politiek>"
    end

    def levensbeschouwing_start attrs
        put_out "\n#{@indent}<#{@afk}:levensbeschouwing>"
    end

    def levensbeschouwing_end
        put_out "</#{@afk}:levensbeschouwing>"
    end

    def nr_verenigingsdossier_start attrs
        put_out "\n#{@indent}<#{@afk}:nr_verenigingsdossier>"
    end

    def nr_verenigingsdossier_end
        put_out "</#{@afk}:nr_verenigingsdossier>"
    end

    def relaties_start attrs
        put_out "\n#{@indent}<#{@afk}:relaties>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def relaties_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:relaties>"
    end

    def Relatie_start attrs
        put_out "\n#{@indent}<#{@afk}:Relatie rdf:parseType=\"Resource\">"
    end

    def Relatie_end
        put_out "</#{@afk}:Relatie>"
    end

    def type_relatie_start attrs
        put_out "\n#{@indent}<#{@afk}:type_relatie>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def type_relatie_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:type_relatie>"
    end

    def relatie_start attrs
        put_out "\n#{@indent}<#{@afk}:relatie>"
    end

    def relatie_end
        put_out "</#{@afk}:relatie>"
    end

    def instelling_start attrs
        put_out "\n#{@indent}<#{@afk}:instelling rdf:parseType=\"Literal\">"
    end

    def instelling_end
        put_out "</#{@afk}:instelling>"
    end

    def oprichters_start attrs
        put_out "\n#{@indent}<#{@afk}:oprichters rdf:parseType=\"Literal\">"
    end

    def oprichters_end
        put_out "</#{@afk}:oprichters>"
    end

    def bestuursleden_start attrs
        put_out "\n#{@indent}<#{@afk}:bestuursleden rdf:parseType=\"Literal\">"
    end

    def bestuursleden_end
        put_out "</#{@afk}:bestuursleden>"
    end

    def beschermheren_start attrs
        put_out "\n#{@indent}<#{@afk}:beschermheren rdf:parseType=\"Literal\">"
    end

    def beschermheren_end
        put_out "</#{@afk}:beschermheren>"
    end

    def verantwoording_gegevens_start attrs
        put_out "\n#{@indent}<#{@afk}:verantwoording_gegevens rdf:parseType=\"Literal\">"
    end

    def verantwoording_gegevens_end
        put_out "</#{@afk}:verantwoording_gegevens>"
    end

    def inlichting_niet_ontvangen_start attrs
        put_out "\n#{@indent}<#{@afk}:inlichting_niet_ontvangen rdf:parseType=\"Resource\">"
    end

    def inlichting_niet_ontvangen_end
        put_out "</#{@afk}:inlichting_niet_ontvangen>"
    end

    def inlichting_start attrs
        put_out "\n#{@indent}<#{@afk}:inlichting>"
    end

    def inlichting_end
        put_out "</#{@afk}:inlichting>"
    end

    def staatscourant_start attrs
        put_out "\n#{@indent}<#{@afk}:staatscourant rdf:parseType=\"Literal\">"
    end

    def staatscourant_end
        put_out "</#{@afk}:staatscourant>"
    end

    def archief_geschreven_start attrs
        put_out "\n#{@indent}<#{@afk}:archief_geschreven rdf:parseType=\"Literal\">"
    end

    def archief_geschreven_end
        put_out "</#{@afk}:archief_geschreven>"
    end

    def archief_objecten_start attrs
        put_out "\n#{@indent}<#{@afk}:archief_objecten rdf:parseType=\"Literal\">"
    end

    def archief_objecten_end
        put_out "</#{@afk}:archief_objecten>"
    end

    def eigen_gebouw_start attrs
        put_out "\n#{@indent}<#{@afk}:eigen_gebouw rdf:parseType=\"Literal\">"
    end

    def eigen_gebouw_end
        put_out "</#{@afk}:eigen_gebouw>"
    end

    def vergaderplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:vergaderplaats rdf:parseType=\"Literal\">"
    end

    def vergaderplaats_end
        put_out "</#{@afk}:vergaderplaats>"
    end

    def literatuur_over_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur_over>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def literatuur_over_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:literatuur_over>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Resource\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def auteur_start attrs
        put_out "\n#{@indent}<#{@afk}:auteur>"
    end

    def auteur_end
        put_out "</#{@afk}:auteur>"
    end

    def title_start attrs
        put_out "\n#{@indent}<#{@afk}:title>"
    end

    def title_end
        put_out "</#{@afk}:title>"
    end

    def jvu_start attrs
        put_out "\n#{@indent}<#{@afk}:jvu>"
    end

    def jvu_end
        put_out "</#{@afk}:jvu>"
    end

    def pages_start attrs
        put_out "\n#{@indent}<#{@afk}:pages>"
    end

    def pages_end
        put_out "</#{@afk}:pages>"
    end

    def ppn_start attrs
        put_out "\n#{@indent}<#{@afk}:ppn>"
    end

    def ppn_end
        put_out "</#{@afk}:ppn>"
    end

    def publicaties_van_start attrs
        put_out "\n#{@indent}<#{@afk}:publicaties_van>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def publicaties_van_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:publicaties_van>"
    end

    def publicaties_start attrs
        put_out "\n#{@indent}<#{@afk}:publicaties rdf:parseType=\"Resource\">"
    end

    def publicaties_end
        put_out "</#{@afk}:publicaties>"
    end

    def goossens_start attrs
        put_out "\n#{@indent}<#{@afk}:goossens>"
    end

    def goossens_end
        put_out "</#{@afk}:goossens>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def oprichtingsdatum_start attrs
        put_out "\n#{@indent}<#{@afk}:oprichtingsdatum rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
	@jaar = ""
	@maand = ""
	@dag = ""
    end

    def oprichtingsdatum_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:oprichtingsdatum>"
    end

    def archief_start attrs
        put_out "\n#{@indent}<#{@afk}:archief>"
    end

    def archief_end
        put_out "</#{@afk}:archief>"
    end

    def naam_vereniging_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_vereniging>"
    end

    def naam_vereniging_end
        put_out "</#{@afk}:naam_vereniging>"
    end

    def naam_vindplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_vindplaats>"
    end

    def naam_vindplaats_end
        put_out "</#{@afk}:naam_vindplaats>"
    end

    def naam_collectie_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_collectie>"
    end

    def naam_collectie_end
        put_out "</#{@afk}:naam_collectie>"
    end

    def beheersnummer_start attrs
        put_out "\n#{@indent}<#{@afk}:beheersnummer>"
    end

    def beheersnummer_end
        put_out "</#{@afk}:beheersnummer>"
    end

    def toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:toegang>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def toegang_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:toegang>"
    end

    def selectie_start attrs
        put_out "\n#{@indent}<#{@afk}:selectie>"
    end

    def selectie_end
        put_out "</#{@afk}:selectie>"
    end

    def openbaarheid_start attrs
        put_out "\n#{@indent}<#{@afk}:openbaarheid>"
    end

    def openbaarheid_end
        put_out "</#{@afk}:openbaarheid>"
    end

    def omvang_start attrs
        put_out "\n#{@indent}<#{@afk}:omvang>"
    end

    def omvang_end
        put_out "</#{@afk}:omvang>"
    end

    def statuten_start attrs
        put_out "\n#{@indent}<#{@afk}:statuten>"
    end

    def statuten_end
        put_out "</#{@afk}:statuten>"
    end

    def statuten_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:statuten_opmerkingen rdf:parseType=\"Literal\">"
    end

    def statuten_opmerkingen_end
        put_out "</#{@afk}:statuten_opmerkingen>"
    end

    def reglementen_start attrs
        put_out "\n#{@indent}<#{@afk}:reglementen>"
    end

    def reglementen_end
        put_out "</#{@afk}:reglementen>"
    end

    def reglementen_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:reglementen_opmerkingen rdf:parseType=\"Literal\">"
    end

    def reglementen_opmerkingen_end
        put_out "</#{@afk}:reglementen_opmerkingen>"
    end

    def ledenlijsten_start attrs
        put_out "\n#{@indent}<#{@afk}:ledenlijsten>"
    end

    def ledenlijsten_end
        put_out "</#{@afk}:ledenlijsten>"
    end

    def ledenlijsten_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:ledenlijsten_opmerkingen rdf:parseType=\"Literal\">"
    end

    def ledenlijsten_opmerkingen_end
        put_out "</#{@afk}:ledenlijsten_opmerkingen>"
    end

    def notulen_start attrs
        put_out "\n#{@indent}<#{@afk}:notulen>"
    end

    def notulen_end
        put_out "</#{@afk}:notulen>"
    end

    def notulen_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:notulen_opmerkingen rdf:parseType=\"Literal\">"
    end

    def notulen_opmerkingen_end
        put_out "</#{@afk}:notulen_opmerkingen>"
    end

    def jaarverslagen_start attrs
        put_out "\n#{@indent}<#{@afk}:jaarverslagen>"
    end

    def jaarverslagen_end
        put_out "</#{@afk}:jaarverslagen>"
    end

    def jaarverslagen_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:jaarverslagen_opmerkingen rdf:parseType=\"Literal\">"
    end

    def jaarverslagen_opmerkingen_end
        put_out "</#{@afk}:jaarverslagen_opmerkingen>"
    end

    def audio_visuele_elementen_start attrs
        put_out "\n#{@indent}<#{@afk}:audio_visuele_elementen>"
    end

    def audio_visuele_elementen_end
        put_out "</#{@afk}:audio_visuele_elementen>"
    end

    def audio_visuele_elementen_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:audio_visuele_elementen_opmerkingen rdf:parseType=\"Literal\">"
    end

    def audio_visuele_elementen_opmerkingen_end
        put_out "</#{@afk}:audio_visuele_elementen_opmerkingen>"
    end

    def correspondentie_start attrs
        put_out "\n#{@indent}<#{@afk}:correspondentie>"
    end

    def correspondentie_end
        put_out "</#{@afk}:correspondentie>"
    end

    def correspondentie_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:correspondentie_opmerkingen rdf:parseType=\"Literal\">"
    end

    def correspondentie_opmerkingen_end
        put_out "</#{@afk}:correspondentie_opmerkingen>"
    end

    def financiele_stukken_start attrs
        put_out "\n#{@indent}<#{@afk}:financiele_stukken>"
    end

    def financiele_stukken_end
        put_out "</#{@afk}:financiele_stukken>"
    end

    def financiele_stukken_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:financiele_stukken_opmerkingen rdf:parseType=\"Literal\">"
    end

    def financiele_stukken_opmerkingen_end
        put_out "</#{@afk}:financiele_stukken_opmerkingen>"
    end

    def overige_stukken_start attrs
        put_out "\n#{@indent}<#{@afk}:overige_stukken>"
    end

    def overige_stukken_end
        put_out "</#{@afk}:overige_stukken>"
    end

    def overige_opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:overige_opmerkingen rdf:parseType=\"Literal\">"
    end

    def overige_opmerkingen_end
        put_out "</#{@afk}:overige_opmerkingen>"
    end

    def table
       	{"provincie"=>{2=>"provincies"}, "bisdom"=>{2=>"bisdommen"}, "werkingsgebied"=>{2=>"werkingsgebieden"}, "relatie"=>{3=>"Relatie"}}
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

