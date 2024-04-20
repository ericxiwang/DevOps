*** Settings ***
Resource          resources.robot
Default Tags      FAZ_smoke

*** Test Cases ***
FAZ_DVM_enter
    Login to index
    Click Element    //*[contains(text(), 'Device Manager')]

FAZ_DVM_device_info
    Get Window Handles
    Wait Until Element Is Visible    css:div[attr-index-in-display-src='0']    50
    Sleep    3s
    ${FGT_online}    Get Element Count   css:i.color-green.ffg-dot-round
    ${FGT_offline}    Get Element Count     css:i.color-red.ffg-dot-round

FAZ_DVM_edit
    #Click Element    //*[@id="dvm-device-table"]/div[2]/div/div[1]
    Click Element    css:div[attr-index-in-display-src='0']
    Sleep    2s
    Click Element    css:button[automation-id='Edit']
    Sleep    2s
    Click Element    css:textarea
    Clear Element Text    css:textarea
    Press Keys    css:textarea    FGT-test
    Click Element    //button[text()='OK']

FAZ_DVM_quit
    Back to index
    Sleep   2s
    Close Browser