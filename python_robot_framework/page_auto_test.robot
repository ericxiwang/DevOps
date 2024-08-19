*** Settings ***
Resource        resources.robot
Default Tags    FAZ_smoke
Test Teardown   Logout_teardown
*** Keywords ***
Logout_teardown
    Run Keyword And Ignore Error    Element Should Contain      xpath://html/body/nav/div/ul/li[1]/a        HOME
    Run Keyword And Ignore Error    Element Should Contain      xpath://html/body/nav/div/ul/li[2]/a        TABLE
    Run Keyword And Ignore Error    Element Should Contain      xpath://html/body/nav/div/ul/li[3]/a        NEW ALBUM
    Run Keyword And Ignore Error    Element Should Contain      xpath://html/body/nav/div/ul/li[4]/a        UPLOAD
    Run Keyword And Ignore Error    Element Should Contain      xpath://html/body/nav/div/ul/li[5]/a        LOGOUT

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
    Sleep    1s
    Capture Page Screenshot
Check_datagrid_table_count
    ${rows}     Get Element Count   //table[@class="table table-dark table-bordered"]/tbody/tr
    ${sum_pics}     Set Variable        0
    FOR    ${each_last_col}         IN RANGE          2     ${rows} + 2
        ${table_cell} =   Get Table Cell   xpath://html/body/div/div/div[2]/div/table   ${each_last_col}        4
        ${sum_pics}     Set Variable     ${${table_cell} + ${sum_pics}}
    END
    Should Be True      ${sum_pics} == 12
    Sleep    1s

Check_datagrid_album_count
    ${rows}     Get Element Count   //table[@class="table table-dark table-bordered"]/tbody/tr
    ${list_album_name}     Create List
    FOR    ${each_last_col}         IN RANGE          2     ${rows} + 2
        ${table_cell} =   Get Table Cell   xpath://html/body/div/div/div[2]/div/table   ${each_last_col}        2
        Append To List      ${list_album_name}      ${table_cell}
    END
    Log    ${list_album_name}
    ${list_len}     Get Length    ${list_album_name}
    Should Be Equal As Numbers          ${list_len}             5
    Sleep    1s



Check_new_album_page
    Click Element       xpath://html/body/nav/div/ul/li[3]/a
    ${current_size_album}   Get Element Count       //input[@name="album_name_list"]
    Log    ${current_size_album}
    Input Text          //*[@name="album_name"]        TEST_ALBUM
    Input Text          //*[@name="album_description"]        TEST_ALBUM_DESCRIPTION
    Click Element       //input[@value="upload"]
    ${new_size_album}   Get Element Count       //input[@name="album_name_list"]
    Set Global Variable     ${current_size_album}
    Set Global Variable     ${new_size_album}
    Sleep    1s
    Capture Page Screenshot

Check_numbers_albums_page
    Should Be True    ${new_size_album} < ${current_size_album}

Check_delete_album_page
    Click Element       //input[@value="TEST_ALBUM"]
    Click Element       //input[@value="delete" and @type="submit"]
    Sleep    1s
    Capture Page Screenshot

Check_upload_page
    Click Element       xpath://html/body/nav/div/ul/li[4]/a
    Capture Page Screenshot
Check_logout
    Element Should Contain      xpath://html/body/nav/div/ul/li[1]/a        HOME
    Element Should Contain      xpath://html/body/nav/div/ul/li[2]/a        TABLE
    Element Should Contain      xpath://html/body/nav/div/ul/li[3]/a        NEW ALBUM
    Element Should Contain      xpath://html/body/nav/div/ul/li[4]/a        UPLOAD
    Element Should Contain      xpath://html/body/nav/div/ul/li[5]/a        LOGOUT
    Click Element       xpath://html/body/nav/div/ul/li[5]/a
    Logout_teardown

Release_test_resource
    Close All Browsers