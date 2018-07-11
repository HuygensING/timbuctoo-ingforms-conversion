# -*- coding: utf-8 -*-
"""
Created on Wed Feb  1 16:22:13 2017

@author: rikhoekstra

config urls are now still hardcoded, but could work with either a local copy
or a svn checkout of an ingforms repository
"""

#import xmljson
import re
import xmltodict
from collections import OrderedDict
#from pyld import jsonld
import os, fnmatch
#from urllib.parse import urlencode
from json import dump
import argparse
from configparser import ConfigParser
import posixpath

#basic declarations
#indir = '/Users/rikhoekstra/develop/emigratie/ingforms'
#defdir =  os.path.join(indir, 'lists', 'formdef')
#baseurl = "http://resources.huygens.knaw.nl/ingforms/"
#migratieurl = "http://resources.huygens.knaw.nl/ingforms/emigratiegids/"
#collectie='migratiegids'
#exclude = ['inleiding', '[Bb]ijlagen']


def recursive_glob(treeroot, pattern):
    results = []
    for base, dirs, files in os.walk(treeroot):
        goodfiles = fnmatch.filter(files, pattern)
        results.extend(posixpath.join(base, f) for f in goodfiles)
    return results

class SchemaConverter(object):
    def __init__(self, indir=".",
                       defdir="formdef",
                       baseurl='.'):
        """make this a registry for later use and
        inclusion into json-ld files"""
        self.registry = {}
        self.baseurl = baseurl
        self.basedir = os.path.split(indir)[0]
        self.defdir = posixpath.join(self.basedir, 'defdir')
        self.listdir = posixpath.join(self.defdir, 'lists')

    def schema2context(self, infile):
        """parse ingforms schema file
        and make a json-ld context out of it
        As of now the base schema url is the Huygens url"""

        #base declarations and parsing        
        baseurl =  self.baseurl
        fl = open(infile)
        doc = fl.read()
        jd = xmltodict.parse(doc)
        formdef = jd['formdef']
        fields = formdef['form']

        #make a context
        context = {}

        #and the schema url
        flds = fields['field']
        
        #context definitions are the fields of the ingforms schema
        for field in flds:
#            fldname = formdef['formkey']
            if isinstance(field, OrderedDict):
                w_field = field
            else:
                w_field = flds
            fldname = w_field['key']
            context[fldname] = posixpath.join(baseurl,formdef['formkey'],w_field['key'])

            #add begin and end for period fields
            if fldname.find('period') > -1 and not 'begin' in context:
                context['begin'] = posixpath.join(baseurl,formdef['formkey'],w_field['key'],'begin')
                context['end'] = posixpath.join(baseurl,formdef['formkey'],w_field['key'],'end')
                context['date']= posixpath.join(baseurl,formdef['formkey'],w_field['key'],"date") #"http://www.w3.org/2001/XMLSchema#dateTime"

            
            #recurse for embedded fields
            if w_field['type'] == 'form':
                subschemanm = w_field['contents_key']
                subschema = self.getschema(subschemanm)
                for key in subschema:
                    context[key] = subschema[key]

        return context
        
    def convert_schema(self, indir='', schemaname=''):
        """convert schema to json-ld context
        indir overrides self.indir"""
        defdir = indir
        if defdir == '':
            indir = self.defdir #hack, this changes indir to defdir, as it should here
        if schemaname == 'tekst':
            'emigration specific'
            f = posixpath.join(indir, 'tekst', 'emigratie_' + schemaname + '.xml')
        elif schemaname == 'tekstannotatie':
            'emigration specific'
            f = posixpath.join(indir, 'tekst', 'emigratie_annotatie' + '.xml')
        else:
            f = posixpath.join(indir, schemaname + '.xml')
        if os.path.exists(f):
            context = self.schema2context(f)
            nf = os.path.basename(f)
            nf = os.path.splitext(nf)[0]
            out = nf + '_jsld.json'
            flout = open(posixpath.join(indir, out), 'w')
            dump( context, flout, indent=4)
            flout.close()
            self.registry[schemaname] = context
        else:
            raise IOError
        
                
    def getschema(self, indir='', schemaname=''):
        """get schema from registry if it exists
        or put it there for later use"""
        if schemaname not in self.registry:
            try:
                self.convert_schema(indir=indir, schemaname=schemaname)
            except IOError:
                pass
        outschema = self.registry.get(schemaname)
        return outschema


