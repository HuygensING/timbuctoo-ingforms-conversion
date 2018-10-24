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

    def province_start attrs
        put_out "\n#{@indent}<#{@afk}:province>"
    end

    def province_end
        put_out "</#{@afk}:province>"
    end

    def naam_kort_start attrs
        put_out "\n#{@indent}<#{@afk}:naam_kort>"
    end

    def naam_kort_end
        put_out "</#{@afk}:naam_kort>"
    end

    def text_start attrs
        put_out "\n#{@indent}<#{@afk}:text rdf:parseType=\"Literal\">"
    end

    def text_end
        put_out "</#{@afk}:text>"
    end

    def word_document_start attrs
        put_out "\n#{@indent}<#{@afk}:word_document>"
    end

    def word_document_end
        put_out "</#{@afk}:word_document>"
    end

    def city_start attrs
        put_out "\n#{@indent}<#{@afk}:city>"
    end

    def city_end
        put_out "</#{@afk}:city>"
    end

    def provincie_start attrs
        put_out "\n#{@indent}<#{@afk}:provincie>"
    end

    def provincie_end
        put_out "</#{@afk}:provincie>"
    end

    def vereniging_start attrs
        put_out "\n#{@indent}<#{@afk}:vereniging>"
    end

    def vereniging_end
        put_out "</#{@afk}:vereniging>"
    end

    def pkcorpus_start attrs
        put_out "\n#{@indent}<#{@afk}:pkcorpus>"
    end

    def pkcorpus_end
        put_out "</#{@afk}:pkcorpus>"
    end

    def opr_jaar_start attrs
        put_out "\n#{@indent}<#{@afk}:opr_jaar>"
    end

    def opr_jaar_end
        put_out "</#{@afk}:opr_jaar>"
    end

    def oph_jaar_start attrs
        put_out "\n#{@indent}<#{@afk}:oph_jaar>"
    end

    def oph_jaar_end
        put_out "</#{@afk}:oph_jaar>"
    end

    def eerste_verm_start attrs
        put_out "\n#{@indent}<#{@afk}:eerste_verm>"
    end

    def eerste_verm_end
        put_out "</#{@afk}:eerste_verm>"
    end

    def laatste_verm_start attrs
        put_out "\n#{@indent}<#{@afk}:laatste_verm>"
    end

    def laatste_verm_end
        put_out "</#{@afk}:laatste_verm>"
    end

    def fusie_start attrs
        put_out "\n#{@indent}<#{@afk}:fusie>"
    end

    def fusie_end
        put_out "</#{@afk}:fusie>"
    end

    def fusie_res_nr_start attrs
        put_out "\n#{@indent}<#{@afk}:fusie_res_nr>"
    end

    def fusie_res_nr_end
        put_out "</#{@afk}:fusie_res_nr>"
    end

    def fusie_res_start attrs
        put_out "\n#{@indent}<#{@afk}:fusie_res>"
    end

    def fusie_res_end
        put_out "</#{@afk}:fusie_res>"
    end

    def split_start attrs
        put_out "\n#{@indent}<#{@afk}:split>"
    end

    def split_end
        put_out "</#{@afk}:split>"
    end

    def split_naam_start attrs
        put_out "\n#{@indent}<#{@afk}:split_naam>"
    end

    def split_naam_end
        put_out "</#{@afk}:split_naam>"
    end

    def plaats_start attrs
        put_out "\n#{@indent}<#{@afk}:plaats>"
    end

    def plaats_end
        put_out "</#{@afk}:plaats>"
    end

    def produkt1_start attrs
        put_out "\n#{@indent}<#{@afk}:produkt1>"
    end

    def produkt1_end
        put_out "</#{@afk}:produkt1>"
    end

    def produkt2_start attrs
        put_out "\n#{@indent}<#{@afk}:produkt2>"
    end

    def produkt2_end
        put_out "</#{@afk}:produkt2>"
    end

    def produkt3_start attrs
        put_out "\n#{@indent}<#{@afk}:produkt3>"
    end

    def produkt3_end
        put_out "</#{@afk}:produkt3>"
    end

    def produkt4_start attrs
        put_out "\n#{@indent}<#{@afk}:produkt4>"
    end

    def produkt4_end
        put_out "</#{@afk}:produkt4>"
    end

    def ziekengeld_start attrs
        put_out "\n#{@indent}<#{@afk}:ziekengeld>"
    end

    def ziekengeld_end
        put_out "</#{@afk}:ziekengeld>"
    end

    def ziektekosten_start attrs
        put_out "\n#{@indent}<#{@afk}:ziektekosten>"
    end

    def ziektekosten_end
        put_out "</#{@afk}:ziektekosten>"
    end

    def begrafenisgeld_start attrs
        put_out "\n#{@indent}<#{@afk}:begrafenisgeld>"
    end

    def begrafenisgeld_end
        put_out "</#{@afk}:begrafenisgeld>"
    end

    def weduwegeld_start attrs
        put_out "\n#{@indent}<#{@afk}:weduwegeld>"
    end

    def weduwegeld_end
        put_out "</#{@afk}:weduwegeld>"
    end

    def wezen_start attrs
        put_out "\n#{@indent}<#{@afk}:wezen>"
    end

    def wezen_end
        put_out "</#{@afk}:wezen>"
    end

    def ouderdom_start attrs
        put_out "\n#{@indent}<#{@afk}:ouderdom>"
    end

    def ouderdom_end
        put_out "</#{@afk}:ouderdom>"
    end

    def overlijden_start attrs
        put_out "\n#{@indent}<#{@afk}:overlijden>"
    end

    def overlijden_end
        put_out "</#{@afk}:overlijden>"
    end

    def lijfrente_start attrs
        put_out "\n#{@indent}<#{@afk}:lijfrente>"
    end

    def lijfrente_end
        put_out "</#{@afk}:lijfrente>"
    end

    def docmap_start attrs
        put_out "\n#{@indent}<#{@afk}:docmap>"
    end

    def docmap_end
        put_out "</#{@afk}:docmap>"
    end

    def opmerking_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerking>"
    end

    def opmerking_end
        put_out "</#{@afk}:opmerking>"
    end

    def loka_start attrs
        put_out "\n#{@indent}<#{@afk}:loka>"
    end

    def loka_end
        put_out "</#{@afk}:loka>"
    end

    def aard_start attrs
        put_out "\n#{@indent}<#{@afk}:aard>"
    end

    def aard_end
        put_out "</#{@afk}:aard>"
    end

    def kb1830_lev_start attrs
        put_out "\n#{@indent}<#{@afk}:kb1830_lev>"
    end

    def kb1830_lev_end
        put_out "</#{@afk}:kb1830_lev>"
    end

    def beroepcode_start attrs
        put_out "\n#{@indent}<#{@afk}:beroepcode>"
    end

    def beroepcode_end
        put_out "</#{@afk}:beroepcode>"
    end

    def armv_start attrs
        put_out "\n#{@indent}<#{@afk}:armv>"
    end

    def armv_end
        put_out "</#{@afk}:armv>"
    end

    def verstrekking_start attrs
        put_out "\n#{@indent}<#{@afk}:verstrekking>"
    end

    def verstrekking_end
        put_out "</#{@afk}:verstrekking>"
    end

    def levensduur_start attrs
        put_out "\n#{@indent}<#{@afk}:levensduur>"
    end

    def levensduur_end
        put_out "</#{@afk}:levensduur>"
    end

    def levensduur1_start attrs
        put_out "\n#{@indent}<#{@afk}:levensduur1>"
    end

    def levensduur1_end
        put_out "</#{@afk}:levensduur1>"
    end

    def laatste_verandering_start attrs
        put_out "\n#{@indent}<#{@afk}:laatste_verandering>"
    end

    def laatste_verandering_end
        put_out "</#{@afk}:laatste_verandering>"
    end

    def original_db_start attrs
        put_out "\n#{@indent}<#{@afk}:original_db>"
    end

    def original_db_end
        put_out "</#{@afk}:original_db>"
    end

    def original_db_table_start attrs
        put_out "\n#{@indent}<#{@afk}:original_db_table>"
    end

    def original_db_table_end
        put_out "</#{@afk}:original_db_table>"
    end

    def leden_start attrs
        put_out "\n#{@indent}<#{@afk}:leden>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def leden_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:leden>"
    end

    def lid_start attrs
        put_out "\n#{@indent}<#{@afk}:lid rdf:parseType=\"Resource\">"
    end

    def lid_end
        put_out "</#{@afk}:lid>"
    end

    def jaar_start attrs
        put_out "\n#{@indent}<#{@afk}:jaar>"
    end

    def jaar_end
        put_out "</#{@afk}:jaar>"
    end

    def aantal_start attrs
        put_out "\n#{@indent}<#{@afk}:aantal>"
    end

    def aantal_end
        put_out "</#{@afk}:aantal>"
    end

    def datering_start attrs
        put_out "\n#{@indent}<#{@afk}:datering>"
    end

    def datering_end
        put_out "</#{@afk}:datering>"
    end

    def opr_min_start attrs
        put_out "\n#{@indent}<#{@afk}:opr_min>"
    end

    def opr_min_end
        put_out "</#{@afk}:opr_min>"
    end

    def opr_max_start attrs
        put_out "\n#{@indent}<#{@afk}:opr_max>"
    end

    def opr_max_end
        put_out "</#{@afk}:opr_max>"
    end

    def oph_min_start attrs
        put_out "\n#{@indent}<#{@afk}:oph_min>"
    end

    def oph_min_end
        put_out "</#{@afk}:oph_min>"
    end

    def oph_max_start attrs
        put_out "\n#{@indent}<#{@afk}:oph_max>"
    end

    def oph_max_end
        put_out "</#{@afk}:oph_max>"
    end

    def split_nr_start attrs
        put_out "\n#{@indent}<#{@afk}:split_nr>"
    end

    def split_nr_end
        put_out "</#{@afk}:split_nr>"
    end

    def begjr_start attrs
        put_out "\n#{@indent}<#{@afk}:begjr>"
    end

    def begjr_end
        put_out "</#{@afk}:begjr>"
    end

    def zbegjr_start attrs
        put_out "\n#{@indent}<#{@afk}:zbegjr>"
    end

    def zbegjr_end
        put_out "</#{@afk}:zbegjr>"
    end

    def sbegjr_start attrs
        put_out "\n#{@indent}<#{@afk}:sbegjr>"
    end

    def sbegjr_end
        put_out "</#{@afk}:sbegjr>"
    end

    def einjr_start attrs
        put_out "\n#{@indent}<#{@afk}:einjr>"
    end

    def einjr_end
        put_out "</#{@afk}:einjr>"
    end

    def zeinjr_start attrs
        put_out "\n#{@indent}<#{@afk}:zeinjr>"
    end

    def zeinjr_end
        put_out "</#{@afk}:zeinjr>"
    end

    def seinjr_start attrs
        put_out "\n#{@indent}<#{@afk}:seinjr>"
    end

    def seinjr_end
        put_out "</#{@afk}:seinjr>"
    end

    def stpl_start attrs
        put_out "\n#{@indent}<#{@afk}:stpl>"
    end

    def stpl_end
        put_out "</#{@afk}:stpl>"
    end

    def regio_start attrs
        put_out "\n#{@indent}<#{@afk}:regio>"
    end

    def regio_end
        put_out "</#{@afk}:regio>"
    end

    def zregio_start attrs
        put_out "\n#{@indent}<#{@afk}:zregio>"
    end

    def zregio_end
        put_out "</#{@afk}:zregio>"
    end

    def periode_start attrs
        put_out "\n#{@indent}<#{@afk}:periode>"
    end

    def periode_end
        put_out "</#{@afk}:periode>"
    end

    def poph_jaar_start attrs
        put_out "\n#{@indent}<#{@afk}:poph_jaar>"
    end

    def poph_jaar_end
        put_out "</#{@afk}:poph_jaar>"
    end

    def plaatste_verm_start attrs
        put_out "\n#{@indent}<#{@afk}:plaatste_verm>"
    end

    def plaatste_verm_end
        put_out "</#{@afk}:plaatste_verm>"
    end

    def pfusie_start attrs
        put_out "\n#{@indent}<#{@afk}:pfusie>"
    end

    def pfusie_end
        put_out "</#{@afk}:pfusie>"
    end

    def bezittingen_start attrs
        put_out "\n#{@indent}<#{@afk}:bezittingen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def bezittingen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:bezittingen>"
    end

    def Bezit_start attrs
        put_out "\n#{@indent}<#{@afk}:Bezit rdf:parseType=\"Resource\">"
    end

    def Bezit_end
        put_out "</#{@afk}:Bezit>"
    end

    def b_1_start attrs
        put_out "\n#{@indent}<#{@afk}:b_1>"
    end

    def b_1_end
        put_out "</#{@afk}:b_1>"
    end

    def b_1_details_start attrs
        put_out "\n#{@indent}<#{@afk}:b_1_details>"
    end

    def b_1_details_end
        put_out "</#{@afk}:b_1_details>"
    end

    def b_2_start attrs
        put_out "\n#{@indent}<#{@afk}:b_2>"
    end

    def b_2_end
        put_out "</#{@afk}:b_2>"
    end

    def b_2_details_start attrs
        put_out "\n#{@indent}<#{@afk}:b_2_details>"
    end

    def b_2_details_end
        put_out "</#{@afk}:b_2_details>"
    end

    def b_3_start attrs
        put_out "\n#{@indent}<#{@afk}:b_3>"
    end

    def b_3_end
        put_out "</#{@afk}:b_3>"
    end

    def b_3_details_start attrs
        put_out "\n#{@indent}<#{@afk}:b_3_details>"
    end

    def b_3_details_end
        put_out "</#{@afk}:b_3_details>"
    end

    def b_4_start attrs
        put_out "\n#{@indent}<#{@afk}:b_4>"
    end

    def b_4_end
        put_out "</#{@afk}:b_4>"
    end

    def b_4_details_start attrs
        put_out "\n#{@indent}<#{@afk}:b_4_details>"
    end

    def b_4_details_end
        put_out "</#{@afk}:b_4_details>"
    end

    def b_5_start attrs
        put_out "\n#{@indent}<#{@afk}:b_5>"
    end

    def b_5_end
        put_out "</#{@afk}:b_5>"
    end

    def b_5_details_start attrs
        put_out "\n#{@indent}<#{@afk}:b_5_details>"
    end

    def b_5_details_end
        put_out "</#{@afk}:b_5_details>"
    end

    def totale_waarde_start attrs
        put_out "\n#{@indent}<#{@afk}:totale_waarde>"
    end

    def totale_waarde_end
        put_out "</#{@afk}:totale_waarde>"
    end

    def table
       	{"Leden"=>{3=>"lid"}, "bezit"=>{2=>"bezittingen"}}
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
	    text.gsub!(/<br([^>]*)>/,"<br\\1/>")
	    text.gsub!("//>","/>")
	    text.gsub!("<","&lt;")
	    text.gsub!(">","&gt;")
	    text.gsub!(/&lt;([^&]*)&gt;/,"<\\1>")
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

