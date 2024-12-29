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
    #assert 2 == 2


def test_table_page():
    sum_of_pics = 12
    page.get_by_role("link", name="TABLE").click()
    #page.get_by_role("cell", name="Spain", exact=True).click()
    table_data = page.get_by_role("cell").count()
    print("AAAAAAAAAAAAAAAAAAAAAA")
    print(table_data)
    print("AAAAAAAAAAAAAAAAAAAAAA")


def test_new_album():
    page.get_by_role("link", name="NEW ALBUM").click()


def test_upload():
    page.get_by_role("link", name="UPLOAD").click()
