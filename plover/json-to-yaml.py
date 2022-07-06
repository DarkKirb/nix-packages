#!@python@/bin/python
import json
import ruamel.yaml
import sys

JSON_FILENAME = sys.argv[1]
YAML_FILENAME = sys.argv[2]

# Load JSON dictionary
with open(JSON_FILENAME, 'r', encoding='utf-8') as in_file:
    in_data = json.load(in_file)

# Group dictionary by value, sorted alphabetically
out_data = {}

for key, value in sorted(in_data.items(), key=lambda x: x[1].casefold()):
    out_data.setdefault(value, []).append(key)
    out_data[value] = sorted(out_data[value])

# Write dictionary to YAML
with open(YAML_FILENAME, 'w', encoding='utf-8') as out_file:
    yaml = ruamel.yaml.YAML(typ='safe')
    yaml.allow_unicode = True
    yaml.default_flow_style = False
    yaml.indent(sequence=4, offset=2)
    yaml.dump(out_data, out_file)
