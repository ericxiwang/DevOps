*** Settings ***
#Library           SeleniumLibrary
#Library           Screenshot
Library           SSHLibrary
Library           DateTime
Library           RequestsLibrary
Library           JSONLibrary

*** Variables ***
${browser}      gc
${FAZ_CLOUD_URL}          http://10.0.0.112:8000
${user_name}     admin@admin.com
${user_password}     1234

*** Keywords ***

API_auth
    ${data}=    Create dictionary   user_name=${user_name}  user_password=${user_password}
    ${response}=    POST  ${FAZ_CLOUD_URL}/api/v1/auth      json=${data}
    #${access_token}=    Get Value From Json    ${response.json()}
    Set Global Variable    ${FAZ_CLOUD_URL}



