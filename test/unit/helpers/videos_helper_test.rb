require 'test_helper'

class VideosHelperTest < ActionView::TestCase
  include VideosHelper

  test "#full_date" do
    assert_match /^\w+\s+\d{1,2} \d{4}, \d{1,2}:\d{1,2} \w{2} [A-Z0-9:+]+$/, full_date(Date.today)
  end

  test "#created_date" do
    date = Date.today - 3
    assert_equal time_ago_in_words(date) + ' ago', created_date(date)

    date = Date.today - 5
    output = created_date(date)
    assert_not output.include? 'ago'
    assert_match /\w+\s+\d+/, output
  end

  test "#equivalent_urls" do
    assert_not equivalent_urls(nil, nil)
    assert equivalent_urls('blah', 'blah')
    assert equivalent_urls('http://www.google.com/', 'http://www.google.com/')
    assert equivalent_urls('https://www.vimeo.com/same', 'http://www.vimeo.com/same')
  end

  test "#source_url" do
    assert_equal 'google.com', source_url('https://www.google.com')
    assert_equal 'no...', source_url('http://www.nooooooooooooooo.com/', 5)
  end
end
