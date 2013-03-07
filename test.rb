# demo code to automate two minor tasks on weddingwire.com motivated by
# https://groups.google.com/forum/?fromgroups=#!topic/watir-general/hxHtC0wGzXE
# code could use waits in more places to tackle non-determinism

require 'rubygems'
require 'watir'
require 'watir-webdriver'
require 'yaml'

class Tester
  def initialize()
    @browser = Watir::Browser.new :ff
  end

  def login
    @browser.goto("http://www.weddingwire.com/wedding/UserLogin")

    @browser.text_field(:name, "userName").set("redwedding123@gmail.com")
    @browser.text_field(:name, "password").set("gatsby321")

    @browser.send_keys :enter
  end

  def nav_tab(tab)
    @browser.goto("http://www.weddingwire.com/wedding/"+tab)
  end

  def nav_wwpage(option)
    @browser.link(:href, /#{option}/).click
  end

  def task_edit_site
    #watir not deterministic here
    sleep 1 until @browser.text_field(:name, "currentItem.name").exists?
    @browser.text_field(:name,"currentItem.name").set("Super Marvelous Wedding")
    @browser.execute_script("CKEDITOR.instances['currentItem.contentText'].setData( 'Welcome to the internet home for our wedding.');")
    @browser.button(:id, "user-website-edit-cancel").click
  end

  def slurp_themes
    theme_data = @browser.divs(:onmouseover, /javascript/)
    theme_numbers = []
    theme_data.each do |t|
      if (/(\d{4})/.match(t.html))
        theme_numbers << $1
      end
    end
    theme_numbers
  end

  def task_set_designer(n)
    tab_link = ""
    begin
      tab_link = @browser.links(:href, /ThemesView\?group/)[n]
    end until tab_link.exists?
    tab_link.click
 
    theme_numbers = []
    while theme_numbers.length == 0 do
      theme_numbers = slurp_themes
    end

    #select a random theme
    set_theme(theme_numbers.sample)
  end

  def set_theme(n)
    div = @browser.divs(:onmouseover, /#{n}/)[0]
    div.fire_event "onmouseover"
    @browser.execute_script("javascript:selectTheme(\'#{n}\')")
  end

  def test_run
    login
    nav_tab("UserMyWebsitePages")
    nav_wwpage("PageEdit")
    task_edit_site
    nav_tab("UserMyWebsiteThemes")
    task_set_designer(2)
  end
end

test = Tester.new
test.test_run
