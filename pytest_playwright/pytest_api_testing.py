import pytest, requests, json

base_url = "http://localhost:8080"


def test_api_list_reverse():
    api_url = base_url + "/api/v1/list_reverse"

    payload = json.dumps({
        "user_name": "admin",
        "user_password": "1234",
        "user_list": [1,2,3,4]
    })
    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", api_url, headers=headers, data=payload)
    get_json = response.json()
    print(get_json['result'])
    #response = requests.get(api_url)

    # Verify status code
    assert response.status_code == 200
    assert get_json['result'] == [4,3,2,1]

def test_api_list_comprehension():
    limit_list = 10
    api_url = base_url + "/api/v1/list_comprehension"
    payload = json.dumps({
        "user_name": "admin",
        "user_password": "1234",
        "user_limit": limit_list
    })
    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", api_url, headers=headers, data=payload)
    get_json = response.json()
    print(get_json['result'])
    assert response.status_code == 200

    def list_verify(limit_list):
        new_list = [i ** 2 for i in range(1, limit_list) if i * (i - 2) % 3 == 0]
        return new_list

    assert get_json['result'] == list_verify(limit_list)

@pytest.mark.parametrize("user_name, user_group", [
    ("admin_test@test.com", "admin")
])

def test_user_profile(user_name,user_group):
    api_url = base_url + "/api/v1/user_profile"
    payload = json.dumps({
        "user_name": "admin_test@test.com",
        "user_address": "1110-1111 eastwood street",
        "user_group": "admin"
    })
    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", api_url, headers=headers, data=payload)
    get_json = response.json()
    print(get_json,user_name,user_group)
    assert response.status_code == 200
    assert get_json['user_name'] == user_name
    assert get_json['user_group'] == user_group
