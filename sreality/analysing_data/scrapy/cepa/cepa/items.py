# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class CepaItem(scrapy.Item):
# to pass to df pandas
    esti_price_sq_meter = scrapy.Field()
    lon = scrapy.Field()
    lat = scrapy.Field()
    url = scrapy.Field()
    estate_ID = scrapy.Field()
