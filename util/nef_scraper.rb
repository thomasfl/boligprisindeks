# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'sequel'
require 'pg'

#
# Screenscraper for boligprishistorikk fra nef.no
#
# Bruk:
#
#  DATABASE_URL = ENV['DATABASE_URL']
#  nef_scraper = NefScraper.new(DATABASE_URL)
#  nef_scraper.scrape_price_data()

class NefScraper

  def initialize(database_url)
    @DB = Sequel.connect(database_url)
  end

  def scrape_areas
    areas = {}
    doc = Nokogiri::HTML(open('http://www.nef.no/xp/pub/topp/boligprisstatistikk'))
    doc.css('input[type=checkbox]').each do |checkbox|
      id_tag = checkbox.attr('id')
      if(id_tag[/^id_area.*/])
        area_id = checkbox.attr('value')
        area_name = checkbox.next_sibling.text.strip
        areas[area_id] = area_name
      end
    end
    return areas
  end

  def query_rest_service(housing_type, area_id)
    pricing_data = []
    rest_url = "http://www.nef.no/db/boligpriser/" +
      "data/?from=&to=&housing=#{housing_type}&areas=#{area_id}"
    data = JSON.parse(open(rest_url,'r').read)
    if(data['data'].size > 0)
      data['data'][0]['data'].each do |dataentry|
        start_datetime = Time.at(dataentry[0]/1000)
        m2_price_nok = dataentry[1]
        pricing_data.push({start_datetime => m2_price_nok})
      end
    end
    return pricing_data
  end

  def scrape_price_data
    areas = scrape_areas
    housing_types = {1 => 'Alle', 2 => 'Enebolig', 3 => 'Delt+bolig', 4 => 'Leilighet'}
    store_areas(areas)
    store_housing_types(housing_types)
    areas.each do |area_id, area_name|
      housing_types.each do |housing_type_id, housing_type_name|
        print "#{area_name}(#{area_id.to_s}): #{housing_type_name}(#{housing_type_id.to_s}) : "
        historic_prices = query_rest_service(housing_type_name, area_id)
        puts "#{historic_prices.size.to_s} rader funnet"
        store_historic_prices(historic_prices, housing_type_id, area_id)
      end
    end
  end

  ## Database methods

  def store_areas(areas)
    bolig_omrader = @DB[:bolig_omrade]
    areas.each do |area_id, area_name|
      if(!bolig_omrader.first(:bolig_omrade_id => area_id))
        bolig_omrader.insert(:bolig_omrade_id => area_id, :bolig_omrade_navn => area_name)
      end
    end
  end

  def store_housing_types(housing_types)
    bolig_type = @DB[:bolig_type]
    housing_types.each do |type_id, type_name|
      if(!bolig_type.first(:bolig_type_id => type_id))
        bolig_type.insert(:bolig_type_id => type_id, :bolig_type_navn => type_name.gsub('+',' ') )
      end
    end
  end

  def store_historic_prices(historic_prices, housing_type_id, area_id)
    perioder = @DB[:periode]
    historikk = @DB[:boligpris_historikk]
    historic_prices.each do |data_entry|
      start_date = data_entry.keys.first
      m2_price_nok = data_entry.values.first
      if(m2_price_nok != nil)
        result = perioder.first(:periode_start => start_date)
        if(!result)
          periode_id = perioder.insert(:periode_start => start_date)
        else
          periode_id = result[:periode_id]
        end
        if(!historikk.first(:bolig_type_id => housing_type_id,
                         :bolig_omrade_id => area_id,
                         :periode_id => periode_id,
                         :m2_pris => m2_price_nok))

          historikk.insert(:bolig_type_id => housing_type_id,
                           :bolig_omrade_id => area_id,
                           :periode_id => periode_id,
                           :m2_pris => m2_price_nok)
        end
      end
    end
  end

end