class JsonForm(object):
    def __init__(self, 
                 defdir='',
                 indir='', 
                 infile='',
                 url='', 
                 collectie='',
                 abbr=''):
        """parse ingforms xmlfile to json-ld
        taking a lxml etree as input"""
        self.infile = self.form2dict(infile)
        flname = os.path.split(infile)[-1]
        flname = os.path.splitext(flname)[0]
        self.name = flname
        self.root = list(self.infile.keys())[0]
        self.collectie=collectie,
        self.baseurl = url,
        if type(self.baseurl) == tuple:
            self.baseurl = self.baseurl[0]
        self.registry = SchemaConverter(indir=indir,
                                        defdir=defdir,
                                        baseurl=url)
        self.jsonfl = self.form2json(schemaurl=url,abbr=abbr)

    def jd_onderzoek(self,jd,indent,parent):
        new_jd = jd
        indent += "    "
        if isinstance (jd, str):
            print("%s%s" % (indent,jd))
            new_jd = jd
        if isinstance (jd, OrderedDict):
            new_jd = OrderedDict()
            for key in list(jd.keys()):
                new_key = key
                if parent.startswith(new_key):
                    new_key = parent + "s"
                print ("%s%s (key) (parent: %s):" % (indent,new_key,parent))
                new_jd[new_key] = self.jd_onderzoek(jd[key],indent,new_key)
        if isinstance (jd, list):
            new_jd = []
            print ("%slist:" % indent)
            for item in range(len(jd)):
                new_jd.append(self.jd_onderzoek(jd[item],indent,parent))
        return new_jd

 
    def form2dict(self, infile):
        """parse ingform to python dictionary"""
        xmlt = open(infile)
        doc = xmlt.read()
        jd = xmltodict.parse(doc)

        indent = ""
        print("jd_onderzoek")
        new_jd = self.jd_onderzoek(jd,indent,"")
        print("==end==")
        if len("%s" % jd ) != len("%s" % new_jd ):
            print("%d ongelijk aan %d" % (len("%s" % jd ),len("%s" % new_jd )) )
        return new_jd

# this function is not used at this moment
    def flatten(self, keyword, value):
        newarray = []
        if isinstance (value, str):
            return [value]
        if isinstance (value, list):
            for item in range(len(value)):
                newarray += self.flatten(keyword, value[item])
        else:
            if isinstance (value, OrderedDict):
                for key in list(value.keys()):
                    newarray += self.flatten(keyword, value[key])
        return newarray

    def add_ingforms_prefix(self, value, key_name="key", abbr="abbr"):
        if isinstance (value, str):
            return value
        if isinstance(value, list):
            newarray = []
            for item in range(len(value)):
                newarray.append(self.add_ingforms_prefix(value[item],key_name,abbr))
            value = newarray
        else:
            if isinstance(value, OrderedDict):
                newvalue = value.copy()
                for key in value:
                    res = self.add_ingforms_prefix(value[key],key,abbr)
                    if key != '@type' and key != '@value':
                        if not key.startswith("ingforms:"):
                            newkey = "ingforms:%s" % key
                            del newvalue[key]
                            newvalue[newkey] = res
                            if not "@type" in newvalue and not key_name == "" :
                                newvalue["@type"] = "%s:%s" % (abbr, key_name)
                                newvalue.move_to_end("@type", last=False)

                value = newvalue
        return value

    def form2json(self, schemaurl="url", abbr="abbr"):
        """parse fields to json-ld 
        and add schema"""

        #make base object
        jd = self.infile
        root = self.root
        
        #html thingies
        htmld = "http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML"
        pat = re.compile("^<p>")
        baseurl = "http://resource.huygens.knaw.nl/ingforms/"
        
        rt = root
        for key in list(self.infile[root].keys()):
            value = jd[root][key]
#            for keyword in ['trefwoord','thema','trefwoorden','namen','personen','matsoort','commissie']:
#                if keyword == key:
#                    jd[root][key] = self.flatten(keyword, value)
            try:
                if pat.search(value):
#                    id = posixpath.join(baseurl, root, key)
                    value = {"@value":value, "@type":htmld}
                    jd[root][key] = value
            except TypeError: # no string no html
                pass
            if 'datum' == key:
                if value is not None:
                    try:
                        day = value['day']
                        month = value['month']
                        year = value['year']
                        nwval = {"@type":"http://www.w3.org/2001/XMLSchema#dateTime",
                                "@value":"%02s-%02s-%04s" % (day, month, year)
                        }
                        value = nwval
                    except (AttributeError, IndexError):
                        pass # we keep the old value
                    jd[root][key] = value
            if 'periode' in key:
                try:
                    typ = posixpath.join(("%s:%s" % (abbr, root)), 'periode')
                    vals = value.split('-')
                    nwval = {"@type": typ,
                            "ingforms:begin":
                                {
                                    "@type": typ + '/begin',
                                     "ingforms:date": {
                                             "@type":"http://www.w3.org/2001/XMLSchema#dateTime",
                                             "@value":"31-12-%s" % vals[0]}},
                             "ingforms:end":{"@type": typ + '/end',
                                     "ingforms:date": {
                                             "@type":"http://www.w3.org/2001/XMLSchema#dateTime",
                                             "@value":"31-12-%s" % vals[1]}}
                    }
