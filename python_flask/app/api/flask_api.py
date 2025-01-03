from flask import Blueprint,request,redirect, url_for, current_app, session
from flask_login import LoginManager, login_user,login_required, logout_user
import os,json,uuid
from api.algorithms import *

from model.models import *


flask_api = Blueprint('flask_api', __name__, url_prefix='/api/v1')



@flask_api.route('/auth', methods=['POST'])
def api_auth():
    data = json.loads(request.data)
    if request.method == 'POST':
        user_name = data['user_name']
        user_password = data['user_password']
        print(user_name,user_password)
        user = USER_INFO.query.filter_by(email=user_name).first()
        if user is not None and user_password == user.user_password:
            login_user(user)
            print(session['_id'])
            return json.dumps(session['_id'])
    else:
        help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
        return json.dumps(help_info)
@flask_api.route('/unauth', methods=['POST'])
def api_unauth():
    logout_user()
    return "api session terminated"


@flask_api.route('/list_reverse', methods=['POST','GET'])

def list_reverse_api():
    try:
        data = json.loads(request.data)
        user_list = list(data['user_list'])
        new_list = list_reverse(user_list)
        result = {'result':new_list}
        return json.dumps(result)

    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)


@flask_api.route('/list_comprehension', methods=['POST'])

def list_comprehension_api():
    try:
        data = json.loads(request.data)
        user_limit = data['user_limit']
        print(user_limit)
        new_list = list_comprehension(user_limit)
        result = {'result': new_list}
        return json.dumps(result)
    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)
@flask_api.route('/fib', methods=['POST'])
def fib_api():

    try:
        data = json.loads(request.data)
        user_limit = data['user_limit']
        print(user_limit)
        new_list = fib1(user_limit)
        result = {'result': new_list}
        return json.dumps(result)
    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)

@flask_api.route('/build_in_sort', methods=['POST'])
def build_in_sort_api():

     try:
         data = json.loads(request.data)
         input_list = data['user_list']
         print(input_list)
         new_list = build_in_sort(input_list)
         result = {'result': new_list}
         return json.dumps(result)
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)


@flask_api.route('/bubble_sort', methods=['POST'])
def bubble_sort_api():


     try:
         data = json.loads(request.data)
         input_list = data['user_list']
         new_list = bubble_sort(input_list)
         result = {'result': new_list}
         return json.dumps(result)
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)
@flask_api.route('/quick_sort', methods=['POST'])
def quick_sort_api():

     try:
         data = json.loads(request.data)
         input_list = data['user_list']
         print(input_list)
         new_list = quick_sort(input_list)
         result = {'result': new_list}
         return json.dumps(result)
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)
@flask_api.route('/user_profile', methods=['POST'])
def user_profile():

     try:
         user_name      =   "admin_test@test.com"
         user_address   =   "1110-1111 eastwood street"
         user_group     =   "admin"

         result = json.dumps({'user_name': user_name, "user_address":  user_address, "user_group": user_group})

         return result
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)


@flask_api.route('/data_grid/<album_name>', methods=['GET'])
def album_table(album_name):
    if album_name == "all":
        all_albums = IMAGE_ALBUM.query.all()
    else:
        all_albums = IMAGE_ALBUM.query.filter_by(album_name=album_name).all()
    new_grid_list = []

    for each_line in all_albums:
        new_grid = {}
        new_grid["id"] = each_line.id
        new_grid["name"] = each_line.album_name
        #new_grid["description"] = each_line.album_description
        new_grid["count"] = IMAGE_INFO.query.filter_by(img_album=each_line.album_name).count()
        new_grid_list.append(new_grid)
    print(new_grid_list)
    result = {'result': new_grid_list}
    print(result)
    return json.dumps(result)






