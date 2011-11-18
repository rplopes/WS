require 'rss'
require 'rexml/document'
require 'open-uri'

class FetcherController < ApplicationController
  
  def test_movies
    @titles = []
    
    doc = REXML::Document.new File.new('data/movies.xml')
    doc.elements.each("movies/movie") do |movie|
      @titles << movie.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched movies (#{@titles.length})"
    render "home/latest_news"
  end
  
  def test_tvshows
    @titles = []
    
    doc = REXML::Document.new File.new('data/tvshows.xml')
    doc.elements.each("tvshows/tvshow") do |tvshow|
      @titles << tvshow.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched TV shows (#{@titles.length})"
    render "home/latest_news"
  end
  
  def test_directors
    @titles = []
    
    doc = REXML::Document.new File.new('data/directors.xml')
    doc.elements.each("directors/director") do |director|
      @titles << director.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched directors (#{@titles.length})"
    render "home/latest_news"
  end
  
  def test_creators
    @titles = []
    
    doc = REXML::Document.new File.new('data/creators.xml')
    doc.elements.each("creators/creator") do |creator|
      @titles << creator.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched creators (#{@titles.length})"
    render "home/latest_news"
  end
  
  def test_actors
    @titles = []
    
    doc = REXML::Document.new File.new('data/actors.xml')
    doc.elements.each("actors/actor") do |actor|
      @titles << actor.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched actors (#{@titles.length})"
    render "home/latest_news"
  end
  
  def test_genres
    @titles = []
    
    doc = REXML::Document.new File.new('data/genres.xml')
    doc.elements.each("genres/genre") do |genre|
      @titles << genre.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched genres (#{@titles.length})"
    render "home/latest_news"
  end
  
end
