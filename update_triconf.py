# coding: utf-8
path_to_triconf = 'trifacta-conf.json'

import shutil, datetime
timestamp = datetime.datetime.now().isoformat().replace(':', '_')
path_to_backup = path_to_triconf + '.' + timestamp
shutil.copyfile(path_to_triconf, path_to_backup)
import json
with open(path_to_triconf) as f:
    config = json.load(f)
    
import os
os.getenv('TRIFACTA_BUCKET')
config['aws']['s3']['bucket']['name'] = os.getenv('TRIFACTA_BUCKET')
config['webapp']['runInEMR'] = True
with open(path_to_triconf, 'w') as f:
    json.dump(config, f, indent=2)
    
