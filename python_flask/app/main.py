import os,json,uuid
from flask import Flask, render_template, request, redirect, url_for,session
from flask import flash
from werkzeug.utils import secure_filename
from model.models import *
from api.algorithms import *
from api import flask_api
#from kafka import KafkaConsumer


from flask_login import LoginManager, login_user,login_required, logout_user
app = Flask(__name__)
app.register_blueprint(flask_api.flask_api)


path = os.getcwd()

app.secret_key = 'my_album'


############## load config file ###############

config_path = os.path.join(os.path.dirname(__file__), 'config.json')
current_config = open(config_path)
current_config = json.load(current_config)

if current_config['app_mode'] == "prod":
    print("prod mode")
    if current_config['db_type'] == "mysql":
        db_uri = "mysql://" + str(current_config['db_user']) + ":" + str(current_config['db_psw']) + "@" + str(current_config['db_url']) + "/" + str(current_config['db_name'])

elif current_config['app_mode'] == "dev":
    print("dev mode, using local sqlite db")
    db_path = os.path.join(os.path.dirname(__file__), 'database.sqlite3')
    db_uri = 'sqlite:///{}'.format(db_path)
else:
    print("need get app mode config, dev or prod")


#db_uri = 'mysql://root:qa12345@10.0.0.89/demo'
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['API_KEY'] = current_config['api_key']
db.init_app(app)
ALLOWED_EXTENSIONS = {'png','jpg','jpeg','gif'}
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


login_manager = LoginManager()
login_manager.init_app(app)




@login_manager.user_loader
def load_user(user_id):
    return USER_INFO.query.filter_by(id=user_id).first()

@login_manager.unauthorized_handler
def handle_needs_login():
    flash("You have to be logged in to access this page.")
    return redirect(url_for('user_login', next=request.endpoint))


@app.route('/')
@app.route('/index')
@login_required
def index():
    all_albums = IMAGE_ALBUM.query.all()

    return render_template('index.html',all_albums=all_albums)


@app.route('/login', methods=['POST', 'GET'])
def user_login():

    if request.method == 'POST':
        email = request.form['email']
        user_password = request.form['user_password']
        user = USER_INFO.query.filter_by(email=email).first()
        if user is not None and user_password == user.user_password:
            login_user(user, remember=id)
            flash('login successfully')
            print(session['_id'])
            return redirect(url_for('index'))
        flash('wront login info')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():

    logout_user()
    return render_template('login.html')

@app.route('/upload',methods=['POST','GET'])
@login_required
def upload_img():
    image_album = IMAGE_ALBUM.query.all()

    basepath = os.path.dirname(__file__)
    if request.method == 'POST':
        input_image = request.files.getlist('file[]')
        selected_album = request.form['img_album']


        for each_image in input_image:
            if each_image.filename == '':
                return render_template('upload.html',image_album=image_album,message="no file found,do it again")
            else:
                each_image.filename = str(uuid.uuid1()) + ".jpg"
                upload_path = os.path.join(basepath, 'static/images',secure_filename(each_image.filename))
                each_image.save(upload_path)
                image_info = IMAGE_INFO(img_uuid=each_image.filename,img_album=selected_album)
                db.session.add(image_info)
                db.session.commit()
        flash("upload successfully")
        return redirect(url_for('index'))
    return render_template('upload.html',image_album=image_album,message="please select one or more files")

@app.route('/album_show/<string:album_name>')
@login_required
def album_show(album_name):
    all_images = IMAGE_INFO.query.filter_by(img_album=album_name).all()
    return render_template('album_show.html',all_images=all_images)


@app.route('/data_grid',methods=['GET'])
@login_required
def data_grid():
    new_grid_list = []
    all_albums_info = IMAGE_ALBUM.query.all()
    for each_line in all_albums_info:
        new_grid = {}
        new_grid["id"] = each_line.id
        new_grid["name"] = each_line.album_name
        new_grid["description"] = each_line.album_description
        new_grid["count"] = IMAGE_INFO.query.filter_by(img_album=each_line.album_name).count()
        new_grid_list.append(new_grid)
    print(new_grid_list)
   

    return render_template('data_grid.html',all_albums_info=new_grid_list)

@app.route('/kafka', methods=['POST','GET'])
def kafka_consumer():
    consumer = KafkaConsumer('test',
                             bootstrap_servers=['localhost:9092'])
    for message in consumer:
        # message value and key are raw bytes -- decode if necessary!
        # e.g., for unicode: `message.value.decode('utf-8')`
        print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                             message.offset, message.key,
                                             message.value))
        return render_template('kafka_message.html',message=message.value)


@app.route('/api/v1/list_sort',methods=['POST','GET'])
def list_sort():
    data = json.loads(request.data)
    if request.method == 'POST':
        user_name = data['user_name']
        user_password = data['user_password']
        user_list = data['input_list']
        return_list = bubble_sort(user_list)


        return return_list
    else:

        help_info = {"user_name": "<email>", "user_password": "<psw>", "user_url": "<url>","faz_branch":"<version>"}
        return json.dumps(help_info)






if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8000)