#                    typ = posixpath.join(baseurl, root, 'ingforms:periode')
                    value = nwval
                except (AttributeError, IndexError):
                    pass # we keep the old value
                jd[root][key] = value
            if isinstance(jd[root][key], dict):
                jd[root][key] = self.add_ingforms_prefix(jd[root][key],key,abbr)
                if not "@type" in jd[root][key]:
#                   jd[root][key]["@type"] = "http://resource.huygens.knaw.nl/ingforms/%s" % key
                    jd[root][key]["@type"] = "%s:%s" % ( abbr,key )
                    jd[root][key].move_to_end("@type", last=False)

        #add type, i.e. is the rootelement of the ingform
        jd['@type'] = posixpath.join(schemaurl, '%s' % self.collectie, root)
        prefix = "%s:%s" % ( abbr, root )
#        jd['@type'] = posixpath.join(prefix, root)
        jd['@type'] = prefix
        id = posixpath.join(baseurl, self.name)
        jd['@id'] = id
        
        #link template
        linktemplate = "{base}{collectienaam}/{typenaam}/{filename}"
        
        #add all formfields by key
        rjd = jd[root]
        for key in rjd:
            #relations to other objects
            if key.find('_link') > -1 and rjd[key]:
                relations = []
                if 'relation' in rjd[key] and isinstance(rjd[key]['relation'], list):
                    for item in rjd[key]['relation']:
                        fn = os.path.split(item)[-1]
                        relatie= linktemplate.format(collectienaam=self.collectie[0],
                                                  typenaam=rt,
                                                  filename=fn)
                        relatie = relatie.replace(' ', '_')
                        relations.append({"@id":relatie})
                    rjd[key] = relations
                else:
                    if rjd[key].get('relation'):
                        fn = os.path.split(rjd[key].get('relation'))[-1]
                        relatie = linktemplate.format(collectienaam=self.collectie[0],
                                                      typenaam=rt,
                                                      filename=fn)
                        relatie = relatie.replace(' ', '_')
                        relations.append({"@id":relatie})
                        rjd[key] = {"@id":relatie}
                
            elif rjd[key] and isinstance(rjd[key], OrderedDict):
                ks = list(rjd[key].keys())
                for item in ks:
                    try:
#                        import pdb; pdb.set_trace()
                        value = rjd[key][item]
                        typ = linktemplate.format(collectienaam=self.collectie[0],
                                                  typenaam=rt,
                                                  filename=item)
                        if isinstance(value, list):
                            value = {key:[{"@id":posixpath.join(typ, i),
                                     } for i in value],
                                     "@type":typ}
                        else:
                            value = {key:{"@id":posixpath.join(typ, value),
                                     },
                                     "@type":typ}
                        rjd[key] = value
                    except (TypeError, KeyError): #value or key is None, we leave this out
                        pass
        njd = {}
        njd["@type"] = jd["@type"]
        njd["@id"] = posixpath.join(njd["@type"], self.name)
        for key in jd[root]:
            njd["ingforms:"+key] = jd[root][key]
            if isinstance(jd[root][key], dict):
                for key_2 in jd[root][key]:
                    if key_2 != '@type' and key_2 != '@value':
                        print ("%s : %s" % (key_2,jd[root][key][key_2] ) )
        if root == 'autopsie':
            njd['@type'] = posixpath.join(baseurl,self.collectie[0],"text")
        return njd


    def with_context(self):
        """definition in ingforms  schema that we put in the registry"""
        fd = self.registry.getschema(self.root)
        jd = self.jsonfl
        
        #add some general properties that are added regardless of the schema.
        #Though these are also part of the single file output
        try:
            fd['aantekeningen'] = posixpath.join(self.baseurl, 'aantekeningen')
            fd['datum_laatste_verandering'] = posixpath.join(self.baseurl, 'last_modified')
            jd['@context'] = fd
        except TypeError:
            pass # cant find the schema, so leave it out
        return jd
      

