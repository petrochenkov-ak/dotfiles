#!/usr/bin/env python3
import json
import orderdict
import os
import re
import subprocess
import sys

# https://docs.npmjs.com/files/package.json


KEYS = [
    "name",
    "version",
    "description",
    "keywords",
    "homepage",
    "bugs",
    "license",  # https://docs.npmjs.com/files/package.json#license
    "files",
    "main",
    "browser",
    "bin",
    "man",
    "directories",
    "repository",
    "scripts",
    "dependencies",
    "devDependencies",
    "peerDependencies",
    "bundledDependencies",
    "optionalDependencies",
    "engines",
    "engineStrict",
    "os",  # https://docs.npmjs.com/files/package.json#os
    "cpu",
    "private",
    "publishConfig"
]

LIST_KEYS = [
    "keywords",
    "os"
]

def getname():
    return os.path.basename(os.getcwd()).split('.')[0]

def getversion():
    if os.path.exists('setup.py'):
        version = subprocess.getoutput("python3 setup.py --version").strip()
        if len(version.splitlines())>1:
            raise ValueError(version)
        return version
    return date.strftime("%Y-%m-%d").replace('-0', '-')

def getdescription():
    return re.sub(':[^:]+:', '', open('.github/description.txt').read()).strip()

def getlicense():
    user = subprocess.getoutput("git config user.name").strip()
    fullname = "%s/%s" % (user,os.path.basename(os.getcwd()))
    return "https://github.com/%s" % fullname

def getbin():
    data = {}
    for l in filter(lambda l:l not in [".DS_Store"],os.listdir('bin')):
        path = os.path.join('bin', l)
        if os.path.isfile(path):
            data[l] = "./%s" % os.path.relpath(path,os.getcwd())
    return data

def beautify(data):
    return json.dumps(orderdict.order(KEYS, data), indent=2)

def getos():
    return 'darwin linux'

if __name__ == "__main__":
    data = dict(
        name=getname(),
        version=getversion(),
        description=getdescription(),
        license=getlicense(),
        bin = getbin()
    )
    open('package.json','w').write(beautify(data))
