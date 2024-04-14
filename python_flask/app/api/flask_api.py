from flask import Blueprint,request,redirect, url_for
import os,json,uuid
from api.algorithms import *

flask_api = Blueprint('flask_api', __name__, url_prefix='/api/v1')
@flask_api.route('/list_reverse',methods=['POST','GET'])
def list_reverse_api():
    try:
        data = json.loads(request.data)
        user_name = data['user_name']
        user_password = data['user_password']
        user_list = data['user_list']
        new_list = bubble_sort(user_list)

        return new_list

    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)


@flask_api.route('/list_comprehension', methods=['POST'])
def list_comprehension_api():
    try:
        data = json.loads(request.data)

              #  request.method == 'POST'
        user_name = data['user_name']
        user_password = data['user_password']
        user_limit = data['user_limit']
        print(user_limit)
        a = list_comprehension(user_limit)
        return a
    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)
@flask_api.route('/fib', methods=['POST'])
def fib_api():

    try:
        data = json.loads(request.data)
          #  request.method == 'POST'
        user_name = data['user_name']
        user_password = data['user_password']
        user_limit = data['user_limit']
        print(user_limit)
        new_list = fib1(user_limit)

        return str(new_list)
    except:

        help_info = {"user_name": "<email>", "user_password": "<psw>","user_list": "[]"}
        return json.dumps(help_info)

@flask_api.route('/build_in_sort', methods=['POST'])
def build_in_sort_api():

     try:
         data = json.loads(request.data)
         user_name = data['user_name']
         user_password = data['user_password']
         input_list = data['user_list']
         print(input_list)
         new_list = build_in_sort(input_list)
         return new_list
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)


@flask_api.route('/bubble_sort', methods=['POST'])
def bubble_sort_api():


     try:
         data = json.loads(request.data)
         user_name = data['user_name']
         user_password = data['user_password']
         input_list = data['user_list']
         new_list = bubble_sort(input_list)
         return new_list
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)
@flask_api.route('/quick_sort', methods=['POST'])
def quick_sort_api():

     try:
         data = json.loads(request.data)
         user_name = data['user_name']
         user_password = data['user_password']
         input_list = data['user_list']
         print(input_list)
         new_list = quick_sort(input_list)
         return new_list
     except:

         help_info = {"user_name": "<email>", "user_password": "<psw>", "user_list": "[]"}
         return json.dumps(help_info)







