require "net/http"
require "uri"
require "json"

class AnimeData
  class NoDataError < StandardError; end

  @@date = Time.now

  def getCour month
    case month
    when 1..3
      return 1
    when 4..6
      return 2
    when 7..9
      return 3
    when 10..12
      return 4
    end
  end

  def getAnimeData year,cour
    api = "http://api.moemoe.tokyo/anime/v1/master/#{year}/#{cour}"

    res = Net::HTTP.get(URI.parse(api))

    json = JSON.parse(res)
    res = ""
    json.each { |e|
      res << e["title"]+"\n"
    }

    raise NoDataError if json.size <= 0
    return res
  end

  def now
    getAnimeData(@@date.year,getCour(@@date.month))
  end

  def before
    year = @@date.year
    cour = getCour(@@date.month)

    if cour - 1 < 1
      cour = 4
      year -= 1
    else
      cour -= 1
    end

    getAnimeData year,cour
  end

  def next
    year = @@date.year
    cour = getCour(@@date.month)

    if cour + 1 > 4
      cour = 1
      year += 1
    else
      cour += 1
    end

    getAnimeData year,cour
  end
end
