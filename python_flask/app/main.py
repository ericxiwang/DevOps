import sys,os,json,uuid
from flask import Flask, render_template, request, redirect, url_for, session, current_app, Response,current_app
from flask import flash
from werkzeug.utils import secure_filename
from models import *
app = Flask(__name__)

app.secret_key = 'my_album'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.sqlite3'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
@app.route('/')
@app.route('/index')
def index():
    user_info_list = USER_INFO.query.all()
    return render_template('index.html',all_users=user_info_list)
@app.route('/login', methods=['POST', 'GET'])
def user_login():

    error = None
    if request.method == 'POST':
        email = request.form['email']
        user_password = request.form['user_password']

        check_user = USER_INFO.query.filter_by(email=email).first()
        print (check_user)

        if user_password == check_user.user_password:

            session['email'] = email
            session['user_name'] = check_user.user_name
            flash("login successfully")

            return redirect(url_for('index'))
        else:
            return render_template('login.html', error_code="密码错误")

    else:
        return render_template('login.html')
@app.route('/upload',methods=['POST','GET'])
def upload_img():
    image_album=IMAGE_ALBUM.query.all()
    if request.method == 'POST':
        input_image = request.files.getlist('file[]')
        selected_album = request.form['img_album']
        basepath = os.path.dirname(__file__)

        for each_image in input_image:
            each_image.filename = str(uuid.uuid1()) + ".jpg"
            upload_path = os.path.join(basepath, 'static/images',secure_filename(each_image.filename))
            each_image.save(upload_path)
            image_info = IMAGE_INFO(img_uuid=each_image.filename,img_album=selected_album)
            db.session.add(image_info)
            db.session.commit()
        flash("upload successfully")
        return redirect(url_for('index'))

    return render_template('upload.html',image_album=image_album)

@app.route('/album_show/<string:album_name>')
def album_show():
    all_album = IMAGE_ALBUM.query.filter_by(album_name=album_name).all()
    return render_template('album_show.html',all_album=all_album)
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8000)
