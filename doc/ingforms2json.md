# Documentation INGForms to json-ld

## Introduction
The INGForms to json-ld script converts a directory of INGForms xml-files to a json-ld representation, that can (for example) be imported into a Huygens ING Timbuctoo instance.

It will not convert a binary export from an INGForms instance (that has a .fri extension). The xml files together with the schemas contain all the information necessary.

## INGForms and svn
INGForms consist of xml-files containing INGForms schemas, INGForms lists and INGForms files. They may be retrieved from the Huygens ING svn repository at http://dev.inghist.nl/svn, using a username and password provided separately, but it is also possible to use a zip-file and extract this to a directory. SVN interaction is not part of this script.

## Use of the script
The script is called from the command-line, using the incantation

<pre>
python ingforms_to_json_generic.py -so

options:
- -s: output to single file (filename provided in option file, see below)
- -o: provide name of options file (required)

all other options are provided in the options file, see below for details.

Example invocation (should be on a single line):
python ingforms_to_json_generic.py -s -o /<location_on_disk>/ingforms_options.ini

please note that on paths with a white space, the path should be between quotes
</pre>


## Specification of locations in the options-file
The script uses a number of locations of the INGForms files and schemas, that should be specified in an options file. It uses the [.ini style](https://nl.wikipedia.org/wiki/INI) convention of sections indicated with [square brackets] and key = value pairs. An example of a section is:

<pre>
[output]
outdir = out
outfile = out.json
</pre>

Most of the sections provide locations for input and output. We have tried to provide sensible locations for both input and output directories, but some are specific to your system and preferences. They should be changed here. All settings may be changed, but sensible defaults (apart from the basic directory) have been provided.

<pre>
[location]
basedir = location
indir = ingforms
defdir = lists/formdef

[output]
outdir = out
outfile = out.json

[collection]
collection = emigratie

[urls]
base = http://resources.huygens.knaw.nl/ingforms/
collectionurl = collection name

[exclude_dirs]
0 = inleiding
1 = [Bb]ijlagen

</pre>

### Explanation of the sections

- location: provides locations of the original ingforms xml files
- output: the place where the output goes to
- collection: name of the collection. This will also be used in the resulting json files url locations
- urls: urls used for uris of the elements
- exclude_dirs: directories with file that should not be included. Enumerate them as in the example. Regular expressions may be used.
