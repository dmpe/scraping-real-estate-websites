#!/usr/bin/python3
import requests
import json
import sys
import pandas as pd
import time
import random
from sqlalchemy import *
import sqlalchemy
import sqlalchemy.schema
import io
from IPython.display import *
from pandas.io.json import *
from sqlalchemy.types import *

#https://stackoverflow.com/questions/24518944/try-except-when-using-python-requests-module
url_req = "https://www.sreality.cz/api/cs/v2/estates"

referer = {'prodej_domy': 'https://www.sreality.cz/hledani/prodej/domy/praha', 
           'pronajem_domy': 'https://www.sreality.cz/hledani/pronajem/domy/praha'}

houses_room_size = ["1-pokoj", "2-pokoje", "3-pokoje", "4-pokoje", "5-a-vice", "atypicky"]


def number_of_listings_to_download():
    #print(sys.argv[1] + " real estates are requested to be downloaded")
    return(sys.argv[1])

def rent_or_buy():
    #print(sys.argv[2] + " houses are requested")
    
    if(sys.argv[2] == "buy"):
        num = 1
        ref = referer['prodej_domy']
    else: # rent
        num = 2
        ref = referer['pronajem_domy']
    #print(num)
    
    return(num, ref)

def generateTimeEpoch():
    return(int(time.time()))

