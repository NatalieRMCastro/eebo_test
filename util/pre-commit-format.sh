#/bin/sh

staged_files=`git diff --cached --name-status      |
                egrep -i '^(A|M).*\.(xml)$'        | # Only process certain files
                sed -e 's/^[AM][[:space:]]*//'     | # Remove leading git info
                sort                               | # Remove duplicates
                uniq`

for FILE in $staged_files ; do

# Sort attributes by name and indent with one space.
    tmp="$(mktemp)"

#   Must have lxml installed
    python3 - "$FILE" "$tmp" << 'PYTHONFORMAT' || { echo 'attribute sort and indent failed for:' "$FILE" >&2; exit 1; }
from lxml import etree
import sys

def sort_and_indent(elem, level: int = 0):
    attrib = elem.attrib
    if len(attrib) > 1:
        attributes = sorted(attrib.items())
        attrib.clear()
        attrib.update(attributes)

    i = "\n" + " " * level

    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + " "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            sort_and_indent(elem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

input_file = sys.argv[1]
output_file = sys.argv[2]

parser = etree.XMLParser(remove_blank_text=True, remove_pis=True)
tree = etree.parse(input_file, parser)
sort_and_indent(tree.getroot())
tree.write(output_file,
           encoding=tree.docinfo.encoding,
           xml_declaration=False,  # make our own below to get double quotes
           doctype='<?xml version="1.0" encoding="' + tree.docinfo.encoding + '"?>' + "\n"
                 + '<?xml-model href="http://schemata.earlyprint.org/schemata/tei_earlyprint.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>'
          )
PYTHONFORMAT

    mv "$tmp" "$FILE"
    git add "$FILE"

done
