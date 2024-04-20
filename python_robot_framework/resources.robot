*** Settings ***
Library           SeleniumLibrary
#Library           Selenium2Library
#Library           Screenshot
Library           SSHLibrary
Library           DateTime
Library           RequestsLibrary
Library           JSONLibrary


*** Variables ***
${browser}      gc
${FLASK_CLOUD_URL}          http://10.0.0.112:8000
${user_name}     admin@admin.com
${user_password}     1234

*** Keywords ***
Open browser with URL
    [Arguments]    ${FLASK_CLOUD_URL}
    Open Browser    ${FLASK_CLOUD_URL}  options=add_argument("--ignore-certificate-errors");add_argument("--no-sandbox")
API_auth
    ${data}=    Create dictionary   user_name=${user_name}  user_password=${user_password}
    ${response}=    POST  ${FLASK_CLOUD_URL}/api/v1/auth      json=${data}
    #${access_token}=    Get Value From Json    ${response.json()}
    Set Global Variable    ${FLASK_CLOUD_URL}



Open_Index_Page
    Open browser with URL    ${FLASK_CLOUD_URL}