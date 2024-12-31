from playwright.sync_api import expect, Page, sync_playwright
import pytest, re

URL = "http://localhost:8080"
playwright = sync_playwright().start()
browser = playwright.chromium.launch(headless=False)
context = browser.new_context()
page = context.new_page()
page.goto(URL)


def test_login():
    page.get_by_placeholder("input email").click()
    page.get_by_placeholder("input email").fill("admin@admin.com")
    page.get_by_placeholder("input email").press("Tab")
    page.get_by_placeholder("input password").fill("1234")
    page.get_by_role("button", name="Login").click()
    title = page.get_by_role("link", name="LOGOUT")


def test_index_page():
    all_album_list = ["Spain", "Canada", "Israel", "France", "China"]
    page.get_by_role("link", name="HOME").click()

    for each_album in all_album_list:
        page.get_by_text(str(each_album), exact=True).click()
    assert 2 == 2


def test_table_page():
    sum_of_pics = 12
    init_number = 0
    page.get_by_role("link", name="TABLE").click()
    #page.get_by_role("cell", name="Spain", exact=True).click()
    table_rows = page.locator('tbody').locator('tr').count()

    for each_row in range(int(table_rows)):

        init_number = init_number + int(page.locator('tbody').locator('tr').nth(each_row).locator('td').nth(3).text_content())

    assert init_number == sum_of_pics
@pytest.fixture()
def test_check_album():
    page.get_by_role("link", name="NEW ALBUM").click()
    album_list = ["Spain", "Canada", "Israel", "France", "China"]
    page_list = []
    get_current_list = page.locator("input.form-check-input")
    number_of_album = get_current_list.count()
    print(number_of_album)
    for list_item in range(int(number_of_album)):
        each_album = page.locator("input.form-check-input").nth(list_item).input_value()

        page_list.append(each_album)
    page_list.sort()
    print(page_list)
    album_list.sort()
    print(album_list)

    if page_list == album_list:
        album_check_passed = True
    else:
        album_check_passed = False
    return album_check_passed,page_list


def test_new_album(test_check_album):
    print("new",test_check_album)
    if test_check_album[0]:
        input_album_name = "test_album"
        input_album_desc = "test_album_desc"
        page.get_by_role("link", name="NEW ALBUM").click()
        #page.get_by_role("textbox", name="album_name").click()
        #page.get_by_role("textbox", name="album_name").fill("test_album")
        page.locator("input[name=album_name]").click()
        page.locator("input[name=album_name]").fill(input_album_name)
        page.locator("textarea[name=album_description]").click()
        page.locator("textarea[name=album_description]").fill(input_album_desc)
        #page.get_by_role("textbox", name="album_description").click()
        #page.get_by_role("textbox", name="album_description").fill("test_album_desc")
        page.get_by_role("button", name="upload").click()
        page.wait_for_timeout(3000)
    else:
        print("no album is created")

def test_delete_album(test_check_album):
    if test_check_album[0] == False:
        print("trying delete last album")
        page.locator("input[value=test_album]").check()
        page.get_by_role("button", name="delete").click()
        page.wait_for_timeout(3000)

    else:
        print("nothing to delete")



def test_upload():
    page.get_by_role("link", name="UPLOAD").click()


def test_locator_by_id():
    get_text = page.locator('#locator_id').inner_text()
    assert get_text == "Locating by Id"

def test_locator_by_name():
    get_text = page.locator('[name=locator_name]').inner_text()
    assert get_text == "Locating by Name"


def test_locator_by_class():
    get_text = page.locator('[class="locator_class panel panel-success panel-heading"]').inner_text()
    assert get_text == "Locating by Class Name"

def test_locator_by_xpath():
    get_text = page.locator('xpath=/html/body/div/div/div[1]/div[4]').inner_text()
    assert get_text == "Locating by Xpath"

def test_locator_by_css():
    get_text = page.locator('css=div[style*="background-color:#aabbcc"]').inner_text()
    assert get_text == "Locating by CSS Selectors"

def test_over():
    context.close()

    browser.close()
