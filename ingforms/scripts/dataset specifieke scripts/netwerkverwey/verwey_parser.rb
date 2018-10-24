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
	@in_koppelnaam = false
	@koppelnaam = ""
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon>"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def persoon_start attrs
        put_out "\n#{@indent}<#{@afk}:persoon>"
    end

    def persoon_end
        put_out "</#{@afk}:persoon>"
    end

    def persname_start attrs
        put_out "\n#{@indent}<#{@afk}:persname rdf:parseType=\"Resource\">"
    end

    def persname_end
        put_out "</#{@afk}:persname>"
    end

    def name_start attrs
        put_out "\n#{@indent}<#{@afk}:name>"
    end

    def name_end
        put_out "</#{@afk}:name>"
    end

    def preposition_start attrs
        put_out "\n#{@indent}<#{@afk}:preposition>"
    end

    def preposition_end
        put_out "</#{@afk}:preposition>"
    end

    def firstname_start attrs
        put_out "\n#{@indent}<#{@afk}:firstname>"
    end

    def firstname_end
        put_out "</#{@afk}:firstname>"
    end

    def intraposition_start attrs
        put_out "\n#{@indent}<#{@afk}:intraposition>"
    end

    def intraposition_end
        put_out "</#{@afk}:intraposition>"
    end

    def familyname_start attrs
        put_out "\n#{@indent}<#{@afk}:familyname>"
    end

    def familyname_end
        put_out "</#{@afk}:familyname>"
    end

    def postposition_start attrs
        put_out "\n#{@indent}<#{@afk}:postposition>"
    end

    def postposition_end
        put_out "</#{@afk}:postposition>"
    end

    def koppelnaam_start attrs
        put_out "\n#{@indent}<#{@afk}:koppelnaam>"
	@in_koppelnaam = true
	@koppelnaam = ""
    end

    def koppelnaam_end
        put_out "</#{@afk}:koppelnaam>"
	@in_koppelnaam = false
	put_out "\n#{@indent}<schema:name>#{@koppelnaam}</schema:name>"
    end

    def altname_start attrs
        put_out "\n#{@indent}<#{@afk}:altname>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def altname_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:altname>"
    end

    def names_start attrs
        put_out "\n#{@indent}<#{@afk}:names rdf:parseType=\"Resource\">"
    end

    def names_end
        put_out "</#{@afk}:names>"
    end

    def nametype_start attrs
        put_out "\n#{@indent}<#{@afk}:nametype>"
    end

    def nametype_end
        put_out "</#{@afk}:nametype>"
    end

    def sex_start attrs
        put_out "\n#{@indent}<#{@afk}:sex>"
    end

    def sex_end
        put_out "</#{@afk}:sex>"
    end

    def birth_start attrs
        put_out "\n#{@indent}<#{@afk}:birth rdf:parseType=\"Resource\">"
    end

    def birth_end
        put_out "</#{@afk}:birth>"
    end

    def date_start attrs
        @in_datum = true
    end

    def date_end
        @in_datum = false
        put_out "\n#{@indent}<#{@afk}:date rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">"
        put_out verwerk_datum
        put_out "</#{@afk}:date>"
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

    def values_start attrs
        put_out "\n#{@indent}<#{@afk}:values rdf:parseType=\"Resource\">"
    end

    def values_end
        put_out "\n#{@indent}</#{@afk}:values>"
    end

    def val_start attrs
        put_out "\n#{@indent}<#{@afk}:val>"
    end

    def val_end
        put_out "</#{@afk}:val>"
    end

    def place_start attrs
        put_out "\n#{@indent}<#{@afk}:place>"
    end

    def place_end
        put_out "</#{@afk}:place>"
    end

    def country_start attrs
        put_out "\n#{@indent}<#{@afk}:country>"
    end

    def country_end
        put_out "</#{@afk}:country>"
    end

    def death_start attrs
        put_out "\n#{@indent}<#{@afk}:death rdf:parseType=\"Resource\">"
    end

    def death_end
        put_out "</#{@afk}:death>"
    end

    def woonplaats_start attrs
        put_out "\n#{@indent}<#{@afk}:woonplaats>"
    end

    def woonplaats_end
        put_out "</#{@afk}:woonplaats>"
    end

    def education_start attrs
        put_out "\n#{@indent}<#{@afk}:education>"
    end

    def education_end
        put_out "</#{@afk}:education>"
    end

    def occupation_start attrs
        put_out "\n#{@indent}<#{@afk}:occupation>"
    end

    def occupation_end
        put_out "</#{@afk}:occupation>"
    end

    def network_start attrs
        put_out "\n#{@indent}<#{@afk}:network>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def network_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:network>"
    end

    def domain_start attrs
        put_out "\n#{@indent}<#{@afk}:domain>"
    end

    def domain_end
        put_out "</#{@afk}:domain>"
    end

    def relatives_start attrs
        put_out "\n#{@indent}<#{@afk}:relatives>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def relatives_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:relatives>"
    end

    def relatie_start attrs
        put_out "\n#{@indent}<#{@afk}:relatie rdf:parseType=\"Resource\">"
    end

    def relatie_end
        put_out "</#{@afk}:relatie>"
    end

    def reltype_start attrs
        put_out "\n#{@indent}<#{@afk}:reltype>"
    end

    def reltype_end
        put_out "</#{@afk}:reltype>"
    end

    def koppelname_start attrs
        put_out "\n#{@indent}<#{@afk}:koppelname>"
    end

    def koppelname_end
        put_out "</#{@afk}:koppelname>"
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
        put_out "\n#{@indent}<#{@afk}:periodiek>"
    end

    def periodiek_end
        put_out "</#{@afk}:periodiek>"
    end

    def periodieken_other_start attrs
        put_out "\n#{@indent}<#{@afk}:periodieken_other>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def periodieken_other_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:periodieken_other>"
    end

    def overig_start attrs
        put_out "\n#{@indent}<#{@afk}:overig rdf:parseType=\"Resource\">"
    end

    def overig_end
        put_out "</#{@afk}:overig>"
    end

    def other_start attrs
        put_out "\n#{@indent}<#{@afk}:other>"
    end

    def other_end
        put_out "</#{@afk}:other>"
    end

    def memberships_start attrs
        put_out "\n#{@indent}<#{@afk}:memberships>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def memberships_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:memberships>"
    end

    def lidmaatschap_start attrs
        put_out "\n#{@indent}<#{@afk}:lidmaatschap>"
    end

    def lidmaatschap_end
        put_out "</#{@afk}:lidmaatschap>"
    end

    def memberships_other_start attrs
        put_out "\n#{@indent}<#{@afk}:memberships_other>"
    end

    def memberships_other_end
        put_out "</#{@afk}:memberships_other>"
    end

    def domains_start attrs
        put_out "\n#{@indent}<#{@afk}:domains>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def domains_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:domains>"
    end

    def domein_start attrs
        put_out "\n#{@indent}<#{@afk}:domein>"
    end

    def domein_end
        put_out "</#{@afk}:domein>"
    end

    def domains_other_start attrs
        put_out "\n#{@indent}<#{@afk}:domains_other>"
    end

    def domains_other_end
        put_out "</#{@afk}:domains_other>"
    end

    def subdomains_start attrs
        put_out "\n#{@indent}<#{@afk}:subdomains>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def subdomains_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:subdomains>"
    end

    def subdomain_start attrs
        put_out "\n#{@indent}<#{@afk}:subdomain>"
    end

    def subdomain_end
        put_out "</#{@afk}:subdomain>"
    end

    def subdomains_other_start attrs
        put_out "\n#{@indent}<#{@afk}:subdomains_other>"
    end

    def subdomains_other_end
        put_out "</#{@afk}:subdomains_other>"
    end

    def characteristic_start attrs
        put_out "\n#{@indent}<#{@afk}:characteristic>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def characteristic_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:characteristic>"
    end

    def karakteristic_start attrs
        put_out "\n#{@indent}<#{@afk}:karakteristic>"
    end

    def karakteristic_end
        put_out "</#{@afk}:karakteristic>"
    end

    def characteristic_other_start attrs
        put_out "\n#{@indent}<#{@afk}:characteristic_other>"
    end

    def characteristic_other_end
        put_out "</#{@afk}:characteristic_other>"
    end

    def characteristic_old_start attrs
        put_out "\n#{@indent}<#{@afk}:characteristic_old rdf:parseType=\"Literal\">"
    end

    def characteristic_old_end
        put_out "</#{@afk}:characteristic_old>"
    end

    def domains_old_start attrs
        put_out "\n#{@indent}<#{@afk}:domains_old>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def domains_old_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:domains_old>"
    end

    def politics_start attrs
        put_out "\n#{@indent}<#{@afk}:politics>"
    end

    def politics_end
        put_out "</#{@afk}:politics>"
    end

    def opm_politics_start attrs
        put_out "\n#{@indent}<#{@afk}:opm_politics>"
    end

    def opm_politics_end
        put_out "</#{@afk}:opm_politics>"
    end

    def levensbeschouwing_start attrs
        put_out "\n#{@indent}<#{@afk}:levensbeschouwing>"
    end

    def levensbeschouwing_end
        put_out "</#{@afk}:levensbeschouwing>"
    end

    def literatuur_start attrs
        put_out "\n#{@indent}<#{@afk}:literatuur>"
    end

    def literatuur_end
        put_out "</#{@afk}:literatuur>"
    end

    def biodesurl_start attrs
        put_out "\n#{@indent}<#{@afk}:biodesurl>"
    end

    def biodesurl_end
        put_out "</#{@afk}:biodesurl>"
    end

    def dbnl_url_start attrs
        put_out "\n#{@indent}<#{@afk}:dbnl_url>"
    end

    def dbnl_url_end
        put_out "</#{@afk}:dbnl_url>"
    end

    def verwijzingen_start attrs
        put_out "\n#{@indent}<#{@afk}:verwijzingen>"
  	put_out "\n#{@indent}<rdf:Seq>"
    end

    def verwijzingen_end
  	@output.puts "\n#{@indent}</rdf:Seq>"
        indent = "  " * (@level - 1)
  	put_out "#{indent}"
        put_out "</#{@afk}:verwijzingen>"
    end

    def link_start attrs
        put_out "\n#{@indent}<#{@afk}:link rdf:parseType=\"Resource\">"
    end

    def link_end
        put_out "</#{@afk}:link>"
    end

    def url_start attrs
        put_out "\n#{@indent}<#{@afk}:url>"
    end

    def url_end
        put_out "</#{@afk}:url>"
    end

    def identifier_start attrs
        put_out "\n#{@indent}<#{@afk}:identifier>"
    end

    def identifier_end
        put_out "</#{@afk}:identifier>"
    end

    def soort_start attrs
        put_out "\n#{@indent}<#{@afk}:soort>"
    end

    def soort_end
        put_out "</#{@afk}:soort>"
    end

    def opmerkingen_start attrs
        put_out "\n#{@indent}<#{@afk}:opmerkingen rdf:parseType=\"Literal\">"
    end

    def opmerkingen_end
        put_out "</#{@afk}:opmerkingen>"
    end

    def notities_start attrs
        put_out "\n#{@indent}<#{@afk}:notities rdf:parseType=\"Literal\">"
    end

    def notities_end
        put_out "</#{@afk}:notities>"
    end

    def aantekeningen_start attrs
        put_out "\n#{@indent}<#{@afk}:aantekeningen rdf:parseType=\"Literal\">"
    end

    def aantekeningen_end
        put_out "</#{@afk}:aantekeningen>"
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
	    @koppelnaam = text.strip if @in_koppelnaam
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

