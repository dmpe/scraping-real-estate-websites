# -*- coding: utf-8 -*-
import scrapy
import os

class WgGesuchtDeSpider(scrapy.Spider):
    name = 'wg_gesucht.de'
    allowed_domains = ['wg-gesucht.de', 'https://www.wg-gesucht.de/wg-zimmer-in-Nuernberg.96.0.1.0.html']

    start_urls = ['https://www.wg-gesucht.de/wg-zimmer-in-Nuernberg.96.0.1.0.html']

    def parse(self, response):
        """Locates place advertisement
        https://stackoverflow.com/a/12176793
        https://stackoverflow.com/a/35289364
        https://stackoverflow.com/q/18480363
        """
        trans_table = {ord(c): None for c in u'\r\n'}

        locate_main_column = response.xpath('//*[@id ="main_column"]')

        extract_listings = locate_main_column.xpath('//div[contains(@id, "liste-details-ad-")]').extract_first()

        #print(extract_listings)
        print("Next page  ..........................")

        pagination_row_list = locate_main_column.xpath('//ul[@class="pagination pagination-sm"]')
        #print(pagination_row_list)

        numbers, urls = [], []

        for element in pagination_row_list:
            numbers.append([i.strip() for i in element.xpath('//li/a[@class = "a-pagination"]/text()').extract()])
            urls.append(element.xpath('//li/a[@class = "a-pagination"]/@href').extract())
            #print(urls)

        #os.remove("/home/jm/Documents/master_thesis_git_repo/code_data/wg_gesucht/wg_gesucht/data.json")

        yield {
            'URL': urls,
            'Number': numbers
        }

        for a in [element for element in pagination_row_list.xpath('//li/a[@class = "a-pagination"]/@href').extract()]:
            yield response.follow(a, callback=self.parse)



class WgGesuchtDeSpiderListingMetadata(scrapy.Spider):
    name = 'wg_gesucht.de'
    allowed_domains = ['wg-gesucht.de', 'https://www.wg-gesucht.de/wg-zimmer-in-Nuernberg.96.0.1.0.html']

    start_urls = ['https://www.wg-gesucht.de/wg-zimmer-in-Nuernberg.96.0.1.0.html']

    def parse_descriptionOfListings(arg):
        pass





process = CrawlerProcess()
process.crawl(MySpider1)
process.crawl(MySpider2)
process.start()
