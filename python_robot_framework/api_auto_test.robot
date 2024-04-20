*** Settings ***
Resource    resources.robot

*** Test Cases ***
API_SESSION_INIT
    [Tags]      sanity
    API_auth
    ${flask_api_temp}=    Load Json From File        api_temp.json
    Set Global Variable     ${flask_api_temp}


/api/v1/list_reverse
    [Tags]     sanity
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
   # ${body}=    Update Value To Json        ${body}      $.user_list     [9,8,7,6,5,4,3,2,1]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}

/api/v1/list_comprehension
    [Tags]      cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}

/api/v1/fib
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}

/api/v1/bubble_sort
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}
/api/v1/quick_sort
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}

/api/v1/build_in_sort
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     $.'${TEST NAME}'
    ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/${TEST NAME}   json=${body}     verify=${False}
    Log     ${response.json()}

/api/v1/user_profile(check_username)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_name]
    ${test_data}    Set Variable    ${body}[0][user_name]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_name]
    Log    ${real_data}
    Should Be Equal As Strings    ${test_data}      ${real_data}

/api/v1/user_profile(check_username_failed_demo)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_name]
    ${test_data}    Set Variable    ${body}[0][user_name]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_name]
    Log    ${real_data}
    Should Not Be Equal As Strings    ${test_data}      ${real_data}

/api/v1/user_address(check_address)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_address]
    ${test_data}    Set Variable    ${body}[0][user_address]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_address]
    Log    ${real_data}
    Should Be Equal As Strings    ${test_data}      ${real_data}
/api/v1/user_address(check_address_failed_demo)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_address]
    ${test_data}    Set Variable    ${body}[0][user_address]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_address]
    Log    ${real_data}
    Should not Be Equal As Strings    ${test_data}      ${real_data}

/api/v1/user_group(check_group)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_group]
    ${test_data}    Set Variable    ${body}[0][user_group]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_group]
    Log    ${real_data}
    Should Be Equal As Strings    ${test_data}      ${real_data}

/api/v1/user_group(check_group_failed_demo)
    [Tags]     cloud
    ${body}=     Get Value From Json    ${flask_api_temp}     '/api/v1/user_profile'
    Log     ${body}[0][user_group]
    ${test_data}    Set Variable    ${body}[0][user_group]
   # ${body}     Set Variable    ${body}[0]
    ${response}=    POST    ${FAZ_CLOUD_URL}/api/v1/user_profile   json=${body}     verify=${False}
    Log     ${response.json()}
    ${real_data}    Set Variable     ${response.json()}[user_group]
    Log    ${real_data}
    Should not Be Equal As Strings    ${test_data}      ${real_data}
