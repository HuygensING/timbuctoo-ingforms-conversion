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
	@only_jaar = false
    end

    def verbalen_start attrs
        put_out "\n#{@indent}<#{@afk}:verbalen>"
    end

    def verbalen_end
        put_out "</#{@afk}:verbalen>"
    end

    def verbaal_start attrs
        put_out "\n#{@indent}<#{@afk}:verbaal rdf:parseType=\"Resource\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def verbaal_end
        @in_datum = false
	put_out "<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
	put_out "</#{@afk}:date>"
        put_out "#{@indent}</#{@afk}:verbaal>"
    end

    def year_start attrs
	@in_jaar = true
    end

    def year_end
	if @only_jaar
	    put_out "\n#{@indent}<#{@afk}:year>#{@jaar}</#{@afk}:year>"
	    @only_jaar = false
	end
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

    def comment_start attrs
        put_out "\n#{@indent}<#{@afk}:comment>"
    end

    def comment_end
        put_out "</#{@afk}:comment>"
    end

    def archival_section_number_start attrs
        put_out "\n#{@indent}<#{@afk}:archival_section_number>"
    end

    def archival_section_number_end
        put_out "</#{@afk}:archival_section_number>"
    end

    def index_invnr_start attrs
        put_out "\n#{@indent}<#{@afk}:index_invnr>"
    end

    def index_invnr_end
        put_out "</#{@afk}:index_invnr>"
    end

    def secret_start attrs
        put_out "\n#{@indent}<#{@afk}:secret>"
    end

    def secret_end
        put_out "</#{@afk}:secret>"
    end

    def number_in_index_start attrs
        put_out "\n#{@indent}<#{@afk}:number_in_index>"
    end

    def number_in_index_end
        put_out "</#{@afk}:number_in_index>"
    end

    def author_start attrs
        put_out "\n#{@indent}<#{@afk}:author>"
    end

    def author_end
        put_out "</#{@afk}:author>"
    end

    def date_document_start attrs
        put_out "\n#{@indent}<#{@afk}:date_document rdf:parseType=\"Resource\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def date_document_end
        @in_datum = false
	put_out "<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
	put_out "</#{@afk}:date>"
        put_out "</#{@afk}:date_document>"
    end

    def addressee_start attrs
        put_out "\n#{@indent}<#{@afk}:addressee>"
    end

    def addressee_end
        put_out "</#{@afk}:addressee>"
    end

    def short_description_start attrs
        put_out "\n#{@indent}<#{@afk}:short_description rdf:parseType=\"Literal\">"
    end

    def short_description_end
        put_out "</#{@afk}:short_description>"
    end

    def verbaal_invnr_start attrs
        put_out "\n#{@indent}<#{@afk}:verbaal_invnr>"
    end

    def verbaal_invnr_end
        put_out "</#{@afk}:verbaal_invnr>"
    end

    def verbaal_found_start attrs
        put_out "\n#{@indent}<#{@afk}:verbaal_found>"
    end

    def verbaal_found_end
        put_out "</#{@afk}:verbaal_found>"
    end

    def remarks_start attrs
        put_out "\n#{@indent}<#{@afk}:remarks rdf:parseType=\"Literal\">"
    end

    def remarks_end
        put_out "</#{@afk}:remarks>"
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

    def geography_start attrs
        put_out "\n#{@indent}<#{@afk}:geography rdf:parseType=\"Resource\">"
    end

    def geography_end
        put_out "</#{@afk}:geography>"
    end

    def keyword_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword>"
    end

    def keyword_end
        put_out "</#{@afk}:keyword>"
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

    def keyword_islam_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_islam>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_islam_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_islam>"
    end

    def keyword_hbco_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_hbco>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_hbco_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_hbco>"
    end

    def keyword_pc_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_pc>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_pc_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_pc>"
    end

    def keyword_cc_start attrs
        put_out "\n#{@indent}<#{@afk}:keyword_cc>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def keyword_cc_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:keyword_cc>"
    end

    def related_records_verbaal_start attrs
        put_out "\n#{@indent}<#{@afk}:related_records_verbaal>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_records_verbaal_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_records_verbaal>"
    end

    def relation_start attrs
        put_out "\n#{@indent}<#{@afk}:relation>"
    end

    def relation_end
        put_out "</#{@afk}:relation>"
    end

    def related_records_besluiten_start attrs
        put_out "\n#{@indent}<#{@afk}:related_records_besluiten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_records_besluiten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_records_besluiten>"
    end

    def related_records_mailrapporten_start attrs
        put_out "\n#{@indent}<#{@afk}:related_records_mailrapporten>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_records_mailrapporten_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_records_mailrapporten>"
    end

    def related_records_staatsblad_start attrs
        put_out "\n#{@indent}<#{@afk}:related_records_staatsblad>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def related_records_staatsblad_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:related_records_staatsblad>"
    end

    def reference_kviv_start attrs
        put_out "\n#{@indent}<#{@afk}:reference_kviv>"
    end

    def reference_kviv_end
        put_out "</#{@afk}:reference_kviv>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
    end

    def advieskiz_start attrs
        put_out "\n#{@indent}<#{@afk}:advieskiz>"
    end

    def advieskiz_end
        put_out "</#{@afk}:advieskiz>"
    end

    def recipient_start attrs
        put_out "\n#{@indent}<#{@afk}:recipient>"
    end

    def recipient_end
        put_out "</#{@afk}:recipient>"
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
        put_out "\n#{@indent}<#{@afk}:subject rdf:parseType=\"Resource\">"
    end

    def subject_end
        put_out "</#{@afk}:subject>"
    end

    def published_in_start attrs
        put_out "\n#{@indent}<#{@afk}:published_in>"
    end

    def published_in_end
        put_out "</#{@afk}:published_in>"
    end

    def archival_references_start attrs
        put_out "\n#{@indent}<#{@afk}:archival_references>"
    end

    def archival_references_end
        put_out "</#{@afk}:archival_references>"
    end

    def see_also_start attrs
        put_out "\n#{@indent}<#{@afk}:see_also>"
    end

    def see_also_end
        put_out "</#{@afk}:see_also>"
    end

    def scan_start attrs
        put_out "\n#{@indent}<#{@afk}:scan>"
    end

    def scan_end
        put_out "</#{@afk}:scan>"
    end

    def link_scan_start attrs
        put_out "\n#{@indent}<#{@afk}:link_scan rdf:parseType=\"Literal\">"
    end

    def link_scan_end
        put_out "</#{@afk}:link_scan>"
    end

    def besluiten_start attrs
        put_out "\n#{@indent}<#{@afk}:besluiten>"
    end

    def besluiten_end
        put_out "</#{@afk}:besluiten>"
    end

    def besluit_start attrs
        put_out "\n#{@indent}<#{@afk}:besluit rdf:parseType=\"Resource\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def besluit_end
        @in_datum = false
	puts "<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
	put_out "</#{@afk}:date>"
        put_out "\n#{@indent}</#{@afk}:besluit>"
    end

    def decisionmaker_start attrs
        put_out "\n#{@indent}<#{@afk}:decisionmaker>"
    end

    def decisionmaker_end
        put_out "</#{@afk}:decisionmaker>"
    end

    def summary_start attrs
        put_out "\n#{@indent}<#{@afk}:summary rdf:parseType=\"Literal\">"
    end

    def summary_end
        put_out "</#{@afk}:summary>"
    end

    def besluit_invnr_start attrs
        put_out "\n#{@indent}<#{@afk}:besluit_invnr>"
    end

    def besluit_invnr_end
        put_out "</#{@afk}:besluit_invnr>"
    end

    def dossier_start attrs
        put_out "\n#{@indent}<#{@afk}:dossier>"
    end

    def dossier_end
        put_out "</#{@afk}:dossier>"
    end

    def dossier_start attrs
        put_out "\n#{@indent}<#{@afk}:dossier>"
    end

    def dossier_end
        put_out "</#{@afk}:dossier>"
    end

    def section_number_start attrs
        put_out "\n#{@indent}<#{@afk}:section_number>"
    end

    def section_number_end
        put_out "</#{@afk}:section_number>"
    end

    def titledossier_start attrs
        put_out "\n#{@indent}<#{@afk}:titledossier>"
    end

    def titledossier_end
        put_out "</#{@afk}:titledossier>"
    end

    def mailrapporten_start attrs
        put_out "\n#{@indent}<#{@afk}:mailrapporten>"
    end

    def mailrapporten_end
        put_out "</#{@afk}:mailrapporten>"
    end

    def mailrapport_start attrs
        put_out "\n#{@indent}<#{@afk}:mailrapport rdf:parseType=\"Resource\">"
	@only_jaar = true
    end

    def mailrapport_end
        put_out "</#{@afk}:mailrapport>"
	@only_jaar = false
    end

    def date_besluit_start attrs
        put_out "\n#{@indent}<#{@afk}:date_besluit rdf:parseType=\"Resource\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def date_besluit_end
        @in_datum = false
	put_out "<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
	put_out "</#{@afk}:date>"
        put_out "</#{@afk}:date_besluit>"
    end

    def mailrapport_invnr_start attrs
        put_out "\n#{@indent}<#{@afk}:mailrapport_invnr>"
    end

    def mailrapport_invnr_end
        put_out "</#{@afk}:mailrapport_invnr>"
    end

    def wetgeving_start attrs
        put_out "\n#{@indent}<#{@afk}:wetgeving>"
    end

    def wetgeving_end
        put_out "</#{@afk}:wetgeving>"
    end

    def staatsblad_start attrs
        put_out "\n#{@indent}<#{@afk}:staatsblad rdf:parseType=\"Resource\">"
	@only_jaar = true
    end

    def staatsblad_end
        put_out "</#{@afk}:staatsblad>"
	@only_jaar = false
    end

    def bijblad_start attrs
        put_out "\n#{@indent}<#{@afk}:bijblad>"
    end

    def bijblad_end
        put_out "</#{@afk}:bijblad>"
    end

    def other_law_start attrs
        put_out "\n#{@indent}<#{@afk}:other_law>"
    end

    def other_law_end
        put_out "</#{@afk}:other_law>"
    end

    def date_regulation_start attrs
        put_out "\n#{@indent}<#{@afk}:date_regulation rdf:parseType=\"Resource\">"
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
    end

    def date_regulation_end
        @in_datum = false
	put_out "<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
	put_out "</#{@afk}:date>"
        put_out "</#{@afk}:date_regulation>"
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

