## Robotframework test suite and config files summary
1. api_auto_test.robot  for robotframework API auto test cases scripts
2. page_auto_test.robot for robotframework+selenium web page auto test cases scripts
3. api_temp.json for test input dummy data
4. resource.robot for settings section and customized test case keywords





## robotframework command example

* robot api_auto_test.robot
* robot page_auto_test.robot

### with parameters(for CI command line running on robotframework agent)
* robot -v  browser:Chrome -v selenium_grid_url:http://10.0.0.88:4444/wd/hub -v FLASK_CLOUD_URL:http://10.0.0.89:8080 -v user_name:admin@admin.com     page_auto_test.robot