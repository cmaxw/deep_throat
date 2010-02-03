require 'net/http'

module DeepThroat
  def self.root_url(path)
    res = call_url(path)
    case res.class.to_s
    when "Net::HTTPMovedPermanently"
      return root_url(res.header["Location"])
    when "Net::HTTPFound"
      return root_url(res.header["Location"])
    else
      return path
    end
  end
  
  def self.successful_url(path)
    call_url(root_url(path)).class.to_s == "Net::HTTPOK"
  end
  
  def self.call_url(path)
    url = URI.parse(path)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }    
  end
end