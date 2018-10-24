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
	@in_fs_comm = false
	@in_verw_sh_act = false
	@in_aut_rap_inst = false
    end

    def avmat_start attrs
        put_out "\n#{@indent}<#{@afk}:avmat>"
    end

    def avmat_end
        put_out "</#{@afk}:avmat>"
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

    def maker_start attrs
        put_out "\n#{@indent}<#{@afk}:maker rdf:parseType=\"Literal\">"
    end

    def maker_end
        put_out "</#{@afk}:maker>"
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

    def vindplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:vindplaats>"
    end

    def vindplaats_end
        put_out "</#{@afk}:vindplaats>"
    end

    def documentnr_start attrs
        put_out "\n#{@indent}<#{@afk}:documentnr>"
    end

    def documentnr_end
        put_out "</#{@afk}:documentnr>"
    end

    def rechthebbenden_start attrs
        put_out "\n#{@indent}<#{@afk}:rechthebbenden>"
    end

    def rechthebbenden_end
        put_out "</#{@afk}:rechthebbenden>"
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

    def themas_start attrs
        put_out "\n#{@indent}<#{@afk}:themas>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def themas_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:themas>"
    end

    def themapaar_start attrs
        put_out "\n#{@indent}<#{@afk}:themapaar rdf:parseType=\"Resource\">"
    end

    def themapaar_end
        put_out "</#{@afk}:themapaar>"
    end

    def Thema_start attrs
        put_out "\n#{@indent}<#{@afk}:Thema>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def Thema_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:Thema>"
    end

    def thema_start attrs
        put_out "\n#{@indent}<#{@afk}:thema>"
    end

    def thema_end
        put_out "</#{@afk}:thema>"
    end

    def subthema_start attrs
        put_out "\n#{@indent}<#{@afk}:subthema>"
    end

    def subthema_end
        put_out "</#{@afk}:subthema>"
    end

    def commissies_start attrs
        put_out "\n#{@indent}<#{@afk}:commissies>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def commissies_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:commissies>"
    end

    def commissie_start attrs
        put_out "\n#{@indent}<#{@afk}:commissie>"
    end

    def commissie_end
        put_out "</#{@afk}:commissie>"
    end

    def personen_start attrs
        put_out "\n#{@indent}<#{@afk}:personen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def personen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:personen>"
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon rdf:parseType=\"Resource\">"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def naam_persoon_inst_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_persoon_inst>"
    end

    def naam_persoon_inst_end
        put_out "</#{@afk}:naam_persoon_inst>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def beschrijving_start attrs
        put_out "\n#{@indent}<#{@afk}:beschrijving rdf:parseType=\"Literal\">"
    end

    def beschrijving_end
        put_out "</#{@afk}:beschrijving>"
    end

    def geselecteerd_start attrs
        put_out "\n#{@indent}<#{@afk}:geselecteerd>"
    end

    def geselecteerd_end
        put_out "</#{@afk}:geselecteerd>"
    end

    def kosten_start attrs
        put_out "\n#{@indent}<#{@afk}:kosten rdf:parseType=\"Literal\">"
    end

    def kosten_end
        put_out "</#{@afk}:kosten>"
    end

    def status_start attrs
        put_out "\n#{@indent}<#{@afk}:status rdf:parseType=\"Literal\">"
    end

    def status_end
        put_out "</#{@afk}:status>"
    end

    def naambestand_start attrs
        put_out "\n#{@indent}<#{@afk}:naambestand rdf:parseType=\"Literal\">"
    end

    def naambestand_end
        put_out "</#{@afk}:naambestand>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def factsheetcommissie_start attrs
        put_out "\n#{@indent}<#{@afk}:factsheetcommissie>"
    end

    def factsheetcommissie_end
        put_out "</#{@afk}:factsheetcommissie>"
    end

    def herzieningsjaar_start attrs
        put_out "\n#{@indent}<#{@afk}:herzieningsjaar>"
    end

    def herzieningsjaar_end
        put_out "</#{@afk}:herzieningsjaar>"
    end

    def naam_voorzitter_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def naam_voorzitter_end
        put_out "</schema:title>"
    end

    def officiele_naam_start attrs
        put_out "\n#{@indent}<#{@afk}:officiele_naam>"
    end

    def officiele_naam_end
        put_out "</#{@afk}:officiele_naam>"
    end

    def naamsvarianten_start attrs
        put_out "\n#{@indent}<#{@afk}:naamsvarianten>"
    end

    def naamsvarianten_end
        put_out "</#{@afk}:naamsvarianten>"
    end

    def opdracht_start attrs
        put_out "\n#{@indent}<#{@afk}:opdracht>"
    end

    def opdracht_end
        put_out "</#{@afk}:opdracht>"
    end

    def jaren_start attrs
        put_out "\n#{@indent}<#{@afk}:jaren>"
    end

    def jaren_end
        put_out "</#{@afk}:jaren>"
    end

    def kb_instelling_start attrs
        put_out "\n#{@indent}<#{@afk}:kb_instelling>"
    end

    def kb_instelling_end
        put_out "</#{@afk}:kb_instelling>"
    end

    def kb_ontbinding_start attrs
        put_out "\n#{@indent}<#{@afk}:kb_ontbinding>"
    end

    def kb_ontbinding_end
        put_out "</#{@afk}:kb_ontbinding>"
    end

    def aantal_bijeenkomsten_start attrs
        put_out "\n#{@indent}<#{@afk}:aantal_bijeenkomsten>"
    end

    def aantal_bijeenkomsten_end
        put_out "</#{@afk}:aantal_bijeenkomsten>"
    end

    def datum_eindverslag_start attrs
        put_out "\n#{@indent}<#{@afk}:datum_eindverslag>"
    end

    def datum_eindverslag_end
        put_out "</#{@afk}:datum_eindverslag>"
    end

    def datum_aanbieding_aan_tk_start attrs
        put_out "\n#{@indent}<#{@afk}:datum_aanbieding_aan_tk>"
    end

    def datum_aanbieding_aan_tk_end
        put_out "</#{@afk}:datum_aanbieding_aan_tk>"
    end

    def samenstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:samenstelling>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def samenstelling_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:samenstelling>"
    end

    def naam_persoon_inst_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_persoon_inst>"
    end

    def naam_persoon_inst_end
        put_out "</#{@afk}:naam_persoon_inst>"
    end

    def Functie_start attrs
        put_out "\n#{@indent}<#{@afk}:Functie rdf:parseType=\"Resource\">"
    end

    def Functie_end
        put_out "</#{@afk}:Functie>"
    end

    def functie_start attrs
        put_out "\n#{@indent}<#{@afk}:functie>"
    end

    def functie_end
        put_out "</#{@afk}:functie>"
    end

    def partij_start attrs
        put_out "\n#{@indent}<#{@afk}:partij>"
    end

    def partij_end
        put_out "</#{@afk}:partij>"
    end

    def subcommissies_start attrs
        put_out "\n#{@indent}<#{@afk}:subcommissies rdf:parseType=\"Literal\">"
    end

    def subcommissies_end
        put_out "</#{@afk}:subcommissies>"
    end

    def verslagen_start attrs
        put_out "\n#{@indent}<#{@afk}:verslagen rdf:parseType=\"Literal\">"
    end

    def verslagen_end
        put_out "</#{@afk}:verslagen>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Literal\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def av_bronnen_start attrs
        put_out "\n#{@indent}<#{@afk}:av_bronnen rdf:parseType=\"Literal\">"
    end

    def av_bronnen_end
        put_out "</#{@afk}:av_bronnen>"
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

    def autopsierapportcommissies_start attrs
        put_out "\n#{@indent}<#{@afk}:autopsierapportcommissies>"
    end

    def autopsierapportcommissies_end
        put_out "</#{@afk}:autopsierapportcommissies>"
    end

    def naam_start attrs
        put_out "\n#{@indent}<schema:name>"
    end

    def naam_end
        put_out "</schema:name>"
    end

    def naam_archiefvormer_start attrs
	if @in_aut_rap_inst
	    put_out "\n#{@indent}<schema:title>"
	else
	    put_out "\n#{@indent}<#{@afk}:naam_archiefvormer>"
	end
    end

    def naam_archiefvormer_end
	if @in_aut_rap_inst
	    put_out "\n#{@indent}</schema:title>"
	else
	    put_out "</#{@afk}:naam_archiefvormer>"
	end
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

    def soort_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:soort_toegang>"
    end

    def soort_toegang_end
        put_out "</#{@afk}:soort_toegang>"
    end

    def kenmerk_toegang_start attrs
        put_out "\n#{@indent}<#{@afk}:kenmerk_toegang>"
    end

    def kenmerk_toegang_end
        put_out "</#{@afk}:kenmerk_toegang>"
    end

    def inventaris_geraadpleegd_start attrs
        put_out "\n#{@indent}<#{@afk}:inventaris_geraadpleegd>"
    end

    def inventaris_geraadpleegd_end
        put_out "</#{@afk}:inventaris_geraadpleegd>"
    end

    def stukken_geraadpleegd_start attrs
        put_out "\n#{@indent}<#{@afk}:stukken_geraadpleegd>"
    end

    def stukken_geraadpleegd_end
        put_out "</#{@afk}:stukken_geraadpleegd>"
    end

    def inventarisnummers_start attrs
        put_out "\n#{@indent}<#{@afk}:inventarisnummers>"
    end

    def inventarisnummers_end
        put_out "</#{@afk}:inventarisnummers>"
    end

    def aard_van_de_documentatie_start attrs
        put_out "\n#{@indent}<#{@afk}:aard_van_de_documentatie>"
    end

    def aard_van_de_documentatie_end
        put_out "</#{@afk}:aard_van_de_documentatie>"
    end

    def inhoud_start attrs
        put_out "\n#{@indent}<#{@afk}:inhoud rdf:parseType=\"Literal\">"
    end

    def inhoud_end
        put_out "</#{@afk}:inhoud>"
    end

    def opmerkingen_overig_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_overig rdf:parseType=\"Literal\">"
    end

    def opmerkingen_overig_end
        put_out "</#{@afk}:opmerkingen_overig>"
    end

    def inventaris_bewerkt_door_start attrs
        put_out "\n#{@indent}<#{@afk}:inventaris_bewerkt_door>"
    end

    def inventaris_bewerkt_door_end
        put_out "</#{@afk}:inventaris_bewerkt_door>"
    end

    def stukken_bewerkt_door_start attrs
        put_out "\n#{@indent}<#{@afk}:stukken_bewerkt_door>"
    end

    def stukken_bewerkt_door_end
        put_out "</#{@afk}:stukken_bewerkt_door>"
    end

    def definitief_start attrs
        put_out "\n#{@indent}<#{@afk}:definitief>"
    end

    def definitief_end
        put_out "</#{@afk}:definitief>"
    end

    def verwijzingsheetactoren_start attrs
        put_out "\n#{@indent}<#{@afk}:verwijzingsheetactoren>"
    end

    def verwijzingsheetactoren_end
        put_out "</#{@afk}:verwijzingsheetactoren>"
    end

    def naam_staatscommissie_start attrs
	if @in_verw_sh_act
	    put_out "\n#{@indent}<schema:title>"
	else
	    put_out "\n#{@indent}<#{@afk}:naam_staatscommissie>"
	end
    end

    def naam_staatscommissie_end
	if @in_verw_sh_act
	    put_out "\n#{@indent}</schema:title>"
	else
	    put_out "</#{@afk}:naam_staatscommissie>"
	end
    end

    def overige_betrokkenen_start attrs
        put_out "\n#{@indent}<#{@afk}:overige_betrokkenen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def overige_betrokkenen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:overige_betrokkenen>"
    end

    def collectie_start attrs
        put_out "\n#{@indent}<#{@afk}:collectie>"
    end

    def collectie_end
        put_out "</#{@afk}:collectie>"
    end

    def overige_betrokkenen_instellingen_start attrs
        put_out "\n#{@indent}<#{@afk}:overige_betrokkenen_instellingen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def overige_betrokkenen_instellingen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:overige_betrokkenen_instellingen>"
    end

    def instelling_start attrs
        put_out "\n#{@indent}<#{@afk}:instelling rdf:parseType=\"Resource\">"
    end

    def instelling_end
        put_out "</#{@afk}:instelling>"
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

    def factsheetpersoon_start attrs
        put_out "\n#{@indent}<#{@afk}:factsheetpersoon>"
    end

    def factsheetpersoon_end
        put_out "</#{@afk}:factsheetpersoon>"
    end

    def leefjaren_start attrs
        put_out "\n#{@indent}<#{@afk}:leefjaren>"
    end

    def leefjaren_end
        put_out "</#{@afk}:leefjaren>"
    end

    def politieke_partij_start attrs
        put_out "\n#{@indent}<#{@afk}:politieke_partij>"
    end

    def politieke_partij_end
        put_out "</#{@afk}:politieke_partij>"
    end

    def functies_start attrs
        put_out "\n#{@indent}<#{@afk}:functies>"
    end

    def functies_end
        put_out "</#{@afk}:functies>"
    end

    def biografische_gegevens_in_start attrs
        put_out "\n#{@indent}<#{@afk}:biografische_gegevens_in rdf:parseType=\"Literal\">"
    end

    def biografische_gegevens_in_end
        put_out "</#{@afk}:biografische_gegevens_in>"
    end

    def literatuur_in_lijst_start attrs
	if @in_fs_comm
	    put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Literal\">"
	else
            put_out "\n#{@indent}<#{@afk}:literatuur_in_lijst rdf:parseType=\"Literal\">"
	end
    end

    def literatuur_in_lijst_end
	if @in_fs_comm
	    put_out "</#{@afk}:literatuur>"
	    @in_fs_comm = false
	else
	    put_out "</#{@afk}:literatuur_in_lijst>"
	end
    end

    def zitting_start attrs
        put_out "\n#{@indent}<#{@afk}:zitting>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def zitting_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:zitting>"
    end

    def zitting_in_start attrs
        put_out "\n#{@indent}<#{@afk}:zitting_in rdf:parseType=\"Resource\">"
    end

    def zitting_in_end
        put_out "</#{@afk}:zitting_in>"
    end

    def betrokken_start attrs
        put_out "\n#{@indent}<#{@afk}:betrokken>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def betrokken_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:betrokken>"
    end

    def betrokken_bij_start attrs
        put_out "\n#{@indent}<#{@afk}:betrokken_bij rdf:parseType=\"Resource\">"
    end

    def betrokken_bij_end
        put_out "</#{@afk}:betrokken_bij>"
    end

    def opmerkingen_archivalia_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen_archivalia rdf:parseType=\"Literal\">"
    end

    def opmerkingen_archivalia_end
        put_out "</#{@afk}:opmerkingen_archivalia>"
    end

    def autopsierapportpersonen_start attrs
        put_out "\n#{@indent}<#{@afk}:autopsierapportpersonen>"
    end

    def autopsierapportpersonen_end
        put_out "</#{@afk}:autopsierapportpersonen>"
    end

    def naam_archiefcollectie_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_archiefcollectie>"
    end

    def naam_archiefcollectie_end
        put_out "</#{@afk}:naam_archiefcollectie>"
    end

    def staatscommissie_start attrs
        put_out "\n#{@indent}<#{@afk}:staatscommissie>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def staatscommissie_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:staatscommissie>"
    end

    def in_staatscommissie_start attrs
        put_out "\n#{@indent}<#{@afk}:in_staatscommissie rdf:parseType=\"Resource\">"
    end

    def in_staatscommissie_end
        put_out "</#{@afk}:in_staatscommissie>"
    end

    def waardering_belang_archivalia_start attrs
        put_out "\n#{@indent}<#{@afk}:waardering_belang_archivalia rdf:parseType=\"Literal\">"
    end

    def waardering_belang_archivalia_end
        put_out "</#{@afk}:waardering_belang_archivalia>"
    end

    def bijzondere_stukken_start attrs
        put_out "\n#{@indent}<#{@afk}:bijzondere_stukken rdf:parseType=\"Literal\">"
    end

    def bijzondere_stukken_end
        put_out "</#{@afk}:bijzondere_stukken>"
    end

    def factsheetinstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:factsheetinstelling>"
    end

    def factsheetinstelling_end
        put_out "</#{@afk}:factsheetinstelling>"
    end

    def naam_varianten_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_varianten>"
    end

    def naam_varianten_end
        put_out "</#{@afk}:naam_varianten>"
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

    def taken_start attrs
        put_out "\n#{@indent}<#{@afk}:taken rdf:parseType=\"Literal\">"
    end

    def taken_end
        put_out "</#{@afk}:taken>"
    end

    def autopsierapportinstellingen_start attrs
        put_out "\n#{@indent}<#{@afk}:autopsierapportinstellingen>"
    end

    def autopsierapportinstellingen_end
        put_out "</#{@afk}:autopsierapportinstellingen>"
    end

    def formulierselectie_start attrs
        put_out "\n#{@indent}<#{@afk}:formulierselectie>"
    end

    def formulierselectie_end
        put_out "</#{@afk}:formulierselectie>"
    end

    def formnr_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def formnr_end
        put_out "</schema:title>"
    end

    def documentnaam_start attrs
        put_out "\n#{@indent}<#{@afk}:documentnaam rdf:parseType=\"Literal\">"
    end

    def documentnaam_end
        put_out "</#{@afk}:documentnaam>"
    end

    def aard_stuk_start attrs
        put_out "\n#{@indent}<#{@afk}:aard_stuk>"
    end

    def aard_stuk_end
        put_out "</#{@afk}:aard_stuk>"
    end

    def ontwikkelingsstadium_start attrs
        put_out "\n#{@indent}<#{@afk}:ontwikkelingsstadium>"
    end

    def ontwikkelingsstadium_end
        put_out "</#{@afk}:ontwikkelingsstadium>"
    end

    def opm_datum_start attrs
        put_out "\n#{@indent}<#{@afk}:opm_datum>"
    end

    def opm_datum_end
        put_out "</#{@afk}:opm_datum>"
    end

    def bronfragment_start attrs
        put_out "\n#{@indent}<#{@afk}:bronfragment rdf:parseType=\"Literal\">"
    end

    def bronfragment_end
        put_out "</#{@afk}:bronfragment>"
    end

    def aant_annotatie_start attrs
        put_out "\n#{@indent}<#{@afk}:aant_annotatie rdf:parseType=\"Literal\">"
    end

    def aant_annotatie_end
        put_out "</#{@afk}:aant_annotatie>"
    end

    def paginas_start attrs
        put_out "\n#{@indent}<#{@afk}:paginas rdf:parseType=\"Literal\">"
    end

    def paginas_end
        put_out "</#{@afk}:paginas>"
    end

    def grondwetartikelen_start attrs
        put_out "\n#{@indent}<#{@afk}:grondwetartikelen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def grondwetartikelen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:grondwetartikelen>"
    end

    def grondwetartikel_start attrs
        put_out "\n#{@indent}<#{@afk}:grondwetartikel rdf:parseType=\"Resource\">"
    end

    def grondwetartikel_end
        put_out "</#{@afk}:grondwetartikel>"
    end

    def jaar_start attrs
        put_out "\n#{@indent}<#{@afk}:jaar>"
    end

    def jaar_end
        put_out "</#{@afk}:jaar>"
    end

    def artikel_start attrs
        put_out "\n#{@indent}<#{@afk}:artikel>"
    end

    def artikel_end
        put_out "</#{@afk}:artikel>"
    end

    def lid_start attrs
        put_out "\n#{@indent}<#{@afk}:lid>"
    end

    def lid_end
        put_out "</#{@afk}:lid>"
    end

    def fragment_start attrs
        put_out "\n#{@indent}<#{@afk}:fragment rdf:parseType=\"Literal\">"
    end

    def fragment_end
        put_out "</#{@afk}:fragment>"
    end

    def overige_actoren_start attrs
        put_out "\n#{@indent}<#{@afk}:overige_actoren>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def overige_actoren_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:overige_actoren>"
    end

    def actoren_start attrs
        put_out "\n#{@indent}<#{@afk}:actoren rdf:parseType=\"Resource\">"
    end

    def actoren_end
        put_out "</#{@afk}:actoren>"
    end

    def actoor_start attrs
        put_out "\n#{@indent}<#{@afk}:actoor>"
    end

    def actoor_end
        put_out "</#{@afk}:actoor>"
    end

    def literatuurlijst_start attrs
	if @in_fs_comm
	    put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Literal\">"
	else
            put_out "\n#{@indent}<#{@afk}:literatuurlijst>"
  	    put_out "\n#{@indent}<rdf:Seq>"
	end
    end

    def literatuurlijst_end
	if @in_fs_comm
	    put_out "\n#{@indent}</#{@afk}:literatuur>"
	    @in_fs_comm = false
	else
  	    @output.puts "\n#{@indent}</rdf:Seq>"
            indent = "  " * (@level - 1)
  	    put_out "#{indent}"
            put_out "</#{@afk}:literatuurlijst>"
	end
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur rdf:parseType=\"Resource\">"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def literatuur_titel_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur_titel>"
    end

    def literatuur_titel_end
        put_out "</#{@afk}:literatuur_titel>"
    end

    def samenhangende_stukken_start attrs
        put_out "\n#{@indent}<#{@afk}:samenhangende_stukken>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def samenhangende_stukken_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:samenhangende_stukken>"
    end

    def stukken_start attrs
        put_out "\n#{@indent}<#{@afk}:stukken rdf:parseType=\"Resource\">"
    end

    def stukken_end
        put_out "</#{@afk}:stukken>"
    end

    def stuk_start attrs
        put_out "\n#{@indent}<#{@afk}:stuk>"
    end

    def stuk_end
        put_out "</#{@afk}:stuk>"
    end

    def waardering1_start attrs
        put_out "\n#{@indent}<#{@afk}:waardering1>"
    end

    def waardering1_end
        put_out "</#{@afk}:waardering1>"
    end

    def waardering2_start attrs
        put_out "\n#{@indent}<#{@afk}:waardering2>"
    end

    def waardering2_end
        put_out "</#{@afk}:waardering2>"
    end

    def waardering3_start attrs
        put_out "\n#{@indent}<#{@afk}:waardering3>"
    end

    def waardering3_end
        put_out "</#{@afk}:waardering3>"
    end

    def wt1_start attrs
        put_out "\n#{@indent}<#{@afk}:wt1>"
    end

    def wt1_end
        put_out "</#{@afk}:wt1>"
    end

    def wt2_start attrs
        put_out "\n#{@indent}<#{@afk}:wt2>"
    end

    def wt2_end
        put_out "</#{@afk}:wt2>"
    end

    def wt3_start attrs
        put_out "\n#{@indent}<#{@afk}:wt3>"
    end

    def wt3_end
        put_out "</#{@afk}:wt3>"
    end

    def wt4_start attrs
        put_out "\n#{@indent}<#{@afk}:wt4>"
    end

    def wt4_end
        put_out "</#{@afk}:wt4>"
    end

    def wt5_start attrs
        put_out "\n#{@indent}<#{@afk}:wt5>"
    end

    def wt5_end
        put_out "</#{@afk}:wt5>"
    end

    def table
       	{"thema"=>{2=>"themas", 3=>"themapaar", 4=>"Thema"}, "commissie"=>{2=>"commissies"}, "persoon"=>{4=>"naam_persoon_inst"}, "naam"=>{4=>"naam_persoon_inst"}, "functies"=>{4=>"Functie"}, "grondwetartikel"=>{2=>"grondwetartikelen"}, "literatuur"=>{2=>"literatuurlijst", 4=>"literatuur_titel"}}
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
	    @in_fs_comm = true if name.eql?("factsheetcommissie")
	    @in_fs_comm = true if name.eql?("factsheetinstelling")
	    @in_fs_comm = true if name.eql?("factsheetpersoon")
	    @in_verw_sh_act = true if name.eql?("verwijzingsheetactoren")
	    @in_aut_rap_inst = true if name.eql?("autopsierapportinstellingen")
        lines =<<EOF


  <rdf:Description rdf:about="https://resource.huygens.knaw.nl/ingforms/#{@collection}/#{name}/#{code}">
    <rdf:type rdf:resource="https://resource.huygens.knaw.nl/ingforms/#{@collection}/#{name}" />
EOF
            put_out lines
        else
            begin
                result = self.send( "#{name}_start", attrs )
                rescue => detail
                    STDERR.puts "#{detail}\nin #{name}"
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

