# -*- coding: utf-8 -*-
import argparse
from datetime import datetime
import glob
import html
from html.parser import HTMLParser
from html.entities import name2codepoint
from html.entities import html5
import locale
locale.setlocale(locale.LC_ALL, 'nl-NL')
import os.path
import re
import sys
import unicodedata

class MyHTMLParser(HTMLParser):

    in_title = False
    title = ""
    in_chapter = False
    tags = []
    locals = locals()
    indent = ""
    afk = ""
    in_datum = False
    only_jaar = False
    in_jaar = False
    in_maand = False
    in_dag = False
    dag = ""
    maand = ""
    jaar = ""
    level = 1
    keyword_type = ""
    in_keyword = False
    in_person = False
    in_geo_keyw = False
    keywords = {}
    last_keyword = ""
    geo_keywords = {}
    persons = {}
    in_relation = False
    relations = []
    filename = ""
    related_type = []
    in_comment = False
    comment = ""
    in_dossier = False
    dossier = ""
    in_staatsblad = False
    in_bijblad = False
    in_other_law = False
    in_date_regulation = False
    in_verbaal = False
    in_besluit = False
    in_mailrapport = False
    wetgeving_title = ""
    in_related_records = False
    pattern = re.compile("[^a-z]+")
    current_tag = ""
    current_data = ""
    tags_without_resource = ['addressee', 'archival_section_number', 'author', 'besluit_invnr', 'decisionmaker',
            'dossier', 'index_invnr', 'mailrapport_invnr', 'number_in_index', 'recipient', 'reference_kviv',
            'scan', 'secret', 'section_number', 'verbaal_found', 'verbaal_invnr']
    tags_with_resource = ['aantekeningen', 'link_scan', 'remarks', 'short_description', 'summary']
    entiteiten = []

    def __init__(self,output,collection,afk):
        super().__init__()
        self.output = output
        self.collection = collection
        self.afk = collection
        self.number = 1
        self.locals
#        for it in self.locals:
#            print(it)

    def add_attrs(self,attrs):
        res = ""
        for attr in attrs:
#            print(attr.__class__)
            res += ' {}="{}"'.format(attr[0],attr[1])
        return res   



    def verbaal_start(self,attrs):
#        self.put_out("{}<{}:verbaal rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.in_datum = True
        self.dag = ""
        self.maand = ""
        self.jaar = ""


    def verbaal_end(self):
        self.in_datum = False
#        indent = self.make_indent(self.level - 1)
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:verbaal_date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{1}</{0}:verbaal_date>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:verbaal_comment>{1}</{0}:verbaal_comment>\n".format(self.afk, self.comment))
        self.comment = ""

#        self.put_out("{}<{}:verbaal_date rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
#        self.put_out("  {1}{2}\n{1}</{0}:verbaal>\n".format(self.afk, indent,self.verwerk_datum()))
#        self.put_out("{}<schema:title>Verbaal {} - {}</schema:title>\n".format(indent, self.get_datum(), self.comment))


    def year_start(self,attrs):
        self.in_jaar = True


    def year_end(self):
        indent = self.make_indent(self.level - 1)
        if self.only_jaar and not self.in_mailrapport:
            if not self.jaar=="" and not self.in_staatsblad:
                self.put_out("{0}<{1}:year>{2}</{1}:year>\n".format(indent,self.afk,self.jaar))
                self.only_jaar = False
        self.in_jaar = False


    def month_start(self,attrs):
        self.in_maand = True


    def month_end(self):
        self.in_maand = False


    def day_start(self,attrs):
        self.in_dag = True


    def day_end(self):
        self.in_dag = False


    def comment_start(self,attrs):
#        self.put_out("{}<{}:comment>".format(self.make_indent(),self.afk))
        self.in_comment = True

    def comment_end(self):
        self.in_comment = False
