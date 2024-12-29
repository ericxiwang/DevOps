from flask import Flask
from kafka import KafkaProducer
import logging
import json

def get_kafka_producer():
    return KafkaProducer(
        bootstrap_servers=['10.0.0.90:9092'],
        value_serializer=lambda m: json.dumps(m).encode('ascii'),
        retry_backoff_ms=500,
        request_timeout_ms=20000,)

# print a nice greeting.
def say_hello(username = "World"):
    # record the event asynchronously
    producer.send('webapp', {'says-hello' : username})
    return '<p>Hello %s!</p>\n' % username


logging.basicConfig(level=logging.DEBUG)

# some bits of text for the page.
header_text = '''
    <html>\n<head> <title>Flask and Kafka</title> </head>\n<body>'''
instructions = '''
    <p><em>Hint</em>: This is a RESTful web service! Append a username
    to the URL (for example: <code>/Thelonious</code>) to say hello to
    someone specific.</p>\n'''
home_link = '<p><a href="/">Back</a></p>\n'
footer_text = '</body>\n</html>'

# EB looks for an 'application' callable by default.
application = Flask(__name__)

# Create a Kafka Producer
producer=get_kafka_producer()

# add a rule for the index page.
application.add_url_rule('/', 'index', (lambda: header_text +
    say_hello() + instructions + footer_text))

# add a rule when the page is accessed with a name appended to the site
# URL.
application.add_url_rule('/<username>', 'hello', (lambda username:
    header_text + say_hello(username) + home_link + footer_text))

# run the app.
if __name__ == "__main__":
    # Setting debug to True enables debug output. This line should be
    # removed before deploying a production app.
    #application.debug = True
    application.run()
    #get_kafka_producer()
    #say_hello(username="World")