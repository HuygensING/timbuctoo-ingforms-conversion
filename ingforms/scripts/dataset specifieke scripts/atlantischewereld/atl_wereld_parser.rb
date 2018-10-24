require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require 'cgi'
#require 'htmlentities'

include REXML


class Parser

    def Parser.parseFile(inputfilename,outputfilename,collection,afk,number)
#	STDERR.puts inputfilename
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

    def archiefmat_start attrs
        put_out "\n#{@indent}<#{@afk}:archiefmat>"
    end

    def archiefmat_end
        put_out "</#{@afk}:archiefmat>"
    end

    def wetgeving_start attrs
        put_out "\n#{@indent}<#{@afk}:wetgeving>"
    end

    def wetgeving_end
        put_out "</#{@afk}:wetgeving>"
    end

    def type_identity_start attrs
        put_out "\n#{@indent}<#{@afk}:type_identity>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def type_identity_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:type_identity>"
    end

    def type_start attrs
        put_out "\n#{@indent}<#{@afk}:type>"
    end

    def type_end
        put_out "</#{@afk}:type>"
    end

    def name_start attrs
        put_out "\n#{@indent}<schema:name>"
    end

    def name_end
        put_out "</schema:name>"
    end

    def name_english_start attrs
        put_out "\n#{@indent}<#{@afk}:name_english>"
    end

    def name_english_end
        put_out "</#{@afk}:name_english>"
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

    def period_description_start attrs
        put_out "\n#{@indent}<#{@afk}:period_description>"
    end

    def period_description_end
        put_out "</#{@afk}:period_description>"
    end

    def his_func_start attrs
        put_out "\n#{@indent}<#{@afk}:his_func rdf:parseType=\"Literal\">"
    end

    def his_func_end
        put_out "</#{@afk}:his_func>"
    end

    def related_archive_title_start attrs
        put_out "\n#{@indent}<#{@afk}:related_archive_title>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_archive_title_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_archive_title>"
    end

    def relation_start attrs
        put_out "\n#{@indent}<#{@afk}:relation>"
    end

    def relation_end
        put_out "</#{@afk}:relation>"
    end

    def related_creators_start attrs
        put_out "\n#{@indent}<#{@afk}:related_creators>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_creators_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_creators>"
    end

    def keyword_geography_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_geography>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_geography_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_geography>"
    end

    def geo_start attrs
        put_out "\n#{@indent}<#{@afk}:geo>"
    end

    def geo_end
        put_out "</#{@afk}:geo>"
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

    def subject_start attrs
        put_out "\n#{@indent}<#{@afk}:subject>"
    end

    def subject_end
        put_out "</#{@afk}:subject>"
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

    def person_start attrs
        put_out "\n#{@indent}<#{@afk}:person rdf:parseType=\"Resource\">"
    end

    def person_end
        put_out "</#{@afk}:person>"
    end

    def keyword_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword>"
    end

    def keyword_end
        put_out "</#{@afk}:keyword>"
    end

    def notes_start attrs
        put_out "\n#{@indent}<#{@afk}:notes rdf:parseType=\"Literal\">"
    end

    def notes_end
        put_out "</#{@afk}:notes>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur>"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def made_by_start attrs
        put_out "\n#{@indent}<#{@afk}:made_by>"
    end

    def made_by_end
        put_out "</#{@afk}:made_by>"
    end

    def Aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:Aantekeningen rdf:parseType=\"Literal\">"
    end

    def Aantekeningen_end
        put_out "</#{@afk}:Aantekeningen>"
    end

    def rf_country_start attrs
        put_out "\n#{@indent}<#{@afk}:rf_country>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def rf_country_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:rf_country>"
    end

    def country_start attrs
        put_out "\n#{@indent}<#{@afk}:country>"
    end

    def country_end
        put_out "</#{@afk}:country>"
    end

    def rf_archive_start attrs
        put_out "\n#{@indent}<#{@afk}:rf_archive>"
    end

    def rf_archive_end
        put_out "</#{@afk}:rf_archive>"
    end

    def ref_code_start attrs
        put_out "\n#{@indent}<#{@afk}:ref_code>"
    end

    def ref_code_end
        put_out "</#{@afk}:ref_code>"
    end

    def code_subfonds_start attrs
        put_out "\n#{@indent}<#{@afk}:code_subfonds>"
    end

    def code_subfonds_end
        put_out "</#{@afk}:code_subfonds>"
    end

    def series_start attrs
        put_out "\n#{@indent}<#{@afk}:series>"
    end

    def series_end
        put_out "</#{@afk}:series>"
    end

    def itemno_start attrs
        put_out "\n#{@indent}<#{@afk}:itemno>"
    end

    def itemno_end
        put_out "</#{@afk}:itemno>"
    end

    def titel_start attrs
        put_out "\n#{@indent}<schema:title>"
    end

    def titel_end
        put_out "</schema:title>"
    end

    def titel_eng_start attrs
        put_out "\n#{@indent}<#{@afk}:titel_eng>"
    end

    def titel_eng_end
        put_out "</#{@afk}:titel_eng>"
    end

    def extent_start attrs
        put_out "\n#{@indent}<#{@afk}:extent>"
    end

    def extent_end
        put_out "</#{@afk}:extent>"
    end

    def overhead_title_start attrs
        put_out "\n#{@indent}<#{@afk}:overhead_title>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def overhead_title_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:overhead_title>"
    end

    def finding_aid_start attrs
        put_out "\n#{@indent}<#{@afk}:finding_aid>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def finding_aid_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:finding_aid>"
    end

    def creator_start attrs
        put_out "\n#{@indent}<#{@afk}:creator>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def creator_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:creator>"
    end

    def scope_start attrs
        put_out "\n#{@indent}<#{@afk}:scope rdf:parseType=\"Literal\">"
    end

    def scope_end
        put_out "</#{@afk}:scope>"
    end

    def undelying_levels_titels_start attrs
        put_out "\n#{@indent}<#{@afk}:undelying_levels_titels>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def undelying_levels_titels_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:undelying_levels_titels>"
    end

    def related_units_start attrs
        put_out "\n#{@indent}<#{@afk}:related_units>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_units_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_units>"
    end

    def link_law_start attrs
        put_out "\n#{@indent}<#{@afk}:link_law>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def link_law_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:link_law>"
    end

    def references_start attrs
        put_out "\n#{@indent}<#{@afk}:references>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def references_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:references>"
    end

    def reference_start attrs
        put_out "\n#{@indent}<#{@afk}:reference>"
    end

    def reference_end
        put_out "</#{@afk}:reference>"
    end

    def pages_start attrs
        put_out "\n#{@indent}<#{@afk}:pages>"
    end

    def pages_end
        put_out "</#{@afk}:pages>"
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

    def date_start attrs
        put_out "\n#{@indent}<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
	@jaar = ""
	@maand = ""
	@dag = ""
    end

    def date_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:date>"
    end

    def date2_start attrs
        put_out "\n#{@indent}<#{@afk}:date2 rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        @in_datum = true
	@jaar = ""
	@maand = ""
	@dag = ""
    end

    def date2_end
        @in_datum = false
        put_out verwerk_datum
        put_out "</#{@afk}:date2>"
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

    def contents_start attrs
        put_out "\n#{@indent}<#{@afk}:contents rdf:parseType=\"Literal\">"
    end

    def contents_end
        put_out "</#{@afk}:contents>"
    end

    def see_also_link_start attrs
        put_out "\n#{@indent}<#{@afk}:see_also_link>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def see_also_link_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:see_also_link>"
    end

    def see_also_other_start attrs
        put_out "\n#{@indent}<#{@afk}:see_also_other>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def see_also_other_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:see_also_other>"
    end

    def see_start attrs
        put_out "\n#{@indent}<#{@afk}:see rdf:parseType=\"Resource\">"
    end

    def see_end
        put_out "</#{@afk}:see>"
    end

    def other_publication_start attrs
        put_out "\n#{@indent}<#{@afk}:other_publication>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def other_publication_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:other_publication>"
    end

    def publication_start attrs
        put_out "\n#{@indent}<#{@afk}:publication rdf:parseType=\"Resource\">"
    end

    def publication_end
        put_out "</#{@afk}:publication>"
    end

    def original_archival_source_start attrs
        put_out "\n#{@indent}<#{@afk}:original_archival_source rdf:parseType=\"Literal\">"
    end

    def original_archival_source_end
        put_out "</#{@afk}:original_archival_source>"
    end

    def link_archival_dbase_start attrs
        put_out "\n#{@indent}<#{@afk}:link_archival_dbase>"
    end

    def link_archival_dbase_end
        put_out "</#{@afk}:link_archival_dbase>"
    end

    def remarks_start attrs
        put_out "\n#{@indent}<#{@afk}:remarks rdf:parseType=\"Literal\">"
    end

    def remarks_end
        put_out "</#{@afk}:remarks>"
    end

    def scan_start attrs
        put_out "\n#{@indent}<#{@afk}:scan>"
    end

    def scan_end
        put_out "</#{@afk}:scan>"
    end

    def partstoscan_start attrs
        put_out "\n#{@indent}<#{@afk}:partstoscan>"
    end

    def partstoscan_end
        put_out "</#{@afk}:partstoscan>"
    end

    def table
       	{"reference"=>{2=>"references"},
	 "doctype"=>{2=>"doctypes"}}
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
	    if md=text.match(/(&#\d+)([^;0-9])/)
		text = "#{md.pre_match}#{md[1]};#{md[2]}#{md.post_match}"
	    end
	    text.gsub!(/&nbsp;/,"&#160;")
	    text.gsub!(/(\s)&(\s)/,"\\1&amp;\\2")
	    text.gsub!(/([a-zA-Z])&([a-zA-Z])/,"\\1&amp;\\2")
	    text.gsub!(/&amp;amp;/,"&amp;")
	    text.gsub!(/&ldquo;/,"&amp;ldquo;")
	    text.gsub!(/&\$/,"&#")
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

