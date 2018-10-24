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
	@in_doc_nr = false
	@doc_nr = ""
    end

    def plakkaat_start attrs
        put_out "\n#{@indent}<#{@afk}:plakkaat>"
    end

    def plakkaat_end
        put_out "</#{@afk}:plakkaat>"
    end

    def documentnr_start attrs
        put_out "\n#{@indent}<#{@afk}:documentnr>"
	@in_doc_nr = true
	@doc_nr = ""
    end

    def documentnr_end
        put_out "</#{@afk}:documentnr>"
	put_out "\n#{@indent}<schema:title>#{@doc_nr}</schema:title>"
	@in_doc_nr = false
    end

    def kolonie_start attrs
        put_out "\n#{@indent}<#{@afk}:kolonie>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def kolonie_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:kolonie>"
    end

    def kolonie__start attrs
        put_out "\n#{@indent}<#{@afk}:kolonie_>"
    end

    def kolonie__end
        put_out "</#{@afk}:kolonie_>"
    end

    def archiefinstelling_start attrs
        put_out "\n#{@indent}<#{@afk}:archiefinstelling>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def archiefinstelling_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:archiefinstelling>"
    end

    def instelling__start attrs
        put_out "\n#{@indent}<#{@afk}:instelling_>"
    end

    def instelling__end
        put_out "</#{@afk}:instelling_>"
    end

    def archief_start attrs
        put_out "\n#{@indent}<#{@afk}:archief>"
    end

    def archief_end
        put_out "</#{@afk}:archief>"
    end

    def alt_vindplaatsen_start attrs
        put_out "\n#{@indent}<#{@afk}:alt_vindplaatsen rdf:parseType=\"Literal\">"
    end

    def alt_vindplaatsen_end
        put_out "</#{@afk}:alt_vindplaatsen>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<#{@afk}:titel>"
    end

    def titel_end
        put_out "</#{@afk}:titel>"
    end

    def titel_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:titel_eng>"
    end

    def titel_eng_end
        put_out "</#{@afk}:titel_eng>"
    end

    def doctypes_start attrs
        put_out "\n#{@indent}<#{@afk}:doctypes>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def doctypes_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:doctypes>"
    end

    def doctype_start attrs
        put_out "\n#{@indent}<#{@afk}:doctype>"
    end

    def doctype_end
        put_out "</#{@afk}:doctype>"
    end

    def uitgevende_instantie_start attrs
        put_out "\n#{@indent}<#{@afk}:uitgevende_instantie>"
    end

    def uitgevende_instantie_end
        put_out "</#{@afk}:uitgevende_instantie>"
    end

    def plaats_opmaak_start attrs
        put_out "\n#{@indent}<#{@afk}:plaats_opmaak>"
    end

    def plaats_opmaak_end
        put_out "</#{@afk}:plaats_opmaak>"
    end

    def date1_start attrs
        put_out "\n#{@indent}<#{@afk}:date1 rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
    end

    def date1_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:date1>"
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

    def date2_start attrs
        put_out "\n#{@indent}<#{@afk}:date2 rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
    end

    def date2_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:date2>"
    end

    def date3_start attrs
        put_out "\n#{@indent}<#{@afk}:date3 rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
    end

    def date3_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:date3>"
    end

    def link_eerdere_plakaten_start attrs
        put_out "\n#{@indent}<#{@afk}:link_eerdere_plakaten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def link_eerdere_plakaten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:link_eerdere_plakaten>"
    end

    def relation_start attrs
        put_out "\n#{@indent}<#{@afk}:relation>"
    end

    def relation_end
        put_out "</#{@afk}:relation>"
    end

    def link_latere_plakaten_start attrs
        put_out "\n#{@indent}<#{@afk}:link_latere_plakaten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def link_latere_plakaten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:link_latere_plakaten>"
    end

    def link_andereplakkaten_start attrs
        put_out "\n#{@indent}<#{@afk}:link_andereplakkaten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def link_andereplakkaten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:link_andereplakkaten>"
    end

    def plakaten_other_start attrs
        put_out "\n#{@indent}<#{@afk}:plakaten_other>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def plakaten_other_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:plakaten_other>"
    end

    def see_start attrs
        put_out "\n#{@indent}<#{@afk}:see rdf:parseType=\"Resource\">"
    end

    def see_end
        put_out "</#{@afk}:see>"
    end

    def contents_start attrs
        put_out "\n#{@indent}<#{@afk}:contents rdf:parseType=\"Literal\">"
    end

    def contents_end
        put_out "</#{@afk}:contents>"
    end

    def keyword_geography_broad_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_geography_broad>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_geography_broad_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_geography_broad>"
    end

    def geobroad_start attrs
        put_out "\n#{@indent}<#{@afk}:geobroad>"
    end

    def geobroad_end
        put_out "</#{@afk}:geobroad>"
    end

    def keyword_geography_narrow_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_geography_narrow>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_geography_narrow_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_geography_narrow>"
    end

    def geonarrow_start attrs
        put_out "\n#{@indent}<#{@afk}:geonarrow>"
    end

    def geonarrow_end
        put_out "</#{@afk}:geonarrow>"
    end

    def keyword_subject_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_subject>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_subject_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_subject>"
    end

    def onderwerp_start attrs
        put_out "\n#{@indent}<#{@afk}:onderwerp>"
    end

    def onderwerp_end
        put_out "</#{@afk}:onderwerp>"
    end

    def keyword_subject_extra_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_subject_extra>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_subject_extra_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_subject_extra>"
    end

    def subject_other_start attrs
        put_out "\n#{@indent}<#{@afk}:subject_other>"
    end

    def subject_other_end
        put_out "</#{@afk}:subject_other>"
    end

    def keyword_person_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_person>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_person_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_person>"
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon rdf:parseType=\"Resource\">"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def keyword_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword>"
    end

    def keyword_end
        put_out "</#{@afk}:keyword>"
    end

    def transcriptie_start attrs
        put_out "\n#{@indent}<#{@afk}:transcriptie rdf:parseType=\"Literal\">"
    end

    def transcriptie_end
        put_out "</#{@afk}:transcriptie>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen>"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def table
       	{"doctype"=>{2=>"doctypes"}}
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
	    if @in_doc_nr
		@doc_nr = text.strip
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