def create_single_header_params(roomCount):
    """
    Creates request headers
    """
    id_number_rent_buy, url_ref = rent_or_buy()
    
    if(roomCount == 1):
        velikost_pokoju = houses_room_size[0]
    elif(roomCount == 2):
        velikost_pokoju = houses_room_size[1]
    elif(roomCount == 3):
        velikost_pokoju = houses_room_size[2]
    elif(roomCount == 4):
        velikost_pokoju = houses_room_size[3]
    elif(roomCount == 5):
        velikost_pokoju = houses_room_size[4]
    else: #6 = atypicky
        velikost_pokoju = houses_room_size[5]
    
    #print(velikost_pokoju)
    
    req_headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:56.0) Gecko/20100101 Firefox/56.0',
    'X-Requested-With': 'XMLHttpRequest',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept': 'application/json, text/plain, */*',
    'Host': 'www.sreality.cz',
    'Cookie': 'lastsrch="{\"category_main_cb\": \"2\"\054 \"per_page\": \"60\"\054 \"tms\": \"' + str(generateTimeEpoch()) + '\"\054 \"locality_region_id\": \"10\"\054 \"category_type_cb\": \"' + str(id_number_rent_buy) + '\"}"',
    'Referer': str(url_ref)+"?velikost="+ velikost_pokoju
    }
    #print(req_headers)
    return(req_headers)

def store_and_returnHashIDs(roomCount, per_page = 60, page = number_of_listings_to_download()):
    """
    Used just for retrieving hash_id of each real estate
    https://stackoverflow.com/a/4504677
    """
    #print(roomCount)
    listOfhashIDs = []
    id_number_rent_buy, url_ref = rent_or_buy()
    #print(id_number_rent_buy, url_ref)
    #print(type(page), page)


    for i in range(1,int(page)+1):
        params = {
            'category_main_cb': '2', # houses
            'category_type_cb': str(id_number_rent_buy), # buy or to rent (which is 2)
            'room_count_cb': str(roomCount),
            'locality_region_id': '10',
            'per_page': str(per_page),
            'page': str(i),
            'tms': generateTimeEpoch()
        }
        print(params)
        response = requests.get(url_req, params=params, headers=create_single_header_params(roomCount))
        
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            # Whoops it wasn't a 200
            return "Error: " + str(e) 
        
        listObjects = response.json()
        #with open('data.txt', 'w') as f:
        #    json.dump(listObjects['_embedded']["estates"], f, ensure_ascii=False)
        for estates in listObjects['_embedded']["estates"]:
            listOfhashIDs.extend([(estates['hash_id'])])

    with open('hash_ids.txt', 'w') as f:
        json.dump(listOfhashIDs, f, ensure_ascii=False)

    return(listOfhashIDs)

def generate_listing_URLs(roomCount):
    """
    Combines URLs that can be used for "real" requests and place_id (the hash value of each estate)
    """
    urls = list()
    #print(roomCount)
    hsid_dict = store_and_returnHashIDs(roomCount = roomCount)

    for place_id in hsid_dict:
        place_url = url_req + "/" + str(place_id)
        urls.extend([(place_id, place_url)])
    #print(urls)

    return(urls)
    
def buy_rent_individual_houses_DF(roomCount):
    """
    Retrievies House's description, name, price and other information.
    https://stackoverflow.com/a/35387129
    """
    #print(roomCount)
    urls_list = generate_listing_URLs(roomCount = roomCount)
    list_meta = list()    
    time_snapshot = generateTimeEpoch()

    req_params = {
        'tms': time_snapshot
    }

    for ids, house_number_url in urls_list:

        random_number_forSQL_table = random.randint(0,999999999999999)

        response = requests.get(house_number_url, params = req_params, headers = create_single_header_params(roomCount))
        
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            # Whoops it wasn't a 200
            return "Error: " + str(e) 
        
        print("we are here processing: -> " + str(house_number_url))

        house_ind = response.json()
        # for individuals
        seller_indv_Phone_Type, seller_indv_Phone_Number, seller_indv_email = None, None, None
        # for agencies
        seller_agn_Phone_Type, seller_agn_Phone_Number = None, None
        seller_agn_Phone_Type2, seller_agn_Phone_Number2 = None, None

        description_items_price_info_value = None
        description_items_old_price_info_value = None
        description_items_price_info_more_value = None


        description_items_building = description_items_building_state= description_items_building_type = description_items_size= description_items_living_area = description_items_land_area=description_items_garden_area= description_items_garage= description_items_energy_efficiency_rating = description_items_elevator = description_items_cellar = description_items_build_area=description_items_swimming_pool= description_items_movein_date = description_items_house_place = description_items_furniture = description_items_parking = description_items_year_final_inspection = description_items_year_reconstruction = description_items_barrier = description_items_ownership = None

        description_items = house_ind['items']
        #description = house_ind['text']['name']
        description_value = house_ind['text']['value']

        #name = house_ind['name']['name']
        name_value = house_ind['name']['value']

        #address = house_ind['locality']['name']
        address_value = house_ind['locality']['value']
        address_lat = house_ind['map']['lat']
        address_lon = house_ind['map']['lon']

        if("seller" not in house_ind['_embedded']):
            if house_ind['contact']['phones']:
                # individuals
                seller_indv_phone = house_ind['contact']['phones']
                seller_indv_Phone_Type = seller_indv_phone[0]['type']
                seller_indv_Phone_Number = str(seller_indv_phone[0]['code'] + seller_indv_phone[0]['number'])
                if house_ind['contact']['email']:
                    seller_indv_email = house_ind['contact']['email']
            else:
                print("empty ind. phone contact details")
        else:
            # real estate agencies
            seller_agn_seller = house_ind['_embedded']['seller']
            seller_agn_seller_phone = seller_agn_seller['phones']
            seller_agn_seller_company = seller_agn_seller['_embedded']['premise']
            seller_agn_ID = seller_agn_seller['user_id']

            seller_agn_company_name = seller_agn_seller_company['name']
            seller_agn_company_ico = seller_agn_seller_company['ico']
            seller_agn_company_url = seller_agn_seller_company['www_visible']

            if(len(seller_agn_seller_phone) == 2):
                seller_agn_Phone_Type2 = seller_agn_seller_phone[1]['type']
                seller_agn_Phone_Number2 = str(seller_agn_seller_phone[1]['code'] + seller_agn_seller_phone[1]['number'])
            else:
                seller_agn_Phone_Type = seller_agn_seller_phone[0]['type']
                seller_agn_Phone_Number = str(seller_agn_seller_phone[0]['code'] + seller_agn_seller_phone[0]['number'])


        for item in description_items:
            # old price
            if(item['name'] == 'P\u016fvodn\u00ed cena'):
                description_items_old_price_info_value = item['value']
            # new price
            if(item['name'] == 'Cena' or item['name'] == "Zlevn\u011bno" or item['name'] == "Celkov\u00e1 cena"):
                description_items_price_info_value = item['value']
            if(item['name'] == 'Pozn\u00e1mka k cen\u011b'):
                description_items_price_info_more_value = item['value']
            if(item['name'] == 'Stavba'):
                description_items_building = item['value']
            if(item['name'] == 'Stav objektu'):
                description_items_building_state = item['value']
            if(item['name'] == 'Typ domu'):
                description_items_building_type = item['value']
            if(item['name'] == 'Podla\u017e\u00ed'):
                description_items_size = item['value']
            if(item['name'] == 'U\u017eitn\u00e1 plocha'):
                description_items_living_area = item['value']
            if(item['name'] == 'Plocha pozemku'):
                description_items_land_area = item['value']
            if(item['name'] == 'Plocha zahrady'):
                description_items_garden_area = item['value']
            if(item['name'] == 'Plocha zastav\u011bn\u00e1'):
                description_items_build_area = item['value']
            if(item['name'] == 'Gar\u00e1\u017e'):
                description_items_garage = item['value']
            if(item['name'] == 'Energetick\u00e1 n\u00e1ro\u010dnost budovy'):
                description_items_energy_efficiency_rating = item['value']
            if(item['name'] == 'Baz\u00e9n'):
                description_items_swimming_pool = item['value']
            if(item['name'] == 'Sklep'):
                description_items_cellar = item['value']
            if(item['name'] == 'V\u00fdtah'):   
                description_items_elevator = item['value']
            if(item['name'] == 'Datum nast\u011bhov\u00e1n\u00ed'):   
                description_items_movein_date = item['value']  
            if(item['name'] == 'Poloha domu'):   
                description_items_house_place = item['value']   
            if(item['name'] == 'Vybaven\u00ed'):   
                description_items_furniture = item['value']  
            if(item['name'] == 'Parkov\u00e1n\u00ed'):
                description_items_parking = item['value']
            if(item['name'] == 'Rok kolaudace'):   
                description_items_year_final_inspection = item['value']  
            if(item['name'] == 'Rok rekonstrukce'):
                description_items_year_reconstruction = item['value']
            if(item['name'] == 'Bezbari\u00e9rov\u00fd'):
                description_items_barrier = item['value']
            if(item['name'] == 'Vlastnictv\u00ed'):
                description_items_ownership = item['value']               
                
        descriptionRows = [(random_number_forSQL_table, time_snapshot, ids, house_number_url, name_value, description_value,
                        address_value, address_lat, address_lon, seller_indv_Phone_Type, seller_indv_Phone_Number, seller_indv_email,
                        seller_agn_Phone_Type, seller_agn_Phone_Number, seller_agn_Phone_Type2, seller_agn_Phone_Number2,
                       seller_agn_company_name, seller_agn_company_ico, seller_agn_company_url,
                       description_items_old_price_info_value, description_items_price_info_value,
                        description_items_price_info_more_value, description_items_building, description_items_building_state,
                           description_items_building_type, description_items_size, description_items_living_area,
                           description_items_land_area, description_items_garden_area, description_items_build_area,
                            description_items_garage, description_items_energy_efficiency_rating, description_items_swimming_pool,
                           description_items_cellar, description_items_elevator, description_items_movein_date, 
                           description_items_house_place, description_items_furniture, description_items_parking, 
                           description_items_year_final_inspection, description_items_year_reconstruction, description_items_barrier,
                           description_items_ownership)]

        labels = ["random_id_num", "time_Snapshot", "estate_ID", "URL", "name", "description", "address", "address_lat",
                  "address_lon","seller_indv_Phone_Type", "seller_indv_Phone_Number", "seller_indv_Email", "seller_agn_Phone_Type",
                  "seller_agn_Phone_Number","seller_agn_Phone_Type2", "seller_agn_Phone_Number2", "seller_agn_company_name",
                  "seller_agn_company_ico", "seller_agn_company_url", "old_price", "current_price", "price_description",
                 "building", "property_status", "building_type", "size", "living_area", "land_area", "garden_area",
                  "build_area", "garage","energy_efficiency_rating", "swimming_pool", "cellar", "elevator", "move_InDate",
                  "house_Place", "equipment", "parking", "year_finalInspection", "year_reconstruction", "non_barrier", "ownership"]

        list_meta.extend(descriptionRows)

    df = pd.DataFrame.from_records(list_meta, columns = labels)
    df.to_csv("/home/jm/Documents/master_new_repo/code_data/scraping_data/houses_ind_buy_and_rent.csv", mode='a')
    print("Done with all")

    return(df)


def store_in_mariaDB(room_count_type = range(1,7)):
    """
    Store data in database
    http://localhost/phpmyadmin/
    https://stackoverflow.com/a/31741136
    https://stackoverflow.com/a/34384664
    """
    engine = create_engine('mysql+pymysql://root:@localhost/sreality_cz?charset=utf8mb4', encoding='utf8', echo = False)
    
    for i in room_count_type:
        #print(i)
        ind_houses = buy_rent_individual_houses_DF(roomCount = i)
        if(sys.argv[2] == "buy"):
            ind_houses.to_sql('individual_houses_toBuy_roomSize_'+str(i), engine, if_exists='append', 
                          dtype={'swimming_pool': sqlalchemy.types.Text, 'elevator': sqlalchemy.types.Text, 
                                'equipment': sqlalchemy.types.Text, 'parking': sqlalchemy.types.Text, 
                                 'cellar': sqlalchemy.types.Text, 'garage': sqlalchemy.types.Text,
                                 'non_barrier': sqlalchemy.types.Text, 'random_id_num': sqlalchemy.types.Text, 
                                 'estate_ID': sqlalchemy.types.Text})
        else:
            ind_houses.to_sql('individual_houses_toRent_roomSize_'+str(i), engine, if_exists='append', 
                          dtype={'swimming_pool': sqlalchemy.types.Text, 'elevator': sqlalchemy.types.Text,
                                'equipment': sqlalchemy.types.Text, 'parking': sqlalchemy.types.Text,
                                'cellar': sqlalchemy.types.Text, 'garage': sqlalchemy.types.Text,
                                'non_barrier': sqlalchemy.types.Text, 'random_id_num': sqlalchemy.types.Text, 
                                 'estate_ID': sqlalchemy.types.Text})
    
    return("all datasets written to database")
    

def main():
    #print(generate_listing_URLs())
    #print(store_and_returnHashIDs(roomCount = 5))
    #print(
    #buy_individual_houses_DF()
    print(store_in_mariaDB())
    #print(generateTimeEpoch())

if __name__ == "__main__":
    print("Downloading " + sys.argv[1] + " pages of each having 60 real-estate listings")
    print("Rent or buy? Which are choosen? Housing: --> " + sys.argv[2])
    print("   ")
    main()
