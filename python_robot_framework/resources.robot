*** Settings ***
Library           SeleniumLibrary
#Library           Selenium2Library
#Library           Screenshot
Library           SSHLibrary
Library           DateTime
Library           RequestsLibrary
Library           JSONLibrary
Library           Collections


*** Variables ***
${browser}      Chrome
${FLASK_CLOUD_URL}      http://flask-example:8080
${user_name}     admin@admin.com
${user_password}     1234
${selenium_grid_url}    http://selenium-service:4444/wd/hub
${PATH}         ${CURDIR}
*** Keywords ***
Open browser with URL
    [Arguments]    ${FLASK_CLOUD_URL}
    Open Browser    ${FLASK_CLOUD_URL}     ${browser}     remote_url=${selenium_grid_url}
API_auth
    ${data}=    Create dictionary   user_name=${user_name}  user_password=${user_password}
    ${response}=    POST  ${FLASK_CLOUD_URL}/api/v1/auth      json=${data}
    #${access_token}=    Get Value From Json    ${response.json()}
    Set Global Variable    ${FLASK_CLOUD_URL}



Open_Index_Page
    Open browser with URL    ${FLASK_CLOUD_URL}