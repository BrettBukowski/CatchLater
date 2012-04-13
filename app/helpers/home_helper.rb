module HomeHelper
  def bookmarklet
    'javascript:' + IO.read(File.expand_path('app/assets/javascripts/bookmarklet.min.js'))
  end
  
  def bookmarklet_instructions
    browser = request.user_agent.match(/Chrome|Firefox|Safari|Android|iPhone|iPad|MSIE/)
    if browser
      browser = browser[0].downcase
      raw send(:"#{browser}_instructions")
    end
  end
  
  def chrome_instructions
    <<-html
    To install the CatchLater button in Chrome:
    <ol id="chrome">
      <li>Display your Bookmarks bar by clicking <em>View > Show Bookmarks Bar</em></li>
      <li>Drag the CatchLater button up into your Bookmarks bar</li>
      <li>When you're on a website with videos click "CatchLater" to save a video for later viewing</li>
    </ol>
    html
  end
  
  def safari_instructions
    <<-html
    To install the CatchLater button in Safari:
    <ol id="safari">
      <li>Display your Bookmarks bar by clicking <em>Wrench icon > Bookmarks > Show Bookmarks Bar</em></li>
      <li>Drag the CatchLater button up into your Bookmarks bar</li>
      <li>When you're on a website with videos click "CatchLater" to save a video for later viewing</li>
    </ol>
    html
  end
  
  def firefox_instructions
    <<-html
    To install the CatchLater button in Firefox:
    <ol id="safari">
      <li>Display your Bookmarks bar by clicking <em>Wrench icon > Bookmarks > Show Bookmarks Bar</em></li>
      <li>Drag the CatchLater button up into your Bookmarks bar</li>
      <li>When you're on a website with videos click "CatchLater" to save a video for later viewing</li>
    </ol>
    html
  end
  
  def ios_instructions
    <<-html
    To install the CatchLater button in iOS:
    <ol id="safari">
      <li>First of all: I'm sorry. This is an unwieldy process in iOS.</li>
      <li>Bookmark this page right now.</li>
      <li>
        Next, copy these contents to the clipboard.
        <ol>
          <li>Tap inside the textbox. The keyboard will pop up.</li>
          <li>Tap and hold inside the textbox so that the magnifying glass appears. Release.</li>
          <li>You should see the pop-in menu. Choose <em>Select All</em> and then <em>Copy</em>
        </ol>
        <textarea>%s</textarea>
      </li>
      <li>Now, in Safari, tap the Bookmarks item to bring up your list of bookmarks</li>
      <li>Tap <em>Edit</em></li>
      <li>Select the CatchLater bookmark that you just added in Step 2.</li>
      <li>Tap the bookmark's URL and then hit the <em>x</em> to clear it out.</li>
      <li>Tap and hold inside the cleared-out space and select paste.</li>
      <li>Hit Done--You're now done!</li>
      <li>When you're on a website with videos tap the "CatchLater" bookmark to save a video for later viewing</li>
    </ol>
    html
  end
  alias :iphone_instructions :ios_instructions
  alias :ipad_instructions :ios_instructions
  
  def android_instructions
    
  end
  
  def msie_instructions
    <<-html
    To install the CatchLater button in Safari:
    <ol id="safari">
      <li>Display your Bookmarks bar by clicking <em>Wrench icon > Bookmarks > Show Bookmarks Bar</em></li>
      <li>Right-click the button and select <em>Add to Favorites...</em></li>
      <li>When you're on a website with videos click "CatchLater" to save a video for later viewing</li>
    </ol>
    html
  end
end
