*** Settings ***
Resource          resources.robot
Default Tags      FAZ_smoke

*** Test Cases ***

Login to index
    Open_Index_Page
    Sleep   1s
    Set Window Size     1920    1080
    Input Text          xpath://html/body/div/div/div/form/div/div[1]/div/input        ${user_name}
    Input Password      xpath://html/body/div/div/div/form/div/div[2]/div/input        ${user_password}
    Click Element    xpath://html/body/div/div/div/form/div/div[3]/div/button

Check_each_features_on_banner
    Element Should Contain      xpath://html/body/nav/div/ul/li[1]/a        HOME
    Element Should Contain      xpath://html/body/nav/div/ul/li[2]/a        TABLE
    Element Should Contain      xpath://html/body/nav/div/ul/li[3]/a        UPLOAD
    Element Should Contain      xpath://html/body/nav/div/ul/li[4]/a        LOGOUT
    Sleep   1s
Check_each_Album_widget
    Element Should Contain      xpath://html/body/div/div/div/div[2]/div[1]        Spain
    Sleep   1s

Check_datagrid_table
    Click Element       xpath://html/body/nav/div/ul/li[2]/a
    Element Should Contain      xpath://html/body/div/div/div/div[2]/div/table        Spain