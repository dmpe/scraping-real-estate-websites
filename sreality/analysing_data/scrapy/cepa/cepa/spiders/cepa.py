import scrapy
import json
from scrapy.loader import ItemLoader
from cepa.items import CepaItem
import logging
import csv
import sys
import os
import pandas as pd
import numpy as np

headers = {
'Host': 'cenovamapa.eu',
'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0',
'Accept': 'application/json, text/javascript, */*; q=0.01',
'Accept-Language': 'en-US,en;q=0.5',
'Accept-Encoding': 'gzip, deflate',
'X-Requested-With': 'XMLHttpRequest',
'Referer': 'http://cenovamapa.eu/',
'Connection': 'keep-alive',
'Content-Type': 'application/json',
'Pragma': 'no-cache',
'Cache-Control': 'no-cache'
}
def writetoCSV(arg1, arg2, arg3, arg4, arg5):
    # prop_id, url, lat, lon, price_sq_meter
    fe = []
    fe.append([arg1, arg2, arg3, arg4, arg5])
    df = pd.DataFrame(fe)
    if(not os.path.exists("/home/jm/Documents/master_new_repo/code_data/analysing_data/R/CSVs/df.csv")):
        df.to_csv("/home/jm/Documents/master_new_repo/code_data/analysing_data/R/CSVs/df.csv", mode="a", sep=",", na_rep="NA",  index=False, header = ['prop_id', 'req_url', 'lat', 'lon', 'esti_price_sq_meter'])
    else:
        df.to_csv("/home/jm/Documents/master_new_repo/code_data/analysing_data/R/CSVs/df.csv", mode="a", sep=",", na_rep="NA",  index=False,header=False)

def extractInfo():
    with open('/home/jm/Documents/master_new_repo/code_data/analysing_data/R/CSVs/id_lot_lat.csv') as csvfile:
        readCSV = csv.DictReader(csvfile)
        str_beg = 'http://cenovamapa.eu/?do=getprice&p=('
        str_end = ')&zoom=12&t=byty-prodej' # <-------------- DONT FORGET TO CHANGE HERE AS WELL: byty-najem, byty-prodej, domy-prodej
        estateList, urls_list, lat_list, lon_list = [], [], [], []
        for row in readCSV:
            #print(row['estate_ID'], row['address_lat'], row['address_lon'])
            req_url = str_beg + row['address_lat'] + ', '+ row['address_lon'] + str_end
            estateList.append(row['estate_ID'])
            urls_list.append(req_url)
            lat_list.append(row['address_lat'])
            lon_list.append(row['address_lon'])
        #print(type(fg))
    return(estateList,urls_list, lat_list, lon_list)

class CepaSpider(scrapy.Spider):
    name = "cepa"

    def start_requests(self):
        estateList,urls_list, lat_list, lon_list = extractInfo()
        try:
            #print(estateList.pop())
            #print(urls_list.pop())
            #print(lat_list.pop() + " -___-"+ lon_list.pop())
            #http://cenovamapa.eu/?do=getprice&p=(50.08490381227852,%2014.367027282714844)&zoom=12&t=byty-najem
            estate_ID = estateList.pop()
            next_url = urls_list.pop()
            lat = lat_list.pop()
            lon = lon_list.pop()

        except IndexError as e:
            print(e)

        yield scrapy.Request(url=next_url,headers = headers, callback=self.parse, meta={'urls': urls_list, 'prop_id':estateList, 'lat':lat_list, 'lon': lon_list}, dont_filter = True)

    def parse(self, response):
        urls = response.meta['urls']
        prop_id = response.meta['prop_id']
        lat_meta = response.meta['lat']
        lon_meta = response.meta['lon']

        item = CepaItem()
        try:
            next_url = urls.pop()
            item["lat"] = lat_meta.pop()
            item["lon"] = lon_meta.pop()
            item["estate_ID"] = prop_id.pop()
            print(next_url)

            if "text/html".encode() in response.headers['content-type']:
                print("mame tu html")
                yield scrapy.Request(url=next_url,headers = headers, callback=self.parse, meta={'urls': urls, 'prop_id':prop_id, 'lat':lat_meta, 'lon': lon_meta}, dont_filter = True)
            else:
                jsonresponse = json.loads(response.body_as_unicode())
                item["esti_price_sq_meter"] = jsonresponse["price"][0]['cena']
                print(jsonresponse)
                print(item["esti_price_sq_meter"])
                writetoCSV(item["estate_ID"], next_url, item["lat"], item["lon"], item["esti_price_sq_meter"])
                yield scrapy.Request(url=next_url,headers = headers, callback=self.parse, meta={'urls': urls, 'prop_id':prop_id, 'lat':lat_meta, 'lon': lon_meta},dont_filter = True)

        except IndexError as e:
            print(e)