#        if not self.comment=="" and not self.in_staatsblad and not self.in_mailrapport \
#                and not self.in_date_regulation and not self.in_verbaal and not self.in_besluit:
#            indent = self.make_indent(self.level - 1)
#            self.put_out("    {0}<{1}:comment>{2}</{1}:comment>\n".format(indent, self.afk, self.comment))
#            self.comment = ""


    def date_document_start(self,attrs):
#        self.put_out("{}<{}:date_document rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.in_datum = True
        self.dag = ""
        self.maand = ""
        self.jaar = ""

    def date_document_end(self):
        self.in_datum = False
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:date_document rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{1}</{0}:date_document>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:date_document_comment>{1}</{0}:date_document_comment>\n".format(self.afk, self.comment))
        self.comment = ""


    def keyword_geography_start(self,attrs):
#        self.keyword_seq_start("geography")
        self.keyword_type = "keyword_geography"
        self.in_geo_keyw = True

    def keyword_geography_end(self):
#        self.keyword_seq_end("geography")
         self.in_geo_keyw = False
         self.keyword_type = "keyword"

    def geography_start(self,attrs):
        pass
#        self.put_out("{}<{}:geography rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))

    def geography_end(self):
        pass
#        self.put_out("{}</{}:geography>\n".format(self.make_indent(self.level - 1),self.afk))


    def keyword_start(self,attrs):
        if not self.any_keyword():
            self.put_out("{}<{}:keyword>".format(self.make_indent(),self.afk))

    def keyword_end(self):
        if self.any_keyword():
            keyw_type = self.keyword_type
            if keyw_type=="keyword_cc" or keyw_type=="keyword_pc" or keyw_type=="keyword_hbco" or keyw_type=="keyword_islam":
                keyw_type = "keyword"
            elif keyw_type=="keyword_geography":
                keyw_type = "geo_keyword"
            self.put_out("{0}<{1}:{2} rdf:resource=\"https://resource.huygens.knaw.nl/{1}/{4}/{3}\"/>\n".format(self.make_indent(2),
                        self.collection, self.keyword_type,
                        self.last_keyword, keyw_type))
        else:
            self.put_out("</{}:keyword>\n".format(self.afk))


    def keyword_person_start(self,attrs):
#        self.keyword_seq_start("person")
        self.keyword_type = "keyword_person"
        self.in_person = True

    def keyword_person_end(self):
#        self.keyword_seq_end("person")
        self.in_person = False
        self.keyword_type = "keyword"


    def person_start(self,attrs):
        pass
#        self.put_out("{}<{}:person rdf:parseType=\"Resource\">\n".format(self.make_indent(),
#            self.afk))

    def person_end(self):
        pass
#        self.put_out("{}</{}:person>\n".format(self.make_indent(self.level - 1),self.afk))


    def keyword_islam_start(self,attrs):
#        self.keyword_seq_start("islam")
        self.in_keyword = True
        self.keyword_type = "keyword_islam"

    def keyword_islam_end(self):
#        self.keyword_seq_end("islam")
        self.in_keyword = False
        self.keyword_type = "keyword"


    def keyword_hbco_start(self,attrs):
#        self.keyword_seq_start("hbco")
        self.in_keyword = True
        self.keyword_type = "keyword_hbco"

    def keyword_hbco_end(self):
#        self.keyword_seq_end("hbco")
        self.in_keyword = False
        self.keyword_type = "keyword"


    def keyword_pc_start(self,attrs):
#        self.keyword_seq_start("pc")
        self.in_keyword = True
        self.keyword_type = "keyword_pc"

    def keyword_pc_end(self):
#        self.keyword_seq_end("pc")
        self.in_keyword = False
        self.keyword_type = "keyword"


    def keyword_cc_start(self,attrs):
#        self.keyword_seq_start("cc")
        self.keyword_type = "keyword_cc"
        self.in_keyword = True

    def keyword_cc_end(self):
#        self.keyword_seq_end("cc")
        self.in_keyword = False
        self.keyword_type = "keyword"


    def related_records_verbaal_start(self,attrs):