def convert(indir='indir',
             defdir='defdir',
             targeturl='migratieurl',
             baseurl='baseurl',
             collectie='collectie',
             exclude=[],
             outfl='outfl',
             abbr='abbr'
            ):
    """convert an ingforms directory"""

    ingforms = recursive_glob(indir,'*.xml')
    for i in exclude:
        i = re.compile(i)
        ingforms = [f for f in ingforms if not i.search(f)]
    print ("forms read from %s" %indir)
    collectie = collectie
    for item in ingforms:
        try:
            converted = JsonForm(defdir,
                                 indir,
                                 item,
                                 baseurl,
                                 collectie,
                                 abbr,
                                 )
            contextualized = converted.with_context()
            outdir = posixpath.join(indir, 'out')
            outnm = os.path.split(item)[1]
            outnm = os.path.splitext(outnm)[0] + '.json'
            outfl = posixpath.join(outdir, outnm)
            outfile = open(outfl, 'w')
            dump(contextualized, outfile, indent=4)


        except IOError:
            pass
    print ("json files written to %s" % outdir)
    print ("number of files %s" % len(ingforms))        


def single_file_output(indir='indir',
             defdir='defdir',
             targeturl='migratieurl',
             baseurl='baseurl',
             collectie='collectie',
             exclude=[],
             outdir='outdir',
             outfl='outfl',
             abbr='abbr'
            ):
    """convert an ingforms directory to single file. This is too different from
    multifile con"""
    ingforms = recursive_glob(indir,'*.xml')
    for i in exclude:
        i = re.compile(i)
        ingforms = [f for f in ingforms if not i.search(f)]    
    print ("forms read from %s" %indir)
    collectie = collectie
    dumpable = {}
    graph = []
    types = []
    contexts = {}
    for item in ingforms:

            converted = JsonForm(defdir,
                                 indir,
                                 item,
                                 baseurl,
                                 collectie,
                                 abbr,
                                 )
            graph.append(converted.jsonfl)
            if converted.root not in types:
                types.append(converted.root)
    outdir = outdir
    for sch in types:
        context = SchemaConverter().getschema(sch)
        if context != None:
            for k in context:
                contexts[k] = context[k]
    #add some general properties
    contexts['aantekeningen'] = posixpath.join(baseurl, 'aantekeningen')
    contexts['datum_laatste_verandering'] = posixpath.join(baseurl, 'last_modified')
    contexts['ingforms'] = "http://ingforms.example.org/"
    contexts[collectie] = "%s%s/" % (baseurl,collectie)
    dumpable["@context"] = contexts
    dumpable["@graph"] = graph
    outf = posixpath.join(outdir, outfl)
    outfile = open(outfl, 'w')
    dump(dumpable, outfile, indent=4)
    outfile.close()
    print ("json written to %s" %outf)
    print ("number of files %s" % len(ingforms))      


def main(indir='indir',
             defdir='defdir',
             targeturl='migratieurl',
             baseurl='baseurl',
             collectie='collectie',
             exclude=[],
             outfl='outfl',
             single_file=False,
             abbr='abbr'):
    """converts a ingforms project and all files in it to json"""
    
    if single_file == True:
        single_file_output(indir=indir,
            defdir=defdir,
            targeturl=targeturl,
            baseurl=baseurl,
            collectie=collectie,
            exclude=exclude,
            outfl=outfl,
            abbr=abbr)
    else:
        convert(indir=indir,
                defdir=defdir,
                targeturl=targeturl,
                baseurl=baseurl,
                collectie=collectie,
                exclude=exclude,
                outfl=outfl,
                abbr=abbr)



if __name__ == "__main__":
    """Default execution
    -options: sinfle file or multiple files"""
    ap = argparse.ArgumentParser()
    ap.add_argument('-o', '--optionfile',
                    help="ifile with options. Default ./ingforms_options.ini",
                    default="./ingforms_options.ini"
                    )
                
    ap.add_argument("-s", "--single_file", help="output to a single file",
                        action="store_true", default=False)
    args = vars(ap.parse_args())
    sf = args['single_file']
    if args['single_file'] == True:
        print("output going to single file")
    cp = ConfigParser()
    cp.read(args['optionfile'])
    basedir = cp.get('location', 'basedir')
    indir = posixpath.join(basedir, cp.get('location', 'indir'))
    defdir = posixpath.join(basedir, cp.get('location', 'defdir'))
    outdir = posixpath.join(basedir, cp.get('output', 'outdir'))
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    outfile = posixpath.join(outdir, cp.get('output', 'outfile'))
    baseurl = cp.get('urls', 'base')
    targeturl = posixpath.join(baseurl, cp.get('urls', 'collectionurl'))
    ed = cp['exclude_dirs']
    excludedirs = [i[1] for i in ed.items()]
    collectie = cp.get('collection', 'collection')
    abbrtype = cp.get('abbreviations','abbrtype')
    main(indir=indir,
            outfl=outfile,
            defdir=defdir,
            targeturl=targeturl,
            baseurl=baseurl,
            collectie=collectie,
            exclude=excludedirs,
            single_file=sf,
            abbr=abbrtype)
