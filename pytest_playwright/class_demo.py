import re, pytest
from playwright.sync_api import Playwright, sync_playwright, expect

class page_test:
    def __init__(self,test_url):
        self.URL = test_url
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(headless=False)
        self.context = self.browser.new_context()
        self.page = self.context.new_page()
        self.page.goto(self.URL)
    def login(self):


        page = self.page

        page.get_by_label("")
        page.get_by_placeholder("input email").click()
        page.get_by_placeholder("input email").fill("admin@admin.com")
        page.get_by_placeholder("input email").press("Tab")
        page.get_by_placeholder("input password").fill("1234")
        page.get_by_role("button", name="Login").click()
        title = page.get_by_role("herf",name="Auto Test Demo")
        print(title)
        expect(page).to_have_title(re.compile("Eric's Private Album"))
        #assert (title == "Auto Test Demo")

    def check_banner_list(self):
        page = self.page
        menu_list = ['HOME','TABLE','NEW ALBUM','UPLOAD','LOGOUT']
        new_list = []
        get_all_menu = page.locator("xpath=/html/body/nav/div/ul")
        
        #get_all_menu = get_all_menu.text_content().split("\n")
        get_all_menu = get_all_menu.inner_text().split('\n')
        for each_menu in get_all_menu:
            assert menu_list.count((each_menu)) > 0,"check current menu is exists on banner"


    def home(self):
        page = self.page
        #page.get_by_text("HOME").click()
        page.get_by_role('link', name="HOME").click()
        page.get_by_role("button", name="Enter Album").first.click()
        page.get_by_role("link", name="TABLE").click()
        expect(page).to_have_title(re.compile("Eric's Private Album"))

    def test():
        print("TEST")




test_task = page_test(test_url="http://localhost:8080/login?next=index")
test_task.login()
test_task.check_banner_list()
test_task.home()