#        self.keyword_seq_start("related_records_verbaal")
#        self.put_out("<gpol:related_records_verbaal>\n")
        self.related_type = ["verbalen","verbaal"]

    def related_records_verbaal_end(self):
#        self.keyword_seq_end("related_records_verbaal")
#        self.put_out("</gpol:related_records_verbaal>\n")
        self.related_type = []


    def relation_start(self,attrs):
#        self.put_out("{}<{}:relation>".format(self.indent,self.afk))
        self.in_relation = True

    def relation_end(self):
#        self.put_out("</{}:relation>\n".format(self.afk))
        self.in_relation = False


    def related_records_besluiten_start(self,attrs):
#        self.keyword_seq_start("related_records_besluiten")
#        self.put_out("<gpol:related_records_besluiten>\n")
        self.related_type = ["besluiten","besluiten"]

    def related_records_besluiten_end(self):
#        self.keyword_seq_end("related_records_besluiten")
#        self.put_out("</gpol:related_records_besluiten>\n")
        self.related_type = []


    def related_records_mailrapporten_start(self,attrs):
#        self.keyword_seq_start("related_records_mailrapporten")
#        self.put_out("<gpol:related_records_mailrapporten>\n")
        self.related_type = ["mailrapporten","mailrapporten"]

    def related_records_mailrapporten_end(self):
#        self.keyword_seq_end("related_records_mailrapporten")
#        self.put_out("</gpol:related_records_mailrapporten>\n")
        self.related_type = []


    def related_records_staatsblad_start(self,attrs):
#        self.keyword_seq_start("related_records_staatsblad")
#        self.put_out("<gpol:related_records_staatsblad>\n")
        self.related_type = ["wetgeving","staatsblad"]

    def related_records_staatsblad_end(self):
#        self.keyword_seq_end("related_records_staatsblad")
#        self.put_out("</gpol:related_records_staatsblad>\n")
        self.related_type = []


    def keyword_subject_start(self,attrs):
#        self.keyword_seq_start("keyword_subject")
        self.keyword_type = "keyword_subject"
        self.in_keyword = True

    def keyword_subject_end(self):
#        self.keyword_seq_end("keyword_subject")
        self.in_keyword = False
        self.keyword_type = "keyword"


    def subject_start(self,attrs):
        pass
#        self.put_out("{}<{}:subject rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))

    def subject_end(self):
        pass
#        self.put_out("{}</{}:subject>\n".format(self.make_indent(self.level - 1),self.afk))


    def published_in_start(self,attrs):
        self.put_out("{}<{}:published_in>".format(self.indent,self.afk))

    def published_in_end(self):
        self.put_out("</{}:published_in>\n".format(self.afk))


    def archival_references_start(self,attrs):
        self.put_out("{}<{}:archival_references>".format(self.indent,self.afk))

    def archival_references_end(self):
        self.put_out("</{}:archival_references>\n".format(self.afk))


    def see_also_start(self,attrs):
        self.put_out("{}<{}:see_also>".format(self.indent,self.afk))

    def see_also_end(self):
        self.put_out("</{}:see_also>\n".format(self.afk))


    def besluit_start(self,attrs):
#        self.put_out("{}<{}:besluit rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.in_datum = True
        self.dag = ""
        self.maand = ""
        self.jaar = ""

    def besluit_end(self):
        self.in_datum = False
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:besluit_date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{1}</{0}:besluit_date>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:besluit_comment>{1}</{0}:besluit_comment>\n".format(self.afk, self.comment))
        self.comment = ""
#        indent = self.make_indent(self.level - 1)
#        self.put_out("  {1}{2}\n{1}</{0}:besluit>\n".format(self.afk,
#            indent,self.verwerk_datum()))
#        self.put_out("{}<schema:title>Besluit {} - {}</schema:title>\n".format(indent,self.get_datum(),self.comment))


    def titledossier_start(self,attrs):
