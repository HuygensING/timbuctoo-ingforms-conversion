require 'open-uri'
require 'rubygems'
require 'cgi'
#require 'htmlentities'


def make_start_end item,output,property=""
    prop = ""
    seq = ""
    if property.eql?("literal")
	prop = ' rdf:parseType=\"Literal\"'
    elsif property.eql?("B")
	seq = "rdf:Bag"
    elsif property.eql?("R")
	prop = ' rdf:parseType=\"Resource\"'
    elsif property.eql?("S")
	seq = "rdf:Seq"
    elsif property.eql?("D")
	prop = " rdf:datatype=\\\"http://www.w3.org/2001/XMLSchema#date\\\""
    end
    start =<<EOF
    def #{item}_start attrs
        put_out "\\n#\{@indent}<#\{@afk}:#{item}#{prop}>"
EOF
    if !seq.empty?
        start +=<<EOF
  	put_out "\\n#\{@indent}<#{seq}>"
EOF
    end
    if property.eql?("D")
        start +=<<EOF
        @in_datum = true
        @dag = ""
        @maand = ""
        @jaar = ""
EOF
    end
    start +=<<EOF
    end

EOF
    output.puts start

    stop =<<EOF
    def #{item}_end
EOF
    if property.eql?("D")
        stop += "        @in_datum = false\n"
  	stop += "        put_out verwerk_datum\n"
    end
    if !seq.empty?
	stop +=<<EOF
  	@output.puts "\\n#\{@indent}</#{seq}>"
        indent = "  " * (@level - 1)
  	put_out "#\{indent}"
EOF
    end
    stop +=<<EOF
        put_out "</#\{@afk}:#{item}>"
    end

EOF
    output.puts stop
end

def help_message
    STDERR.puts "use: ruby build_parser -i input -o output"
    exit(0)
end

if __FILE__ == $0

    inputfilename = ""
    outputfilename = ""

    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    when '-i' then begin inputfilename = ARGV[i+1] end
	    when '-o' then begin outputfilename = ARGV[i+1] end
	   # when '-r' then begin resource = ARGV[i+1] end
	    when '-h' then begin help_message end
	end
    end

    if inputfilename.empty? || outputfilename.empty?
	help_message
    end

    output = File.new(outputfilename,"w")
    #read header
    File.open("parser_header.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    output.puts line
	end
    end
    #
    #close initialize
    output.puts "    end"
    output.puts

    tags = Array.new
    table = Hash.new
    File.open(inputfilename) do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    #line.strip!
	    if !line.empty?
		# STDERR.puts line.strip
		md = line.match(/<([^>]*)>/)
		if !md.nil?
		    tag = md[1]
		    if md[1].split("|").size>1
			old,new = md[1].split("|")
			tag = new
			level = (md.pre_match.size / 2 ) + 1
			if table.has_key?(old) 
			    table[old][level] = new
			else
			    table[old] = {}
			    table[old][level] = new
			end
#			STDERR.puts "md.pre_match.size: #{md.pre_match.size}"
#			STDERR.puts "old: #{old} - new: #{new} - level: #{level}"
		    end
		    if tags.include? tag
		        STDERR.puts "multiple #{tag}"
		        STDERR.puts "eventueel aanpassen!!!"
		    end
		    md_2 = line.match(/\(([^()]*)\)$/)
		    property = ""
		    property = md_2[1] if !md_2.nil?
		        make_start_end tag,output,property
		    tags << tag
		end
	    end
	end
    end

    table_def =<<EOF
    def table
       	#{table}
    end
EOF
    output.puts table_def
    table_def =<<EOF
    def table
       	{
	    "thema" => {2 => "themas"},
	    "trefwoord" => {2 => "trefwoorden",
    		4 => "woord" },
	    "persoon" => {2 => "personen" },
	    "instelling" => {2 => "instellingen"},
	}
    end
EOF

    # read footer
    File.open("parser_footer.txt") do |file|
	while line = file.gets
	    line.force_encoding(Encoding::UTF_8)
	    output.puts line
	end
    end

end

