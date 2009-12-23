require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/../../lib/deep_throat"

describe DeepThroat do
  it "finds the root url of a redirected link" do
    flexmock(DeepThroat).should_receive(:call_url).with("http://example.org/").and_return(flexmock(:redirect, :class => Net::HTTPFound, :header => {"Location" => "http://example.org/abc"}))
    flexmock(DeepThroat).should_receive(:call_url).with("http://example.org/abc").and_return(flexmock(:redirect, :class => Net::HTTPMovedPermanently, :header => {"Location" => "http://example.org/index.html"}))
    flexmock(DeepThroat).should_receive(:call_url).with("http://example.org/index.html").and_return(flexmock(:redirect2, :class => Net::HTTPOK))

    DeepThroat.root_url("http://example.org/").should == "http://example.org/index.html"
  end
  
  it "calls out to the url provided" do
    powerhouse = flexmock("net-http", :class => "PowerHouse")
    flexmock(Net::HTTP).new_instances do |instance|
      instance.should_receive(:request).and_return(powerhouse)
    end

    DeepThroat.call_url("http://example.org/").should == powerhouse
  end
  
  it "returns false if the response is not success" do
    powerhouse = flexmock("net-http", :class => "PowerHouse")
    flexmock(DeepThroat, :call_url => powerhouse)

    DeepThroat.successful_url("http://example.org/").should_not be_true 
  end
  
  it "returns true if the response is a success" do
    powerhouse = flexmock("net-http", :class => Net::HTTPOK)
    flexmock(DeepThroat, :call_url => powerhouse)

    DeepThroat.successful_url("http://example.org/").should be_true 
  end
end