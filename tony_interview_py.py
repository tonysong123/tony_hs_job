# -*- coding: utf-8 -*-
# -------------------------------------------------
#   @Author :       Tony Song
#   @Time   :       2023/7/2 20:51
#   @File   :       tony_interview_py.py
#   @Software :     PyCharm
#   @Desc :
# -------------------------------------------------

from os import path
import re
from collections import Counter
import requests
import json

base_dir = path.dirname(path.dirname(path.abspath(__file__)))
logFiles = base_dir + "\logs\interview_data_set"

reg = "(^\S+)\s(\S+)\s(\S+)\s(\S+)\s(.*?)\:(.*)"
reg2 = "(\S+)\[([\d+])\].*"

i = 0
dt_list = []
with open(logFiles, 'r+') as f:
    logs = f.readlines()
    for log in logs:
        i += 1
        process = ""
        dt_res = re.findall(reg, log)
        if(dt_res):
            month,day,hms,deviceName,process,description = dt_res[0]
            hour = hms.split(":")[0]

            exist_process = re.findall(reg2, process)
            if(exist_process):
                processName, processId = exist_process[0]

            startHour = "{}00".format(str(int(hour)).zfill(2))
            endHour = "{}00".format((str(int(hour)+1)).zfill(2))
            timeWindow = "{}-{}".format(startHour, endHour)
            # print(i, deviceName, processId, processName, description, timeWindow)

            dt_list.append((deviceName, processId, processName, description, timeWindow))

            # if i>5:
            #     break
        else:
            print(log)


print("Total:",len(dt_list))
counter = Counter(dt_list)
dt_list_res = []
key_list = ["deviceName", "processId", "processName", "description", "timeWindow", "numberOfOccurrence"]
dt_dict = {}
for key, count in counter.items():
    deviceName, processId, processName, description, timeWindow = key
    numberOfOccurrence = count
    # print(deviceName, processId, processName, description, timeWindow, numberOfOccurrence)
    dt_dict = dict(zip(key_list,(deviceName, processId, processName, description, timeWindow, numberOfOccurrence)))
    dt_list_res.append(dt_dict)

print(dt_list_res)

# 上传数据，网络不通，未验证POST数据功能
headers = {
    "Content-Type": 'application/json'
}
url = "https://foo.com/bar"
req = requests.post(url=url, headers=headers, json=dt_list_res)

if req.text:
    print(req.text)
    req_json = json.loads(req.text)
    print(req_json)

    code = req_json.get("code", "")
    msg = req_json.get("msg", "")
else:
    print("Post error")