#        self.put_out("{}<{}:titledossier>".format(self.indent,self.afk))
        self.in_dossier = True

    def titledossier_end(self):
        self.put_out("    <{0}:titledossier>{1}</{0}:titledossier>\n".format(self.afk,
                    self.dossier))
        self.put_out("    <schema:title>{}</schema:title>\n".format(self.dossier))
        self.in_dossier = False
        self.current_data = ""


    def mailrapport_start(self,attrs):
#        self.put_out("{}<{}:mailrapport rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.only_jaar = True

    def mailrapport_end(self):
        datum = self.get_datum()
        if not datum=="":
            self.put_out("    <{0}:mailrapport_year>{1}</{0}:mailrapport_year>\n".format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:mailrapport_comment>{1}</{0}:mailrapport_comment>\n".format(self.afk, self.comment))
        self.comment = ""
        self.only_jaar = False
#        indent = self.make_indent(self.level - 1)
#        self.put_out("{}</{}:mailrapport>\n".format(indent,self.afk))
#        self.put_out("{}<schema:title>Mailrapport {} - {}</schema:title>\n".format(indent, self.get_datum(), self.comment))


    def date_besluit_start(self,attrs):
#        self.put_out("{}<{}:date_besluit rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.in_datum = True
        self.dag = ""
        self.maand = ""
        self.jaar = ""
        self.comment = ""

    def date_besluit_end(self):
        self.in_datum = False
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:date_besluit rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{1}</{0}:date_besluit>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:date_besluit_comment>{1}</{0}:date_besluit_comment>\n".format(self.afk, self.comment))
        self.comment = ""
#       self.put_out("{1}{2}\n{3}</{0}:date_besluit>\n".format(self.afk,
#            self.make_indent(),self.verwerk_datum(),self.make_indent(self.level - 1)))


    def staatsblad_start(self,attrs):
#        self.put_out("{}<{}:staatsblad rdf:parseType=\"Resource\">\n".format(self.indent,self.afk))
        self.only_jaar = True
        self.in_staatsblad = True

    def staatsblad_end(self):
        self.only_jaar = False
        self.in_staatsblad = False
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:staatsblad_year>{1}</{0}:staatsblad_year>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:staatsblad_comment>{1}</{0}:staatsblad_comment>\n".format(self.afk, self.comment))
#        if self.jaar=="" and self.comment=="":
#            return
#        indent = self.make_indent(self.level - 1)
#        self.put_out("{}<{}:staatsblad rdf:parseType=\"Resource\">\n".format(indent, self.afk))
#        if not self.jaar=="":
#            self.put_out("  {0}<{1}:year>{2}</{1}:year>\n".format(indent, self.afk, self.jaar))
#        if not self.comment=="":
#            self.put_out("  {0}<{1}:comment>{2}</{1}:comment>\n".format(indent, self.afk, self.comment))
#        self.put_out("{}</{}:staatsblad>\n".format(indent, self.afk))
        if not self.wetgeving_title.strip()=="":
            self.put_out("    <schema:title>Stb {} - {}</schema:title>\n".format(datum, self.comment))
        self.wetgeving_title = ""
        self.jaar = ""
        self.comment = ""


    def bijblad_start(self,attrs):
#        self.put_out("{}<{}:bijblad>".format(self.indent,self.afk))
        self.in_bijblad = True

    def bijblad_end(self):
        self.in_bijblad = False
        if self.wetgeving_title.strip()=="":
            return
        indent = self.make_indent(self.level - 1)
        self.put_out("{0}<{1}:bijblad>{2}</{1}:bijblad>\n".format(indent, self.afk, self.wetgeving_title.strip()))
#        if self.jaar=="":
        self.put_out("{}<schema:title>Bb {}</schema:title>\n".format(indent, self.wetgeving_title.strip()))
#        else:
#            self.put_out("{}<schema:title>Bb {}, {}</schema:title>\n".format(indent,
#                self.wetgeving_title.strip(), self.jaar))
        self.wetgeving_title = ""


    def other_law_start(self,attrs):
#        self.put_out("{}<{}:other_law>".format(self.indent,self.afk))
        self.in_other_law = True

    def other_law_end(self):
        self.in_other_law = False
        if self.wetgeving_title.strip()=="":
            return
        indent = self.make_indent(self.level - 1)
        self.put_out("{0}<{1}:other_law>{2}</{1}:other_law>\n".format(indent, self.afk, self.wetgeving_title.strip()))
        if not self.wetgeving_title=="":
            self.put_out("{}<schema:title>{}</schema:title>\n".format(indent, self.wetgeving_title.strip()))
        self.wetgeving_title = ""


    def date_regulation_start(self,attrs):
        self.in_datum = True
        self.dag = ""
        self.maand = ""
        self.jaar = ""
        self.comment = ""
        self.in_date_regulation = True

    def date_regulation_end(self):
        self.in_datum = False
        datum = self.get_datum()
        if not datum=="":
            self.put_out('    <{0}:date_regulation rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{1}</{0}:date_regulation>\n'.format(self.afk, datum))
        if not self.comment=="":
            self.put_out("    <{0}:date_regulation_comment>{1}</{0}:date_regulation_comment>\n".format(self.afk, self.comment))
        self.comment = ""
#        if self.jaar=="" and self.comment=="":
#            return
#        indent = self.make_indent(self.level - 1)
#        self.put_out("{}<{}:date_regulation rdf:parseType=\"Resource\">\n".format(indent,self.afk))
#        if not self.jaar=="":
#            self.put_out("  {0}{1}\n".format(indent, self.verwerk_datum()))
#        if not self.comment=="":
#            self.put_out("  {0}<{1}:comment>{2}</{1}:comment>\n".format(indent, self.afk, self.comment))
#        self.put_out("{0}</{1}:date_regulation>\n".format(indent, self.afk))
#        self.in_date_regulation = False


    def tag_string(self, tag, literal=False):
        text = self.clean_text(self.current_data)
        self.current_data = ""
        if text=="":
            return
        lit_str = ''
        if literal:
            lit_str = ' rdf:parseType="Literal"'
        self.put_out("    <{0}:{1}{3}>{2}</{0}:{1}>\n".format(self.afk, tag, text, lit_str))


    def handle_starttag(self, tag, attrs):
        self.current_tag = tag
        r = self.locals
        if self.level == 1:
            code = os.path.basename(self.filename)[:-4]
            self.number += 1
            self.comment = ""
            lines = '''
  <{0}:{1} rdf:about="https://resource.huygens.knaw.nl/{0}/{1}/{2}">
'''
            self.put_out(lines.format(collection, tag, code))
            if tag=="besluiten":
                self.put_out("    <schema:title>Besluit {}</schema:title>\n".format(code.replace("--",", ")))
                self.in_besluit = True
            elif tag=="verbalen":
                self.put_out("    <schema:title>Verbaal {}</schema:title>\n".format(code.replace("--",", ")))
                self.in_verbaal = True
            elif tag=="mailrapporten":
                self.put_out("    <schema:title>Mailrapport {}</schema:title>\n".format(code.replace("--",", ")))
                self.in_mailrapport = True
            self.jaar = ""
        elif tag in self.tags_without_resource:
            pass
        elif tag in self.tags_with_resource:
            pass
        else:
            try:
                res = r[tag+"_start"]
                res(self,self.handle_attrs(attrs))
            except KeyError:
                if tag not in self.tags:
                    self.tags.append(tag)
        self.inc_level() # += 1
        self.indent = self.make_indent()
 
#print("Oops!  No start function for {}. Try\
                    #again...".format(tag))
            #print("<{}{}>".format(tag,self.add_attrs(attrs)))
          #  print("Start tag:", tag+"_start")
          #  for attr in attrs:
        #      print("     attr:", attr)


    def handle_endtag(self, tag):
        code = os.path.basename(self.filename)[:-4]
        if self.level == 2:
            self.put_out("  </{0}:{1}>\n".format(collection, tag))
            self.in_verbaal = False
            self.in_besluit = False
            self.in_mailrapport = True
        elif tag in self.tags_without_resource:
            self.tag_string(tag)
        elif tag in self.tags_with_resource:
            self.tag_string(tag, True)
        else:
            try:
                self.locals[tag+"_end"](self)
            except KeyError:
                pass
        self.dec_level() # -= 1
        self.indent = self.make_indent()

    def handle_data(self, data):
        if self.any_keyword():
            if not data.strip()=="":
                keyword = self.make_id_from_words(data.strip())
                self.last_keyword = keyword
                if self.in_keyword:
                    if keyword=="education_religious_personnel":
                        keyword = "education_of_religious_personnel"
                        self.last_keyword = keyword
                    elif keyword=="clergy_nomination_regular":
                        keyword = "clergy_nomination_of_regular"
                        self.last_keyword = keyword
                    if not keyword in self.keywords:
                        stderr("unknown keyword: {}".format(keyword))
                        self.keywords[keyword] = data.strip().capitalize()
                elif self.in_person and not data.strip() in self.persons:
                    self.persons[keyword] = data.strip()
                elif self.in_geo_keyw and not data.strip() in self.geo_keywords:
                    self.geo_keywords[keyword] = data.strip()
            else:
                self.last_keyword = ""
        elif self.in_relation:
            data = "https://resource.huygens.knaw.nl/{}/{}/{}".format(self.collection,
                    self.related_type[0], os.path.basename(data.strip()))
#            if not data.strip() in self.relations:
#                self.relations.append(data.strip())
        if self.in_title:
            self.title = data
        if self.in_jaar:
            self.jaar = data.strip()
        elif self.in_maand:
            self.maand = data.strip()
        elif self.in_dag:
            self.dag = data.strip()
        elif self.in_relation and not self.related_type==[]:
            self.put_out("    <{}:related_records_{} rdf:resource=\"{}\"/>\n".format(self.afk, self.related_type[1], data))
        else:
            if not len(data.strip()) == 0 and not (self.any_keyword() or self.do_not_print()):
                self.current_data += " " + data.strip()
        if self.in_comment:
            self.comment = data.strip()
        if self.in_dossier:
            self.dossier = data.strip()
        if (self.in_staatsblad or self.in_bijblad or self.in_other_law) and not self.in_jaar:
            self.wetgeving_title += " " + data.strip()
#   

    def handle_comment(self, data):
        pass
        #print("Comment  :", data)

    def handle_entityref(self, name):
        pass
        #c = chr(name2codepoint[name])
        #print("Named ent:", c)

    def handle_charref(self, name):
        pass
        #if name.startswith('x'):
            #c = chr(int(name[1:], 16))
        #else:
            #c = chr(int(name))
        #print("Num ent  :", c)

    def handle_decl(self, data):
        pass
        #print("Decl     :", data)

    def handle_attrs(self, attrs):
        res = {}
        for a in attrs:
            res[a[0]] = a[1]
        return res
#        sys.stderr.write("len(attrs): {}\n{}\n".format(len(attrs),attrs))
#        for i in range(0,len(attrs),2):
#            res[attrs[i]] = attrs[i+1]
#            sys.stderr.write("i: {}\n".format(i))
#        return res


    def any_keyword(self):
        return self.in_keyword or self.in_person or self.in_geo_keyw

    def do_not_print(self):
        return self.in_bijblad or self.in_comment or self.in_other_law

    def make_id_from_words(self,text):
        if self.pattern.search(text):
            text_id = self.pattern.sub("_",text.lower()) # .strip('_')
            # strip('_') pas uitvoeren als probleem upper lower etc is
            # opgelost
            return text_id
        else:
            return text

    def clean_text(self,text):
        entiteiten = re.finditer(r"(&[^ ;]+)(.)", text)
        for ent in entiteiten:
            ent_s = "{}{}".format(ent.group(1),ent.group(2))
            if ent_s not in self.entiteiten:
                self.entiteiten.append(ent_s)
#        text = re.sub(r"</p> *<p>","\n",text.strip())
        text = re.sub(r"</p> *<p>","</p>\n<p>",text.strip())
#        if text[0:3]=="<p>":
#            text = text[3:]
#        if text[-4:]=="</p>":
#            text = text[0:-4]
#        text = text.strip()
#        if text[-3:]=="<p>":
#            text = text[0:-3].strip()

        # Ja, ja... Dit moet echt drie keer gebeuren voordat alles is
        # omgezet naar utf8!
        text = html.unescape(html.unescape(html.unescape(text)))
#        text = text.replace("<","&lt;")
#        text = text.replace(">","&gt;")
        text = text.replace("&","&amp;")
        return text.strip()

    def inc_level(self):
        self.level += 1

    def dec_level(self):
        if self.level > 1:
            self.level -= 1
        
    def make_indent(self, num=0):
        if num==0:
            res = "  " * self.level
        else:
            res = "  " * num
        return res

    def put_out(self, arg):
        self.output.write(arg)


    def get_datum(self):
        dag = ""
        maand = ""
        if self.only_jaar:
            return self.jaar

        if not len(self.maand) == 0:
            try:
                maand = "-{:0>2d}".format(int(self.maand)) #sprintf("-%02d",@dag.to_i)
            except ValueError:
                stderr("maand: {}".format(self.maand))
#            maand = "-{:0>2d}".format(int(maand)) #sprintf("-%02d",@maand.to_i)
        if not len(self.dag) == 0:
            try:
                dag = "-{:0>2d}".format(int(self.dag)) #sprintf("-%02d",@dag.to_i)
            except ValueError:
                stderr(dag)
        return '{}{}{}'.format(self.jaar,maand,dag)

    def verwerk_datum(self):
        result = '<{1}:date rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{2}</{1}:date>'
        return result.format(self.make_indent(),self.afk,self.get_datum())


def help_message():
    stderr("use: python gd_politiek_parser.py -d directory -c collection -o output")
    sys.exit(0)


def stderr(text):
    sys.stderr.write("{}\n".format(text))


def arguments():
    ap = argparse.ArgumentParser(description='Read and convert files from "godsdienstpolitiek"')
    ap.add_argument('-y', '--jaar',
                    help="jaar"
                    )
    ap.add_argument('-i', '--inputfile',
                    help="inputfile" )
    ap.add_argument('-d', '--directory',
                    help="directory" )
    ap.add_argument('-c', '--collection',
                    help="collection" )
    ap.add_argument('-o', '--outputfile',
                    help="outputfile" )
    ap.add_argument('-r', '--resource',
                    help="resource",
                    default = "https://resource.huygens.knaw.nl/ingforms/gpol" )
    args = vars(ap.parse_args())
    return args


if __name__ == "__main__":
    stderr("start")
    stderr(datetime.today().strftime("%H:%M:%S"))

    args = arguments()
#    inputfile = args['inputfile']
    directory = args['directory']
    outputfile = args['outputfile']
    collection = args['collection']
#    resource = args['resource']
    if not directory or not outputfile or not collection:
        help_message()

    afk = collection[0:1]
    output = open(outputfile,"w", encoding='utf-8')
    # evt. aanpassen:
    rdf_rdf ='''<?xml version="1.0"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:{collection}="https://resource.huygens.knaw.nl/{collection}"
    xmlns:schema="http://schema.org/"
    xmlns:person="https://resource.huygens.knaw.nl/constitutionele_commissies/person">
'''
    output.write(rdf_rdf.format(afk=afk,collection=collection))

    all_files = glob.glob("{}/**/*.xml".format(directory),recursive=True)
    # verwijder alles met adviesKIZ uit all_files


    parser = MyHTMLParser(output,collection,afk)

    #  hier all_keywords.txt lezen en toevoegen aan parser.keywords
    invoer = open("all_keywords.txt", encoding='utf-8')
    for line in invoer:
        if line.startswith(" "):
            [title,id] = line.strip().split(' - ')
            if not id in parser.keywords:
                parser.keywords[id] = title
    stderr("found {} unique keywords".format(len(parser.keywords)))

    tel_kiz_skipped = 0
    for filename in all_files:
        if not "adviesKIZ" in filename:
#            stderr(filename)
            invoer = open(filename, encoding='utf-8')
            parser.filename = filename
            for line in invoer:
                parser.feed(line)
        else:
            tel_kiz_skipped += 1
    stderr("{} records adviesKIZ doen we niet".format(tel_kiz_skipped))

    output.write("\n")
    for key in sorted(parser.keywords):
        keyword = parser.keywords[key]
        keyword_lines = \
'''  <gpol:keyword rdf:about="https://resource.huygens.knaw.nl/gpol/keyword/{0}">
    <gpol:keyword_id>{0}</gpol:keyword_id>
    <gpol:displayName>{1}</gpol:displayName>
    <schema:title>{1}</schema:title>
  </gpol:keyword>
'''.format(key,keyword)  # later keyword in tabel opzoeken voor echte displayname
        output.write(keyword_lines)

    output.write("\n")
    for key in sorted(parser.persons):
        person = parser.persons[key]
        person_lines = \
'''  <gpol:keyword_person rdf:about="https://resource.huygens.knaw.nl/gpol/keyword_person/{0}">
    <gpol:keyword_id>{0}</gpol:keyword_id>
    <gpol:displayName>{1}</gpol:displayName>
    <schema:title>{1}</schema:title>
  </gpol:keyword_person>
'''.format(key,person)  # later keyword in tabel opzoeken voor echte displayname
        output.write(person_lines)

    output.write("\n")
    for key in sorted(parser.geo_keywords):
        keyword = parser.geo_keywords[key]
        keyword_lines = \
'''  <gpol:geo_keyword rdf:about="https://resource.huygens.knaw.nl/gpol/geo_keyword/{0}">
    <gpol:keyword_id>{0}</gpol:keyword_id>
    <gpol:displayName>{1}</gpol:displayName>
    <schema:title>{1}</schema:title>
  </gpol:geo_keyword>
'''.format(key,keyword)  # later keyword in tabel opzoeken voor echte displayname
        output.write(keyword_lines)

    output.write("\n</rdf:RDF>\n")
    output.close()


    output = open("found_keywords.txt","w", encoding='utf-8')
    output.write("keywords ({}):\n".format(len(parser.keywords)))
    for key in sorted(parser.keywords):
        keyword = parser.keywords[key]
        output.write("{} - {}\n".format(key,keyword))
    output.close()

    output = open("found_geo_keywords.txt","w", encoding='utf-8')
    output.write("geo keywords ({}):\n".format(len(parser.geo_keywords)))
#    parser.geo_keywords.sort(key=str.lower)
    for key in sorted(parser.geo_keywords):
        keyword = parser.geo_keywords[key]
        output.write("{}\n".format(keyword))
    output.close()
    
    output = open("found_persons.txt","w", encoding='utf-8')
    output.write("persons ({}):\n".format(len(parser.persons)))
#    parser.persons.sort(key=str.lower)
    for key in sorted(parser.persons):
        person = parser.persons[key]
        output.write("{}\n".format(person))
    output.close()

    stderr("unknown tags ({}):".format(len(parser.tags)))
    for t in parser.tags:
        stderr("{}".format(t))

#    stderr("html entiteiten ({}):".format(len(parser.entiteiten)))
#    for t in parser.entiteiten:
#        stderr("{} - {}".format(t,html.unescape(t)))

    stderr(datetime.today().strftime("%H:%M:%S"))
    stderr("einde")

'''
    output = open("found_relations.txt","w", encoding='utf-8')
    output.write("relations ({}):\n".format(len(parser.relations)))
    for relation in parser.relations:
        output.write("{}\n".format(relation))
    output.close()
'''

