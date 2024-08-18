*** Test Cases ***
Login to index
    Sleep   1s
    Open_Index_Page
    Sleep   2s
    Set Window Size     1920    1080
    Input Text          //*[@id="user_name"]        ${user_name}
    Input Password      //*[@id="user_password"]       ${user_password}
    Click Element    //*[@id="login"]
    Capture Page Screenshot

selenium_locator_traversing
    