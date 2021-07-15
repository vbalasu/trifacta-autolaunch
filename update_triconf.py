# coding: utf-8
path_to_triconf = '/opt/trifacta/conf/trifacta-conf.json'

import shutil, datetime
timestamp = datetime.datetime.now().isoformat().replace(':', '_')
path_to_backup = path_to_triconf + '.' + timestamp
shutil.copyfile(path_to_triconf, path_to_backup)
import json
with open(path_to_triconf) as f:
    config = json.load(f)
    
with open('stack.json') as f:
    stack = json.load(f)

trifacta_bucket = [o['OutputValue'] for o in stack['Stacks'][0]['Outputs'] if o['OutputKey'] == 'TrifactaBucket'][0]
config['aws']['s3']['bucket']['name'] = trifacta_bucket
config['webapp']['runInEMR'] = True
with open(path_to_triconf, 'w') as f:
    json.dump(config, f, indent=2)
    
