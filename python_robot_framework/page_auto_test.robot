*** Settings ***
Resource          resources.robot
Default Tags      FAZ_smoke

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
Check_each_features_on_banner
    Element Should Contain      xpath://html/body/nav/div/ul/li[1]/a        HOME
    Element Should Contain      xpath://html/body/nav/div/ul/li[2]/a        TABLE
    Element Should Contain      xpath://html/body/nav/div/ul/li[3]/a        NEW ALBUM
    Element Should Contain      xpath://html/body/nav/div/ul/li[4]/a        UPLOAD
    Element Should Contain      xpath://html/body/nav/div/ul/li[5]/a        LOGOUT
    Sleep   1s
    Capture Page Screenshot
Check_each_Album_widget
    Click Element    //a[@id="Spain"]
    Element Should Contain      xpath://html/body/div/div/div[2]/div[1]      Spain
    Sleep   1s
    Capture Page Screenshot

Check_datagrid_table
    Click Element       xpath://html/body/nav/div/ul/li[2]/a
    Element Should Contain      xpath://html/body/div/div/div[2]/div/table        Spain

    Capture Page Screenshot

Check_new_album_page
    Click Element       xpath://html/body/nav/div/ul/li[3]/a
    Capture Page Screenshot

Check_upload_page
    Click Element       xpath://html/body/nav/div/ul/li[4]/a
    Capture Page Screenshot

Release_test_resource
    Close All Browsers