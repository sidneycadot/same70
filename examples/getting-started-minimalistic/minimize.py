#! /usr/bin/env python3

import subprocess
import hashlib
import os
def rebuild():
    args = ["make", "clean"]
    subprocess.run(args, stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
    args = ["make", "-j8", "default"]
    subprocess.run(args, stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)

def check_ok():
    ok = False
    try:
        with open("build/getting-started_flash.elf", "rb") as fi:
            data = fi.read()
            md5 = hashlib.md5(data).hexdigest()
            if md5 == "477426c8b501958cc5175e490b36c842":
                ok = True
    except:
        pass

    return ok

asfdir = "xdk-asf-3.32.0_essentials"

fullnames = []
for (dirpath, dirnames, filenames) in os.walk(asfdir):
    for filename in filenames:
        fullname = os.path.join(dirpath, filename)
        fullnames.append(fullname)

for (i, fullname) in enumerate(fullnames, 1):
    fullname2 = fullname + ".orig_test"
    os.rename(fullname, fullname2)
    rebuild()
    if check_ok():
        print(i, "removed non-essential file:", fullname)
        os.remove(fullname2)
    else:
        os.rename(fullname2, fullname)
        print(i, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ essential file found:", fullname)
