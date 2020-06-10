#!/usr/bin/env python

# Copyright 2019 Hotspring Ventures Ltd.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import sys
import shutil
import subprocess

DEVICE_ID = sys.argv[1]
LIBRARY_DIR = sys.argv[2]
APP_ID = sys.argv[3]
print('Device id:', DEVICE_ID)
print('Library dir:', LIBRARY_DIR)
print('App ID:', APP_ID)
CACHES_DIR = LIBRARY_DIR + "/Developer/CoreSimulator/Devices/" + DEVICE_ID + "/data/Library/Caches/ApiStubs/" + APP_ID + "/"
print('CACHES_DIR:', CACHES_DIR)
LOCAL_CACHE_DIR = os.environ['PROJECT_DIR'] + "/" + os.environ['TARGET_NAME'] + "/ApiStubs/"
print('LOCAL_CACHE_DIR:', LOCAL_CACHE_DIR)

DIRECTORY_EXISTS = os.path.isdir(CACHES_DIR)
if os.path.isdir(LOCAL_CACHE_DIR):
    print('Using local cached API stubs')
    if DIRECTORY_EXISTS:
        print('Found device caches directory, removing it...')
        shutil.rmtree(CACHES_DIR)
    print('Copying local cache to device')
    shutil.copytree(LOCAL_CACHE_DIR, CACHES_DIR)
    exit(0)
