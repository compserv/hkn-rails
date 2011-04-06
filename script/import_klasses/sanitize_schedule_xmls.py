#!/usr/bin/env python

import re
from xml.dom import minidom
import sys
import simplejson

# Converts klass xml data to a json format. Adapted from the convert_all.py
# script from the old website.
#
# -adegtiar

DEFAULT_DEPARTMENTS=["EL ENG", "COMPSCI"]

#bad_klasses = ( "MEC ENG-297--Summer-2008", "INTEGBI-116-SAKANARI, J A-Summer-2008", "INTEGBI-141-NIERMANN, G L-Summer-2008", "MCELLBI-63-REYES, J A-Summer-2008" )

def normalize_dept(abbr):
    dept_replace = {"BUS ADM" : "UGBA"}
    return dept_replace.get(abbr, abbr)

instructor_patterns = (
     re.compile(r"(?P<last>[-A-Z']+( [-A-Z]+){0,4}), (?P<first>[A-Z])"),                      # matches "Harvey, B"
     re.compile(r"(?P<last>[-A-Z']+( [-A-Z]+){0,4}), (?P<first>[A-Z]) (?P<middle>[A-Z])"),                      # matches "Harvey, B H"
     re.compile(r"(?P<last>[A-Z]+(-[A-Z]+)?( [A-Z]+){0,4})"),                      # matches "PESTANA-NASCIMENTO"
)

also_pattern = re.compile(r'Also: (?P<instr_1>[-A-Z]*, [A-Z](?: [A-Z])?)(?:; (?P<instr_2>[-A-Z]*, [A-Z](?: [A-Z])?))?(?:; (?P<instr_3>[-A-Z]*, [A-Z](?: [A-Z])?))?(?:; (?P<instr_4>[-A-Z]*, [A-Z](?: [A-Z])?))?(?:; (?P<instr_5>[-A-Z]*, [A-Z](?: [A-Z])?))?')

#cross_listed = re.compile(r"Cross-listed with( [A-Za-z ']+ C\d+[A-Z]* section \d+(?: and|[,.]))+")
cross_listed = re.compile(r"(?:with)? ([A-Za-z ']+? C\d+[A-Z]* section \d+)(?: and|[,.])")

course_number_pattern = re.compile(r"([A-Z]*)([0-9]*)([A-Z]*)")

def safe_title(fun):
    def st(e):
        if e:
            return e.strip().title()
        return ""
    def do_it(*args, **kwargs):
        return map(lambda e: st(e), fun(*args, **kwargs))
    return do_it

@safe_title
def parse_name(name):
    for instructor_pattern in instructor_patterns:
        m = instructor_pattern.match(name)
        if m:
            d = m.groupdict()
            return (d.get("first"), d.get("middle"), d.get("last"))
    return ("", "", "")


def splitFullCourse(full_course_number):
    result = course_number_pattern.findall(full_course_number)
    if len(result) == 2:
        result.remove(('','',''))
    elif len(result) != 1:
        print "Poorly formatted course number: ", full_course_number
        print "Please check the input file."
        sys.exit(1)
    return result[0]

def importKlass(klass, year, season):
    klass_dict = {}
    klass_dict['name'] = klass.getAttribute("name")
    full_course_num = klass.getAttribute("course_number")[1:].strip()

    (prefix, number, suffix) = splitFullCourse(full_course_num)
    klass_dict['course_prefix'] = prefix
    klass_dict['course_number'] = number
    klass_dict['course_suffix'] = suffix
    klass_dict['units'] = klass.getAttribute("units")
    section = klass.getAttribute("section")
    klass_dict['section'], klass_dict['section_type'] = section.strip().split()
    instructors = [klass.getAttribute("instructor").strip()]
    klass_dict['times'] = klass.getAttribute("day-hour").strip()
    klass_dict['location'] = klass.getAttribute("room").strip()

    note = klass.getAttribute("note")
    if note.startswith("Note:"):
      section_note = note.replace("Note:", "", 1).strip()
    else:
      section_note = note.strip()
    klass_dict['section_note'] = section_note

    match = also_pattern.search(section_note)
    if match:
        instructors += filter(lambda x: x is not None, match.groups())

    instrs = []
    for instructor in instructors:
        instructor = instructor.strip()
        if len(instructor) == 0 or instructor == "THE STAFF":
            continue
        inst = zip(('first', 'middle', 'last'), parse_name(instructor))
        instrs.append(dict(inst))
    klass_dict['instructors'] = instrs
    return klass_dict

def importDepartment(department, year, season):
    abbr = department.getAttribute('abbr')

    klasses = []
    for klass in department.getElementsByTagName("klass"):
        if klass.hasAttribute("course_number") and klass.getAttribute("course_number")[0] == "P":
            klasses.append(importKlass(klass, year, season))
    return klasses

def importSemester(semester):
    semester_klasses = {}
    year = semester.getAttribute("year")
    season = semester.getAttribute("season")
    semester_klasses['year'] = year
    semester_klasses['season'] = season
    departments = {}
    for department in semester.getElementsByTagName("department"):
        abbr = department.getAttribute("abbr")
        if abbr in DEFAULT_DEPARTMENTS:
            departments[abbr] = importDepartment(department, year, season)
    semester_klasses['departments'] = departments
    return semester_klasses

def importFromXmlFile(klassFile):
    dom = minidom.parse(file(klassFile, "r"))
    for semester in dom.getElementsByTagName("semester"):
        serializeSemester(klassFile, importSemester(semester))

def serializeSemester(klassFile, klassData):
    newXmlName = klassFile.split('.')[0] + '_clean.xml'
    newXml = open(newXmlName, 'w')
    newXml.write(simplejson.dumps(klassData, sort_keys=True, indent=4))
    newXml.close()

def main(klassFile):
    print "Converting klasses from " + klassFile
    importFromXmlFile(klassFile)

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        main(sys.argv[1])
