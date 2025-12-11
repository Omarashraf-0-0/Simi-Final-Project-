import base64
import hashlib
import json
import os
import random
import time
import re  # For extracting lecture numbers
import string
import tempfile
import io
import traceback
import zipfile
from datetime import datetime, timedelta ,date
from difflib import SequenceMatcher

from urllib.parse import urlparse, urlunparse, parse_qs
import smtplib
from email.message import EmailMessage
import requests
import urllib.parse
from collections import defaultdict
import subprocess
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import mysql.connector
#import requests
from flask import Flask, request, jsonify, Response, send_file , url_for
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
from pdfminer.high_level import extract_text
import openai
from abc import ABC, abstractmethod
#from datetime import datetime
app = Flask(__name__)


load_dotenv()  # Load environment variables from .env file


UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}

OMR_SERVER_URL = "https://inspired-initially-warthog.ngrok-free.app/grade"


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_model_answers(quiz_id):
    conn = get_connection()
    if not conn:
        raise RuntimeError("DB connection failed")
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT MCQ, TF FROM paper_quiz_models WHERE quiz_id = %s", (quiz_id,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()

    if not row:
        return [], []
    mcq = [s.strip().upper() for s in row["MCQ"].split(",") if s.strip()]
    tf  = [s.strip().lower() for s in row["TF"].split(",") if s.strip()]
    return mcq, tf

@app.route('/grade', methods=['POST'])
def handle_grading():
    quiz_id = request.form.get("quizId")
    img_file = request.files.get("file")
    print(quiz_id)
    print(img_file.filename)
    # if not quiz_id or not img_file or not allowed_file(img_file.filename):
    #     return jsonify(error="Missing or invalid quizId or file"), 400

    fname = secure_filename(f"{quiz_id}_{img_file.filename}")
    fpath = os.path.join(UPLOAD_DIR, fname)
    img_file.save(fpath)

    # Get model answers from your DB
    try:
        mcq_answers, tf_answers = get_model_answers(quiz_id)
    except Exception as e:
        return jsonify(error=f"DB error: {str(e)}"), 500

    try:
        with open(fpath, 'rb') as image_file:
            files = {'file': image_file}
            data = {
                'mcq_answers': ','.join(mcq_answers),
                'tf_answers': ','.join(tf_answers)
            }
            response = requests.post(OMR_SERVER_URL, files=files, data=data)
            response.raise_for_status()
            return jsonify(response.json())
    except requests.exceptions.RequestException as e:
        error_message = str(e)
        status_code = getattr(e.response, 'status_code', 502)
        try:
            error_content = e.response.json()
        except Exception:
            error_content = e.response.text if e.response else "No response content"
        return jsonify({
            "omr_response": None,
            "error": {
                "message": error_message,
                "status_code": status_code,
                "details": error_content
            }
        }), status_code


#import os
# import cv2
#import json
# import numpy as np
#import mysql.connector
#import requests
#from flask import Flask, request, jsonify, send_file
#from werkzeug.utils import secure_filename


# ─── Configuration ────────────────────────────────────────────────────────────

# UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
# os.makedirs(UPLOAD_DIR, exist_ok=True)

# ALLOWED_EXT = {"png","jpg","jpeg"}

# OMR_URL = "https://AlyAlawa.pythonanywhere.com/ExtractAnswers"  # if you still forward
# # Or, if you want to run OMR locally, skip the forward and call functions directly.

# # ─── Database Connection Helper ───────────────────────────────────────────────

# def get_connection():
#     try:
#         conn = mysql.connector.connect(
#             host="AlyIbrahim.mysql.pythonanywhere-services.com",
#             user="AlyIbrahim",
#             password="I@ly170305",
#             database="AlyIbrahim$StudyMate"
#         )
#         return conn
#     except Exception as e:
#         print(f"Database connection error: {e}")
#         return None

# # ─── Utility ──────────────────────────────────────────────────────────────────

# def allowed_file(fn):
#     return "." in fn and fn.rsplit(".",1)[1].lower() in ALLOWED_EXT

# # ─── OMR Pipeline Helpers ────────────────────────────────────────────────────
# def load_quiz_data(path):return json.load(open(path,'r'))
# def detect_corners(img):
#     original=img.copy()
#     h,w=img.shape[:2]
#     gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
#     blurred=cv2.GaussianBlur(gray,(5,5),0)
#     _,thresh1=cv2.threshold(blurred,70,255,cv2.THRESH_BINARY_INV)
#     adapt_thresh=cv2.adaptiveThreshold(blurred,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY_INV,15,5)
#     thresh=cv2.bitwise_or(thresh1,adapt_thresh)
#     kernel=np.ones((3,3),np.uint8)
#     thresh=cv2.morphologyEx(thresh,cv2.MORPH_CLOSE,kernel)
#     thresh=cv2.morphologyEx(thresh,cv2.MORPH_OPEN,kernel)
#     contours,_=cv2.findContours(thresh,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)
#     margin=int(min(h,w)*0.15)
#     corner_regions=[(0,0,margin,margin),(w-margin,0,margin,margin),(0,h-margin,margin,margin),(w-margin,h-margin,margin,margin)]
#     corner_points=[]
#     for idx,(x,y,rw,rh) in enumerate(corner_regions):
#         region_mask=np.zeros_like(gray)
#         region_mask[y:y+rh,x:x+rw]=255
#         valid_contours=[]
#         for cnt in contours:
#             rect=cv2.boundingRect(cnt)
#             cx,cy=rect[0]+rect[2]//2,rect[1]+rect[3]//2
#             if cv2.pointPolygonTest(np.array([(x,y),(x+rw,y),(x+rw,y+rh),(x,y+rh)]),tuple([float(cx),float(cy)]),False)>=0:
#                 area=cv2.contourArea(cnt)
#                 min_area,max_area=200,5000
#                 if min_area<=area<=max_area:
#                     rx,ry,rw,rh=cv2.boundingRect(cnt)
#                     aspect_ratio=float(rw)/rh
#                     if 0.7<=aspect_ratio<=1.3:
#                         solidity=area/(rw*rh)
#                         if solidity>0.7:
#                             mask=np.zeros_like(gray)
#                             cv2.drawContours(mask,[cnt],0,255,-1)
#                             mean_val=cv2.mean(gray,mask=mask)[0]
#                             if mean_val<100:
#                                 valid_contours.append((cnt,rx+rw//2,ry+rh//2,area,mean_val))
#         if valid_contours:
#             valid_contours.sort(key=lambda c:(c[3],-c[4]))
#             best_cnt=valid_contours[0]
#             corner_points.append((best_cnt[1],best_cnt[2]))
#     if len(corner_points)==4:
#         corners_np=np.array(corner_points)
#         x_sorted=corners_np[np.argsort(corners_np[:,0])]
#         left=x_sorted[:2]
#         right=x_sorted[2:]
#         tl=left[np.argsort(left[:,1])[0]]
#         bl=left[np.argsort(left[:,1])[1]]
#         tr=right[np.argsort(right[:,1])[0]]
#         br=right[np.argsort(right[:,1])[1]]
#         return [tuple(tl),tuple(tr),tuple(br),tuple(bl)]
#     edge_margin=20
#     return [(edge_margin,edge_margin),(w-edge_margin,edge_margin),(w-edge_margin,h-edge_margin),(edge_margin,h-edge_margin)]
# def find_bubbles_from_contours(img):
#     gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
#     clahe=cv2.createCLAHE(clipLimit=3.0,tileGridSize=(8,8))
#     enhanced=clahe.apply(gray)
#     blurred=cv2.GaussianBlur(enhanced,(5,5),0)
#     _,binary_thresh=cv2.threshold(blurred,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
#     adapt_thresh=cv2.adaptiveThreshold(blurred,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY_INV,11,2)
#     combined=cv2.bitwise_or(binary_thresh,adapt_thresh)
#     kernel=np.ones((2,2),np.uint8)
#     morph=cv2.morphologyEx(combined,cv2.MORPH_CLOSE,kernel)
#     morph=cv2.morphologyEx(morph,cv2.MORPH_OPEN,np.ones((1,1),np.uint8))
#     contours,_=cv2.findContours(morph,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
#     bubbles=[]
#     for cnt in contours:
#         area=cv2.contourArea(cnt)
#         if 60<area<900:
#             perimeter=cv2.arcLength(cnt,True)
#             circularity=4*np.pi*area/(perimeter*perimeter) if perimeter>0 else 0
#             if circularity>0.6:
#                 x,y,w,h=cv2.boundingRect(cnt)
#                 aspect_ratio=float(w)/h
#                 if 0.7<aspect_ratio<1.3 and w>8 and h>8:
#                     mask=np.zeros(morph.shape,np.uint8)
#                     cv2.drawContours(mask,[cnt],0,255,-1)
#                     pixel_count=cv2.countNonZero(mask)
#                     mask_cropped=mask[y:y+h,x:x+w]
#                     gray_cropped=gray[y:y+h,x:x+w]
#                     if pixel_count>0:
#                         mean_val=cv2.mean(gray_cropped,mask=mask_cropped)[0]
#                         std_dev=np.std(gray_cropped[mask_cropped==255])
#                         fill_ratio=cv2.countNonZero(cv2.bitwise_and(morph[y:y+h,x:x+w],mask_cropped))/pixel_count
#                         filled=(fill_ratio>0.35 and mean_val<130) or mean_val<90
#                         center_region=mask_cropped[h//4:3*h//4,w//4:3*w//4]
#                         center_filled=cv2.countNonZero(cv2.bitwise_and(morph[y+h//4:y+3*h//4,x+w//4:x+3*w//4],center_region))/max(1,cv2.countNonZero(center_region))>0.45
#                         if center_filled:filled=True
#                         bubbles.append({'center':(x+w//2,y+h//2),'radius':max(w,h)//2,'filled':filled,'x':x,'y':y,'w':w,'h':h,'circularity':circularity,'std_dev':std_dev,'mean_val':mean_val})
#     return bubbles,morph
# def detect_mcq_answers(img):
#     gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY);h,w=gray.shape;blur=cv2.GaussianBlur(gray,(5,5),0)
#     _,binary=cv2.threshold(blur,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU);kernel=np.ones((2,2),np.uint8)
#     morph=cv2.morphologyEx(binary,cv2.MORPH_CLOSE,kernel);morph=cv2.morphologyEx(morph,cv2.MORPH_OPEN,kernel)
#     contours,_=cv2.findContours(morph,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE);circles=[]
#     for cnt in contours:
#         area=cv2.contourArea(cnt)
#         if 30<area<500:
#             (cx,cy),radius=cv2.minEnclosingCircle(cnt);radius=int(radius)
#             if 5<radius<15:
#                 circularity=4*np.pi*area/(cv2.arcLength(cnt,True)**2) if cv2.arcLength(cnt,True)>0 else 0
#                 if circularity>0.6:
#                     mask=np.zeros_like(gray);cv2.drawContours(mask,[cnt],0,255,-1)
#                     mean=cv2.mean(gray,mask=mask)[0];is_filled=mean<100
#                     circles.append((int(cx),int(cy),radius,mean,is_filled))
#     mid_x=w//2;left_circles=[c for c in circles if c[0]<mid_x];right_circles=[c for c in circles if c[0]>=mid_x]
#     if not left_circles or not right_circles:return {},img.copy()
#     min_y=min(c[1] for c in circles);max_y=max(c[1] for c in circles);rows=20;row_height=(max_y-min_y)/(rows-1)
#     grid_left=[];grid_right=[]
#     for i in range(rows):
#         row_y=min_y+i*row_height;row_range=row_height*0.6
#         row_left=[c for c in left_circles if abs(c[1]-row_y)<row_range];row_right=[c for c in right_circles if abs(c[1]-row_y)<row_range]
#         row_left.sort(key=lambda c:c[0]);row_right.sort(key=lambda c:c[0])
#         grid_left.append(row_left);grid_right.append(row_right)
#     answers={};viz=img.copy()
#     for row_idx,row_circles in enumerate(grid_left):
#         q_num=row_idx+1;filled=[c for c in row_circles if c[4]]
#         if filled and len(row_circles)>=3:
#             for c in filled:
#                 x,y,r,_,_=c;option_idx=row_circles.index(c)
#                 if option_idx<4:
#                     answers[q_num]=chr(65+option_idx)
#                     cv2.circle(viz,(x,y),r,(0,255,0),2)
#                     cv2.putText(viz,f"{q_num}:{chr(65+option_idx)}",(x-15,y-8),cv2.FONT_HERSHEY_SIMPLEX,0.4,(255,0,0),1)
#     for row_idx,row_circles in enumerate(grid_right):
#         q_num=row_idx+21;filled=[c for c in row_circles if c[4]]
#         if filled and len(row_circles)>=3:
#             for c in filled:
#                 x,y,r,_,_=c;option_idx=row_circles.index(c)
#                 if option_idx<4:
#                     answers[q_num]=chr(65+option_idx)
#                     cv2.circle(viz,(x,y),r,(0,255,0),2)
#                     cv2.putText(viz,f"{q_num}:{chr(65+option_idx)}",(x-15,y-8),cv2.FONT_HERSHEY_SIMPLEX,0.4,(255,0,0),1)
#     return answers,viz
# def visualize_corners(img,corners):
#     viz=img.copy()
#     if corners:
#         for i,corner in enumerate(corners):
#             if isinstance(corner,tuple)and len(corner)==2:
#                 x,y=corner
#                 cv2.circle(viz,(x,y),15,(0,255,0),-1)
#                 cv2.putText(viz,f"Corner {i+1}",(x+20,y),cv2.FONT_HERSHEY_SIMPLEX,1,(0,255,0),2)
#     return viz
# def perspective_transform(img,corners):
#     if len(corners)!=4:return img
#     width,height=850,1100
#     dst_pts=np.array([[0,0],[width,0],[width,height],[0,height]],dtype=np.float32)
#     corners_np=np.array(corners,dtype=np.float32)
#     M=cv2.getPerspectiveTransform(corners_np,dst_pts)
#     warped=cv2.warpPerspective(img,M,(width,height))
#     return warped
# def find_rectangle_contours(img):
#     gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
#     blur=cv2.GaussianBlur(gray,(5,5),0)
#     edges=cv2.Canny(blur,50,150)
#     kernel=np.ones((3,3),np.uint8)
#     dilated=cv2.dilate(edges,kernel,iterations=2)
#     contours,_=cv2.findContours(dilated,cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)
#     rectangles=[]
#     for cnt in contours:
#         if cv2.contourArea(cnt)<10000:continue
#         peri=cv2.arcLength(cnt,True)
#         approx=cv2.approxPolyDP(cnt,0.02*peri,True)
#         if len(approx)>=4 and len(approx)<=8:
#             x,y,w,h=cv2.boundingRect(approx)
#             aspect_ratio=float(w)/h
#             if 0.2<aspect_ratio<2.5:rectangles.append((cnt,approx,(x,y,w,h)))
#     return rectangles
# def detect_form_sections(img):
#     h,w=img.shape[:2]
#     rectangles=find_rectangle_contours(img)
#     sections={"Name":[int(w*0.1),int(h*0.09),int(w*0.9),int(h*0.13)],"Registration":[int(w*0.3),int(h*0.14),int(w*0.8),int(h*0.18)]}
#     mcq_rect,tf_rect=None,None
#     if len(rectangles)>=2:
#         for cnt,approx,(x,y,w,h)in sorted(rectangles,key=lambda r:r[2][2]*r[2][3],reverse=True)[:4]:
#             if y>img.shape[0]*0.2:
#                 if x<img.shape[1]*0.5 and mcq_rect is None:mcq_rect=(cnt,approx)
#                 elif x>img.shape[1]*0.4 and tf_rect is None:tf_rect=(cnt,approx)
#     if mcq_rect is None:sections["MCQ"]=[int(w*0.05),int(h*0.23),int(w*0.5),int(h*0.9)]
#     else:
#         x,y,w,h=cv2.boundingRect(mcq_rect[0])
#         sections["MCQ"]=[x,y,x+w,y+h]
#     if tf_rect is None:sections["T/F"]=[int(w*0.52),int(h*0.23),int(w*0.9),int(h*0.7)]
#     else:
#         x,y,w,h=cv2.boundingRect(tf_rect[0])
#         sections["T/F"]=[x,y,x+w,y+h]
#     section_imgs={}
#     for name,(x1,y1,x2,y2)in sections.items():
#         cropped=img[y1:y2,x1:x2].copy() if y2>y1 and x2>x1 else img[0:10,0:10].copy()
#         section_imgs[name]=cropped
#     return sections,section_imgs
# def visualize_sections(img,sections):
#     viz=img.copy()
#     colors={"Name":(0,255,0),"Registration":(0,0,255),"MCQ":(255,0,0),"T/F":(255,255,0)}
#     for name,(x1,y1,x2,y2)in sections.items():
#         cv2.rectangle(viz,(x1,y1),(x2,y2),colors[name],3)
#         cv2.putText(viz,name,(x1,y1-10),cv2.FONT_HERSHEY_SIMPLEX,1,colors[name],2)
#     return viz
# def detect_tf_answers(img):
#     bubbles,binary=find_bubbles_from_contours(img)
#     cv2.imwrite("tf_binary.jpg",binary)
#     h,w=img.shape[:2]
#     max_rows=15
#     rows={}
#     row_height=h/max_rows
#     for b in bubbles:
#         row_idx=int(b['center'][1]/row_height)
#         if row_idx not in rows:rows[row_idx]=[]
#         rows[row_idx].append(b)
#     answers={}
#     viz=img.copy()
#     for row_idx,row_bubbles in rows.items():
#         if row_idx>=max_rows or len(row_bubbles)<2:continue
#         q_num=row_idx+1
#         row_bubbles.sort(key=lambda b:b['center'][0])
#         if len(row_bubbles)>=2:
#             if row_bubbles[0]['filled'] and not row_bubbles[1]['filled']:answers[q_num]="True"
#             elif not row_bubbles[0]['filled'] and row_bubbles[1]['filled']:answers[q_num]="False"
#             color1=(0,255,0)if row_bubbles[0]['filled']else(0,0,255)
#             color2=(0,255,0)if row_bubbles[1]['filled']else(0,0,255)
#             cv2.circle(viz,row_bubbles[0]['center'],row_bubbles[0]['radius'],color1,2)
#             cv2.circle(viz,row_bubbles[1]['center'],row_bubbles[1]['radius'],color2,2)
#             cv2.putText(viz,"T",(row_bubbles[0]['center'][0]-5,row_bubbles[0]['center'][1]+5),cv2.FONT_HERSHEY_SIMPLEX,0.5,color1,2)
#             cv2.putText(viz,"F",(row_bubbles[1]['center'][0]-5,row_bubbles[1]['center'][1]+5),cv2.FONT_HERSHEY_SIMPLEX,0.5,color2,2)
#             y_pos=int((row_idx+0.5)*row_height)
#             cv2.putText(viz,f"{q_num}.",(5,y_pos),cv2.FONT_HERSHEY_SIMPLEX,0.5,(255,0,0),2)
#             if q_num in answers:cv2.putText(viz,f"Q{q_num}: {answers[q_num]}",(w-100,y_pos),cv2.FONT_HERSHEY_SIMPLEX,0.5,(255,0,0),2)
#     return answers,viz
# def grade_quiz(mcq_ans,tf_ans,quiz_data):
#     mcq_q=[q for q in quiz_data["questions"]if q["type"]=="mcq"]
#     tf_q=[q for q in quiz_data["questions"]if q["type"]=="true_false"]
#     correct_mcq,mcq_results,correct_tf,tf_results=0,{},0,{}
#     for i,q in enumerate(mcq_q[:40]):
#         q_num=i+1
#         if q_num in mcq_ans:
#             student,correct=mcq_ans[q_num],chr(65+q["options"].index(q["answer"]))
#             mcq_results[q_num]={"student_answer":student,"correct_answer":correct,"is_correct":student==correct}
#             correct_mcq+=student==correct
#     for i,q in enumerate(tf_q[:15]):
#         q_num=i+1
#         if q_num in tf_ans:
#             student,correct=tf_ans[q_num],q["answer"]
#             tf_results[q_num]={"student_answer":student,"correct_answer":correct,"is_correct":student==correct}
#             correct_tf+=student==correct
#     return correct_mcq,correct_tf,mcq_results,tf_results
# def create_result_image(orig,corners_viz,sections_viz,mcq_viz,tf_viz,mcq_answers,tf_answers,correct_mcq,correct_tf,quiz_data):
#     mcq_count,tf_count=len([q for q in quiz_data["questions"]if q["type"]=="mcq"]),len([q for q in quiz_data["questions"]if q["type"]=="true_false"])
#     final_width,final_height,result=2400,1600,np.ones((1600,2400,3),dtype=np.uint8)*255
#     cell_width,cell_height,mcq_width,tf_width=final_width//2,final_height//2,final_width//4,final_width//4
#     result[0:cell_height,0:cell_width]=cv2.resize(orig,(cell_width,cell_height))
#     result[0:cell_height,cell_width:2*cell_width]=cv2.resize(corners_viz,(cell_width,cell_height))
#     result[cell_height:2*cell_height,0:cell_width]=cv2.resize(sections_viz,(cell_width,cell_height))
#     result[cell_height:2*cell_height,cell_width:cell_width+mcq_width]=cv2.resize(mcq_viz,(mcq_width,cell_height))
#     result[cell_height:2*cell_height,cell_width+mcq_width:2*cell_width]=cv2.resize(tf_viz,(tf_width,cell_height))
#     cv2.putText(result,"Original Image",(50,30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,"Corner Detection",(cell_width+50,30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,"Sections Detection",(50,cell_height+30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,"MCQ Detection",(cell_width+50,cell_height+30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,"T/F Detection",(cell_width+mcq_width+50,cell_height+30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,"RESULTS:",(cell_width+50,cell_height+cell_height-250),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,0),2)
#     cv2.putText(result,f"MCQ Score: {correct_mcq}/{min(mcq_count,40)}",(cell_width+50,cell_height+cell_height-200),cv2.FONT_HERSHEY_SIMPLEX,0.8,(0,0,0),2)
#     cv2.putText(result,f"T/F Score: {correct_tf}/{min(tf_count,15)}",(cell_width+50,cell_height+cell_height-150),cv2.FONT_HERSHEY_SIMPLEX,0.8,(0,0,0),2)
#     cv2.putText(result,f"Total: {correct_mcq+correct_tf}/{min(mcq_count,40)+min(tf_count,15)}",(cell_width+50,cell_height+cell_height-100),cv2.FONT_HERSHEY_SIMPLEX,0.8,(0,0,0),2)
#     return result
# def preprocess_image(image):
#     blurred=cv2.GaussianBlur(image,(5,5),0)
#     return blurred
# def extract_student_answers(image_path):
#     """
#     Runs the full OMR pipeline on `image_path`.
#     Returns:
#       stu_mcq (dict), stu_tf (dict),
#       mcq_viz (img), tf_viz (img),
#       orig_img (img), corners_viz (img), sections_viz (img), aligned (img)
#     """
#     orig = cv2.imread(image_path)
#     pre = cv2.GaussianBlur(orig, (5,5), 0)

#     # 1) detect corners + visualize
#     corners = detect_corners(pre)
#     corners_viz = visualize_corners(pre, corners)

#     # 2) warp
#     aligned = perspective_transform(pre, corners)

#     # 3) sections
#     sections, section_imgs = detect_form_sections(aligned)
#     sections_viz = visualize_sections(aligned, sections)

#     # 4) detect answers
#     stu_mcq, mcq_viz = detect_mcq_answers(section_imgs["MCQ"])
#     stu_tf,  tf_viz  = detect_tf_answers(section_imgs["T/F"])

#     return orig, corners_viz, sections_viz, aligned, stu_mcq, mcq_viz, stu_tf, tf_viz

# # ─── Grading Helpers ─────────────────────────────────────────────────────────



# def grade_answers(stu_mcq, stu_tf, model_mcq, model_tf):
#     correct_mcq, mcq_res = 0, {}
#     for i,(s,m) in enumerate(zip(stu_mcq.values(), model_mcq), start=1):
#         ok = s.upper()==m.upper()
#         mcq_res[i] = {"student": s,"model":m,"correct":ok}
#         if ok: correct_mcq+=1

#     correct_tf, tf_res = 0, {}
#     for i,(s,m) in enumerate(zip(stu_tf.values(), model_tf), start=1):
#         ok = s.lower()==m.lower()
#         tf_res[i] = {"student": s,"model":m,"correct":ok}
#         if ok: correct_tf+=1

#     return correct_mcq, correct_tf, mcq_res, tf_res

# # ─── Flask Endpoints ─────────────────────────────────────────────────────────

# @app.route("/ProcessQuizImage", methods=["POST"])
# def process_and_grade():
#     quiz_id = request.form.get("quizId")
#     img_file = request.files.get("file")
#     if not quiz_id or not img_file or not allowed_file(img_file.filename):
#         return jsonify(error="Missing/invalid quizId or file"), 400

#     # 1) Save incoming file
#     fname = secure_filename(f"{quiz_id}_{img_file.filename}")
#     fpath = os.path.join(UPLOAD_DIR, fname)
#     img_file.save(fpath)

#     # 2) Run OMR all in this file
#     orig, corners_viz, sections_viz, aligned, \
#       stu_mcq_dict, mcq_viz, stu_tf_dict, tf_viz = extract_student_answers(fpath)

#     # 3) Fetch model answers & grade
#     try:
#         model_mcq, model_tf = get_model_answers(quiz_id)
#     except Exception as e:
#         return jsonify(error="DB error", details=str(e)), 500

#     c_mcq, c_tf, mcq_res, tf_res = grade_answers(stu_mcq_dict, stu_tf_dict, model_mcq, model_tf)

#     # 4) Build and save annotated result
#     result_img = create_result_image(orig, corners_viz, sections_viz, mcq_viz, tf_viz,
#                                      stu_mcq_dict, stu_tf_dict, c_mcq, c_tf)
#     out_name = fname.rsplit(".",1)[0] + "_result.jpg"
#     out_path = os.path.join(UPLOAD_DIR, out_name)
#     cv2.imwrite(out_path, result_img)

#     # 5) Return JSON + URL
#     return jsonify({
#       "student_mcq": stu_mcq_dict,
#       "student_tf":  stu_tf_dict,
#       "model_mcq":   model_mcq,
#       "model_tf":    model_tf,
#       "correct_mcq": c_mcq,
#       "correct_tf":  c_tf,
#       "mcq_results": mcq_res,
#       "tf_results":  tf_res,
#       "result_image": f"/GetResultImage/{out_name}"
#     }), 200

# @app.route("/GetResultImage/<filename>")
# def get_result_image(filename):
#     path = os.path.join(UPLOAD_DIR, filename)
#     if not os.path.exists(path):
#         return jsonify(error="Not found"), 404
#     return send_file(path, mimetype="image/jpeg")


# import fitz



#START OF CHATBOT (DONT EDIT BETWEEN THEM) ----------------------------



COURSE_CACHE = {}
CACHE_EXPIRY_HOURS = 1

# Conversation history tracking (stores last 5 messages per user session)
CONVERSATION_HISTORY = {}
MAX_HISTORY_LENGTH = 5  # Keep last 5 exchanges

# Pre-loading status tracking
PRELOAD_STATUS = {}  # {course_id: 'loading'|'ready'|'error'}

# ============================================================================
# GREETING DETECTION - For instant responses
# ============================================================================

GREETING_PATTERNS = {
    'ar': ['مرحبا', 'اهلا', 'السلام', 'هاي', 'صباح', 'مساء', 'ازيك', 'عامل ايه', 'كيف حالك', 'شكرا', 'يا', 'ابو ليلى', 'ابوليلى'],
    'en': ['hello', 'hi', 'hey', 'good morning', 'good evening', 'thanks', 'thank you', 'sup', 'yo', 'abolayla', 'abo layla']
}

GREETING_RESPONSES = {
    'ar': [
        "أهلاً! أنا AboLayla، مساعدك في المادة. اسألني أي سؤال عن المحاضرات",
        "مرحباً! إزيك؟ أنا هنا عشان أساعدك في أي حاجة عن الكورس",
        "يا هلا! جاهز أساعدك. إيه اللي محتاج تعرفه؟"
    ],
    'en': [
        "Hello! I'm AboLayla, your study assistant. Ask me anything about the lectures!",
        "Hey there! Ready to help you with the course. What do you need?",
        "Hi! I'm here to help. What would you like to know?"
    ]
}

def is_greeting_message(message):
    """Check if message is just a greeting (no real question)."""
    msg_lower = message.lower().strip()
    
    # Very short messages are likely greetings
    if len(msg_lower) < 15:
        for lang, patterns in GREETING_PATTERNS.items():
            for pattern in patterns:
                if pattern in msg_lower:
                    return True, lang
    return False, None

def get_instant_greeting(language='ar'):
    """Return a random greeting response instantly."""
    lang_key = 'ar' if language.lower() in ['arabic', 'مصري', 'ar'] else 'en'
    return random.choice(GREETING_RESPONSES[lang_key])

# ============================================================================
# AI MODEL ROTATION SYSTEM (3 Free APIs)
# ============================================================================

# API Keys (set these in your environment variables or directly here)
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')  # Get free key: https://makersuite.google.com/app/apikey
GROQ_API_KEY = os.getenv('GROQ_API_KEY', '')      # Get free key: https://console.groq.com
HUGGINGFACE_API_KEY = os.getenv('HUGGINGFACE_API_KEY', '')  # Get free key: https://huggingface.co/settings/tokens

# Model rotation counter
MODEL_ROTATION_COUNTER = 0

# Model configurations
MODELS = [
    {
        'name': 'Gemini',
        'endpoint': 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-thinking-exp:generateContent',
        'api_key': GEMINI_API_KEY,
        'enabled': bool(GEMINI_API_KEY.strip()),
        'model_id': 'gemini-2.0-flash-thinking-exp'
    },
    {
        'name': 'Groq',
        'endpoint': 'https://api.groq.com/openai/v1/chat/completions',
        'model': 'llama-3.1-8b-instant',
        'api_key': GROQ_API_KEY,
        'enabled': bool(GROQ_API_KEY)
    },
    {
        'name': 'HuggingFace',
        'endpoint': 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2',
        'api_key': HUGGINGFACE_API_KEY,
        'enabled': bool(HUGGINGFACE_API_KEY)
    }
]

def get_next_model():
    """Get next available model in rotation."""
    global MODEL_ROTATION_COUNTER

    # Filter enabled models
    enabled_models = [m for m in MODELS if m['enabled']]

    if not enabled_models:
        return None

    # Rotate through models
    model = enabled_models[MODEL_ROTATION_COUNTER % len(enabled_models)]
    MODEL_ROTATION_COUNTER += 1

    print(f"🤖 Using model: {model['name']}")
    return model


def call_gemini_api(prompt):
    """Call Google Gemini 2.0 Flash Thinking API."""
    url = f"{MODELS[0]['endpoint']}?key={MODELS[0]['api_key']}"
    
    payload = {
        "contents": [{
            "parts": [{
                "text": prompt  # Full prompt already constructed
            }]
        }],
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 800,  # Increased for better responses
            "topP": 0.95,
            "topK": 40
        }
    }
    
    response = requests.post(url, json=payload, timeout=20)  # Increased timeout for thinking model
    response.raise_for_status()
    
    result = response.json()
    return result['candidates'][0]['content']['parts'][0]['text']


def call_groq_api(prompt):
    """Call Groq API (OpenAI-compatible)."""
    url = MODELS[1]['endpoint']
    
    headers = {
        "Authorization": f"Bearer {MODELS[1]['api_key']}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": MODELS[1]['model'],
        "messages": [
            {
                "role": "user",
                "content": prompt  # Full prompt already constructed
            }
        ],
        "temperature": 0.7,
        "max_tokens": 800
    }
    
    response = requests.post(url, json=payload, headers=headers, timeout=15)
    response.raise_for_status()
    
    result = response.json()
    return result['choices'][0]['message']['content']


def call_huggingface_api(prompt):
    """Call HuggingFace Inference API."""
    url = MODELS[2]['endpoint']
    
    headers = {
        "Authorization": f"Bearer {MODELS[2]['api_key']}",
        "Content-Type": "application/json"
    }
    
    # Format for instruction-tuned model
    full_prompt = f"[INST] {prompt} [/INST]"
    
    payload = {
        "inputs": full_prompt,
        "parameters": {
            "max_new_tokens": 700,
            "temperature": 0.7,
            "return_full_text": False
        }
    }
    
    response = requests.post(url, json=payload, headers=headers, timeout=20)
    response.raise_for_status()
    
    result = response.json()
    
    # HuggingFace returns different formats
    if isinstance(result, list) and len(result) > 0:
        return result[0].get('generated_text', str(result))
    return str(result)


def generate_ai_response(question, context, language, course_name="", min_lecture=1, max_lecture=1, conversation_history="", lecture_list=""):
    """Generate response using AI with focused, practical prompt engineering."""
    
    # Count total lectures
    total_lectures = len(lecture_list.split(',')) if lecture_list else max_lecture
    
    # Build clean, focused prompt
    if language.lower() in ['arabic', 'مصري']:
        prompt = f"""أنت AboLayla، مساعد تعليمي لطلاب الجامعة في مادة {course_name}.

## معلومات المادة:
- عدد المحاضرات: {total_lectures} محاضرة
- أرقام المحاضرات: {lecture_list}
- النطاق: من {min_lecture} إلى {max_lecture}

## قواعدك:
1. اقرأ المحادثة السابقة كويس - لو الطالب قال "أيوه" أو "تمام" أو "أكيد" يبقى موافق على اللي عرضته قبل كده
2. لو عرضت تساعده ووافق - ساعده فوراً، ماتسألش تاني
3. رد بالمصري العامي
4. كن مختصر ومفيد - الطلاب عايزين إجابات سريعة
5. لو المعلومة مش في المحاضرات - ساعده بمعلوماتك العامة
6. لا تستخدم emojis
7. لا تقول "بناءً على المحاضرات" أو "حسب المحتوى" - ادي الإجابة مباشرة

## المحادثة السابقة:
{conversation_history if conversation_history else "(أول رسالة)"}

## محتوى المحاضرات:
{context}

## سؤال الطالب الحالي:
{question}

## إجابتك (مختصرة ومباشرة):
"""
    else:
        prompt = f"""You are AboLayla, a teaching assistant for college students studying {course_name}.

## Course Info:
- Total lectures: {total_lectures}
- Lecture numbers: {lecture_list}
- Range: {min_lecture} to {max_lecture}

## Your Rules:
1. READ THE CONVERSATION HISTORY CAREFULLY - if student says "yes", "sure", "okay", "yeah" they are agreeing to what you offered
2. If you offered to help and they agreed - HELP IMMEDIATELY, don't ask again
3. Be CONCISE and DIRECT - students want quick answers
4. If info isn't in lectures - help with your general knowledge anyway
5. NO emojis
6. DON'T say "based on the lectures" or "according to the content" - just give the answer directly
7. DON'T repeat yourself or explain your thinking process
8. Use proper formatting whenever needed like (Bulletin, numbered lists, code blocks, etc.)

## Previous Conversation:
{conversation_history if conversation_history else "(First message)"}

## Lecture Content:
{context}

## Student's Current Question:
{question}

## Your Answer (concise and direct):
"""
    
    # Try models in rotation with fallback
    enabled_models = [m for m in MODELS if m['enabled']]

    if not enabled_models:
        print("⚠️ No AI models enabled, using simple extraction")
        return None

    for attempt in range(len(enabled_models)):
        model = get_next_model()

        try:
            print(f"🔄 Attempting {model['name']}...")

            if model['name'] == 'Gemini':
                return call_gemini_api(prompt)
            elif model['name'] == 'Groq':
                return call_groq_api(prompt)
            elif model['name'] == 'HuggingFace':
                return call_huggingface_api(prompt)

        except Exception as e:
            print(f"❌ {model['name']} failed: {e}")
            if attempt < len(enabled_models) - 1:
                print(f"🔄 Trying next model...")
                continue
            else:
                print("⚠️ All models failed, using fallback")
                return None

    return None

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_cached_course(course_id):
    """Check if course data is already cached."""
    if course_id in COURSE_CACHE:
        cache_entry = COURSE_CACHE[course_id]
        last_access = cache_entry['last_access']

        if datetime.now() - last_access < timedelta(hours=CACHE_EXPIRY_HOURS):
            cache_entry['last_access'] = datetime.now()
            print(f"✅ Using cached data for course {course_id}")
            return cache_entry
        else:
            del COURSE_CACHE[course_id]
            print(f"⏰ Cache expired for course {course_id}")

    return None


def cache_course_data(course_id, texts, chunks):
    """Save processed course data to cache."""
    COURSE_CACHE[course_id] = {
        'texts': texts,
        'chunks': chunks,
        'last_access': datetime.now()
    }
    print(f"💾 Cached data for course {course_id} ({len(chunks)} chunks)")


def extract_text_from_pdfs_for_chat(pdf_paths):
    """Extract text from PDFs for chatbot."""
    lecture_texts = {}

    for pdf_path, lecture_number in pdf_paths:
        print(f"📖 Extracting text from {pdf_path} (Lecture {lecture_number})...")
        try:
            text = extract_text(pdf_path)
            if text:
                lecture_texts[lecture_number] = text
                print(f"✅ Extracted {len(text)} characters")
            else:
                print(f"⚠️ No text extracted")
        except Exception as e:
            print(f"❌ Error: {e}")

    return lecture_texts


def split_text_into_chunks_with_metadata(lecture_texts, chunk_size=1000):
    """Split lecture texts into searchable chunks."""
    all_chunks = []

    for lecture_num, text in lecture_texts.items():
        words = text.split()

        for i in range(0, len(words), chunk_size):
            chunk = ' '.join(words[i:i + chunk_size])
            all_chunks.append({
                'lecture': lecture_num,
                'text': chunk,
                'chunk_index': i // chunk_size,
                'word_count': len(chunk.split())
            })

    print(f"📄 Created {len(all_chunks)} chunks")
    return all_chunks


def calculate_relevance_score(chunk_text, query):
    """Calculate how relevant a chunk is to the query."""
    chunk_lower = chunk_text.lower()
    query_lower = query.lower()

    stop_words = {'what', 'is', 'the', 'how', 'why', 'when', 'where', 'who',
                  'can', 'does', 'do', 'are', 'a', 'an', 'and', 'or', 'but',
                  'ما', 'هو', 'هي', 'في', 'من', 'على', 'إلى', 'عن', 'مع'}
    query_words = [w for w in query_lower.split() if w not in stop_words and len(w) > 2]

    if not query_words:
        return 0

    score = 0

    # Exact phrase match
    if query_lower in chunk_lower:
        score += 10

    # Keyword matches
    for word in query_words:
        if word in chunk_lower:
            count = chunk_lower.count(word)
            score += count * 2

    # Fuzzy similarity
    similarity = SequenceMatcher(None, query_lower, chunk_lower[:len(query_lower)*3]).ratio()
    score += similarity * 5

    return score


def get_available_lectures(chunks):
    """Extract the actual range of available lectures from chunks."""
    if not chunks:
        return 1, 1
    lecture_numbers = [chunk['lecture'] for chunk in chunks]
    return min(lecture_numbers), max(lecture_numbers)


def add_to_conversation_history(session_id, user_message, bot_response):
    """Track conversation history for context awareness."""
    if session_id not in CONVERSATION_HISTORY:
        CONVERSATION_HISTORY[session_id] = []
    
    CONVERSATION_HISTORY[session_id].append({
        'user': user_message,
        'bot': bot_response
    })
    
    # Keep only last N exchanges
    if len(CONVERSATION_HISTORY[session_id]) > MAX_HISTORY_LENGTH:
        CONVERSATION_HISTORY[session_id] = CONVERSATION_HISTORY[session_id][-MAX_HISTORY_LENGTH:]


def get_conversation_context(session_id):
    """Retrieve conversation history for context."""
    if session_id not in CONVERSATION_HISTORY:
        return ""
    
    history = CONVERSATION_HISTORY[session_id]
    if not history:
        return ""
    
    # Format conversation history - include FULL responses for proper context
    context_lines = []
    for i, exchange in enumerate(history[-5:], 1):  # Last 5 exchanges
        context_lines.append(f"[Turn {i}]")
        context_lines.append(f"Student: {exchange['user']}")
        context_lines.append(f"AboLayla: {exchange['bot']}")
        context_lines.append("")
    
    return "\n".join(context_lines)


def find_relevant_chunks(chunks, query, top_k=5):
    """Find the most relevant chunks with intelligent scoring."""
    print(f"🔍 Searching {len(chunks)} chunks for: '{query}'")

    scored_chunks = []
    for chunk in chunks:
        score = calculate_relevance_score(chunk['text'], query)
        if score > 0:
            scored_chunks.append({**chunk, 'relevance_score': score})

    # Sort by relevance first, then by lecture number for ties
    scored_chunks.sort(key=lambda x: (x['relevance_score'], -x['lecture']), reverse=True)
    top_chunks = scored_chunks[:top_k]

    lectures = sorted(set(c['lecture'] for c in top_chunks))
    print(f"✅ Found {len(top_chunks)} relevant chunks from lectures: {lectures}")
    return top_chunks


def generate_chatbot_response_simple(query, relevant_chunks, language, course_name, all_chunks, conversation_history=""):
    """Generate chatbot response with conversation-aware AI."""

    if not relevant_chunks:
        if language.lower() in ['arabic', 'مصري']:
            return {
                'answer': "عذراً، لم أجد معلومات حول هذا الموضوع في المحتوى الدراسي",
                'sources': [],
                'context_used': 0,
                'model_used': 'none'
            }
        else:
            return {
                'answer': "Sorry, I couldn't find information about this in the course materials",
                'sources': [],
                'context_used': 0,
                'model_used': 'none'
            }

    # Get lecture boundaries and complete list
    min_lecture, max_lecture = get_available_lectures(all_chunks)
    all_lecture_numbers = sorted(set(chunk['lecture'] for chunk in all_chunks))
    lecture_list = ', '.join(map(str, all_lecture_numbers))
    
    # ALWAYS provide AI with overview of ALL lectures first
    lecture_overview = {}
    for chunk in all_chunks:
        lec_num = chunk['lecture']
        if lec_num not in lecture_overview:
            lecture_overview[lec_num] = chunk['text'][:300]  # First 300 chars of each lecture
    
    # Build overview section
    overview_parts = []
    for lec_num in sorted(lecture_overview.keys()):
        overview_parts.append(f"[Lecture {lec_num} Overview]: {lecture_overview[lec_num]}")
    
    overview_context = "\n\n".join(overview_parts)
    
    # Build detailed context from relevant chunks
    detail_parts = []
    for chunk in relevant_chunks[:5]:
        detail_parts.append(f"[Lecture {chunk['lecture']} Details]: {chunk['text'][:1000]}")
    
    detailed_context = "\n\n".join(detail_parts)
    
    # Combine both: overview + details
    combined_context = f"=== OVERVIEW OF ALL LECTURES ===\n{overview_context}\n\n=== DETAILED CONTENT FOR YOUR QUESTION ===\n{detailed_context}"

    sources = [{'lecture': chunk['lecture'], 'relevance': chunk['relevance_score']}
               for chunk in relevant_chunks]

    # Try AI models first
    ai_answer = generate_ai_response(
        query, 
        combined_context, 
        language, 
        course_name, 
        min_lecture, 
        max_lecture,
        conversation_history,
        lecture_list
    )

    if ai_answer:
        # Return clean answer without source citations
        return {
            'answer': ai_answer,
            'sources': sources,
            'context_used': len(relevant_chunks),
            'model_used': 'ai'
        }

    else:
        # Fallback to simple extraction
        print("⚠️ Using fallback simple extraction")
        best_chunk = relevant_chunks[0]
        snippet = best_chunk['text'][:600] + "..." if len(best_chunk['text']) > 600 else best_chunk['text']
        
        return {
            'answer': snippet,
            'sources': sources,
            'context_used': len(relevant_chunks),
            'model_used': 'fallback'
        }


# ============================================================================
# MAIN CHATBOT ENDPOINT
# ============================================================================

def chat_endpoint(app, get_connection, BASE_DIR, allowed_file, extract_lecture_number):
    """
    Register the /chat endpoint to the Flask app.
    This function should be called from your main server file.

    Usage in your main server:
        from abolayla_chatbot_complete import chat_endpoint
        chat_endpoint(app, get_connection, BASE_DIR, allowed_file, extract_lecture_number)
    """

    @app.route('/chat', methods=['POST'])
    def chat():
        """
        AboLayla chatbot with RAG + Conversation History.
        - Greetings: INSTANT (<100ms)
        - Cached questions: ~3-5 seconds
        - First time: ~30 seconds (use /preload_chat first!)

        Expected JSON:
        {
            "co_id": 1,
            "session_id": "user123_course1",  # Unique ID for conversation tracking
            "course_name": "Biology" (optional),
            "question": "What is photosynthesis?",
            "language": "English" or "مصري"
        }
        """
        start_time = time.time()

        try:
            data = request.get_json()

            # Get parameters
            co_id = data.get('co_id')
            session_id = data.get('session_id', f"user_{co_id}")  # Default session ID
            course_name = data.get('course_name', 'this course')
            question = data.get('question')
            language = data.get('language', 'English')

            # Validate
            if not all([co_id, question]):
                return jsonify({
                    'status': 'error',
                    'message': 'Missing co_id or question'
                }), 400

            print(f"\n{'='*60}")
            print(f"💬 AboLayla Chat - Course: {co_id}, Session: {session_id}, Q: {question}")
            print(f"{'='*60}\n")

            # ============ INSTANT GREETING CHECK ============
            # If it's just a greeting, respond INSTANTLY (no RAG needed)
            is_greeting, detected_lang = is_greeting_message(question)
            if is_greeting:
                greeting_response = get_instant_greeting(language)
                processing_time = time.time() - start_time
                print(f"⚡ Instant greeting in {processing_time:.3f}s")
                
                # Still track conversation
                add_to_conversation_history(session_id, question, greeting_response)
                
                return jsonify({
                    'status': 'success',
                    'answer': greeting_response,
                    'sources': [],
                    'cache_used': True,
                    'processing_time': processing_time,
                    'model_used': 'instant_greeting'
                }), 200

            # ============ CHECK CACHE ============
            cached_data = get_cached_course(co_id)
            cache_used = False

            if cached_data:
                chunks = cached_data['chunks']
                cache_used = True
            else:
                # Process PDFs (first time only)
                print("📚 Processing PDFs (~30 seconds)...")

                # Get course name from database
                conn = get_connection()
                if not conn:
                    return jsonify({'status': 'error', 'message': 'Database error'}), 500

                try:
                    cursor = conn.cursor()
                    cursor.execute("SELECT COName FROM Courses WHERE COId = %s", (co_id,))
                    result = cursor.fetchone()
                    cursor.close()
                    conn.close()

                    if not result:
                        return jsonify({'status': 'error', 'message': 'Course not found'}), 404

                    course_name = result[0]
                except Exception as e:
                    print(f"❌ DB Error: {e}")
                    return jsonify({'status': 'error', 'message': 'Database error'}), 500

                # Build path to PDFs
                course_dir = os.path.join(BASE_DIR, 'lectures', course_name.strip().replace(' ', ''))

                if not os.path.exists(course_dir):
                    return jsonify({'status': 'error', 'message': 'Course directory not found'}), 404

                # Get PDF files (check for .pdf extension)
                all_files = os.listdir(course_dir)
                pdf_files = [f for f in all_files if f.lower().endswith('.pdf')]

                if not pdf_files:
                    return jsonify({'status': 'error', 'message': 'No PDFs found'}), 404

                # Build PDF paths
                pdf_paths = []
                for filename in pdf_files:
                    lecture_number = extract_lecture_number(filename)
                    if lecture_number is not None:
                        file_path = os.path.join(course_dir, filename)
                        pdf_paths.append((file_path, lecture_number))

                if not pdf_paths:
                    return jsonify({'status': 'error', 'message': 'No valid PDFs'}), 404

                # Extract text
                lecture_texts = extract_text_from_pdfs_for_chat(pdf_paths)

                if not lecture_texts:
                    return jsonify({'status': 'error', 'message': 'Could not extract text'}), 500

                # Create searchable chunks
                chunks = split_text_into_chunks_with_metadata(lecture_texts)

                # Cache it
                cache_course_data(co_id, lecture_texts, chunks)

            # Find relevant chunks
            relevant_chunks = find_relevant_chunks(chunks, question, top_k=3)

            if not relevant_chunks:
                no_info = (
                    "عذراً، لم أجد معلومات حول هذا الموضوع في المحتوى الدراسي"
                    if language.lower() in ['arabic', 'مصري']
                    else "Sorry, I couldn't find information about this in the course materials"
                )

                return jsonify({
                    'status': 'success',
                    'answer': no_info,
                    'sources': [],
                    'cache_used': cache_used,
                    'processing_time': time.time() - start_time
                }), 200

            # Get conversation history for context
            conversation_context = get_conversation_context(session_id)

            # Generate response with full context awareness
            response_data = generate_chatbot_response_simple(
                question,
                relevant_chunks,
                language,
                course_name,
                chunks,  # Pass all chunks for lecture boundary detection
                conversation_context  # Pass conversation history
            )

            # Track this conversation exchange
            add_to_conversation_history(session_id, question, response_data.get('answer', ''))

            processing_time = time.time() - start_time
            print(f"✅ Done in {processing_time:.2f}s (cache: {cache_used}, model: {response_data.get('model_used', 'unknown')})\n")

            return jsonify({
                'status': 'success',
                'answer': response_data['answer'],
                'sources': response_data['sources'],
                'cache_used': cache_used,
                'processing_time': processing_time,
                'model_used': response_data.get('model_used', 'unknown')
            }), 200

        except Exception as e:
            print(f"❌ Error: {e}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': str(e)}), 500


    @app.route('/clear_chat_cache', methods=['POST'])
    def clear_chat_cache():
        """Clear cache for a specific course or all courses."""
        try:
            data = request.get_json()
            co_id = data.get('co_id') if data else None

            if co_id:
                if co_id in COURSE_CACHE:
                    del COURSE_CACHE[co_id]
                    return jsonify({'status': 'success', 'message': f'Cache cleared for course {co_id}'}), 200
                else:
                    return jsonify({'status': 'success', 'message': f'No cache for course {co_id}'}), 200
            else:
                cache_count = len(COURSE_CACHE)
                COURSE_CACHE.clear()
                return jsonify({'status': 'success', 'message': f'Cleared {cache_count} caches'}), 200

        except Exception as e:
            return jsonify({'status': 'error', 'message': str(e)}), 500


    @app.route('/chat_cache_status', methods=['GET'])
    def chat_cache_status():
        """Get status of current caches."""
        cache_info = []

        for co_id, cache_entry in COURSE_CACHE.items():
            cache_info.append({
                'course_id': co_id,
                'chunks_count': len(cache_entry['chunks']),
                'lectures_count': len(cache_entry['texts']),
                'last_access': cache_entry['last_access'].isoformat(),
                'age_minutes': (datetime.now() - cache_entry['last_access']).total_seconds() / 60
            })

        return jsonify({
            'status': 'success',
            'total_cached_courses': len(COURSE_CACHE),
            'caches': cache_info,
            'cache_expiry_hours': CACHE_EXPIRY_HOURS
        }), 200


    @app.route('/preload_chat', methods=['POST'])
    def preload_chat():
        """
        Pre-load course data into cache BEFORE user starts chatting.
        Call this when user opens the chat screen for instant responses.
        
        Expected JSON:
        {
            "co_id": 27
        }
        
        Response:
        - If already cached: instant success
        - If loading: returns status
        - If new: loads in background, returns quickly
        """
        start_time = time.time()
        
        try:
            data = request.get_json()
            co_id = data.get('co_id')
            
            if not co_id:
                return jsonify({'status': 'error', 'message': 'Missing co_id'}), 400
            
            # Check if already cached
            cached_data = get_cached_course(co_id)
            if cached_data:
                return jsonify({
                    'status': 'success',
                    'message': 'Course already cached',
                    'cached': True,
                    'chunks_count': len(cached_data['chunks']),
                    'processing_time': time.time() - start_time
                }), 200
            
            # Check if currently loading
            if PRELOAD_STATUS.get(co_id) == 'loading':
                return jsonify({
                    'status': 'loading',
                    'message': 'Course is being loaded',
                    'cached': False
                }), 202
            
            # Mark as loading
            PRELOAD_STATUS[co_id] = 'loading'
            print(f"📚 Pre-loading course {co_id}...")
            
            # Get course name from database
            conn = get_connection()
            if not conn:
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': 'Database error'}), 500
            
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT COName FROM Courses WHERE COId = %s", (co_id,))
                result = cursor.fetchone()
                cursor.close()
                conn.close()
                
                if not result:
                    PRELOAD_STATUS[co_id] = 'error'
                    return jsonify({'status': 'error', 'message': 'Course not found'}), 404
                
                course_name = result[0]
            except Exception as e:
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': f'Database error: {e}'}), 500
            
            # Build path to PDFs
            course_dir = os.path.join(BASE_DIR, 'lectures', course_name.strip().replace(' ', ''))
            
            if not os.path.exists(course_dir):
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': 'Course directory not found'}), 404
            
            # Get PDF files
            all_files = os.listdir(course_dir)
            pdf_files = [f for f in all_files if f.lower().endswith('.pdf')]
            
            if not pdf_files:
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': 'No PDFs found'}), 404
            
            # Build PDF paths
            pdf_paths = []
            for filename in pdf_files:
                lecture_number = extract_lecture_number(filename)
                if lecture_number is not None:
                    file_path = os.path.join(course_dir, filename)
                    pdf_paths.append((file_path, lecture_number))
            
            if not pdf_paths:
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': 'No valid PDFs'}), 404
            
            # Extract text
            lecture_texts = extract_text_from_pdfs_for_chat(pdf_paths)
            
            if not lecture_texts:
                PRELOAD_STATUS[co_id] = 'error'
                return jsonify({'status': 'error', 'message': 'Could not extract text'}), 500
            
            # Create searchable chunks
            chunks = split_text_into_chunks_with_metadata(lecture_texts)
            
            # Cache it
            cache_course_data(co_id, lecture_texts, chunks)
            
            PRELOAD_STATUS[co_id] = 'ready'
            processing_time = time.time() - start_time
            
            print(f"✅ Course {co_id} pre-loaded in {processing_time:.2f}s ({len(chunks)} chunks)")
            
            return jsonify({
                'status': 'success',
                'message': 'Course pre-loaded successfully',
                'cached': True,
                'chunks_count': len(chunks),
                'lectures_count': len(lecture_texts),
                'processing_time': processing_time
            }), 200
            
        except Exception as e:
            PRELOAD_STATUS[co_id] = 'error' if co_id else 'error'
            print(f"❌ Preload error: {e}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': str(e)}), 500


##END OF CHATBOT (DONT EDIT BETWEEN THEM)------------------------------

def extract_texts(pdf_path):
            """Extracts text from a given PDF file."""
            text = ""
            try:
                with fitz.open(pdf_path) as pdf_document:
                    for page_number in range(len(pdf_document)):
                        page = pdf_document[page_number]
                        text += page.get_text()
            except Exception as e:
                print(f"Error reading {pdf_path}: {e}")
            return text

        # Function to extract recommendations from text
def extract_recommendations_from_text(text, topics):
            """Extracts recommendations based on the presence of topics in the text."""
            recommendations = {}
            for topic in topics:
                topic_lower = topic.lower()
                text_lower = text.lower()

                if topic_lower in text_lower:
                    start_idx = text_lower.find(topic_lower)
                    end_idx = start_idx + 200  # Capture a snippet around the topic
                    snippet = text[start_idx:end_idx]
                    recommendations[topic] = snippet.strip()
                else:
                    # Debugging: Log if topic is not found
                    # print(f"Topic '{topic}' not found in the text.")
                    pass
            return recommendations

        # Function to process multiple PDFs and extract recommendations for topics
def extract_recommendations_from_pdfs(pdf_paths, csv_topics):
            """Processes PDFs and extracts detailed recommendations for topics in the CSV."""
            topic_recommendations = {}
            for pdf_path, lecture_number in pdf_paths:
                # print(f"Processing {pdf_path} (Lecture {lecture_number})...")
                try:
                    text = extract_texts(pdf_path)

                    # Debugging: Print a snippet of the text to verify extraction
                    # print(f"Extracted text snippet from Lecture {lecture_number}: {text[:120]}")

                    if text:
                        recommendations = extract_recommendations_from_text(text, csv_topics)
                        for topic, snippet in recommendations.items():
                            topic_recommendations[(lecture_number, topic)] = snippet
                    else:
                        print(f"No text extracted from {pdf_path}.")

                except Exception as e:
                     print(f"Error extracting recommendations from {pdf_path}: {e}")

            return topic_recommendations


        # Function to calculate accuracy for each topic
def calculate_accuracy(quiz_results):
            """Calculates accuracy for each lecture-topic pair."""
            topic_scores = defaultdict(lambda: {"correct": 0, "total": 0})

            for _, row in quiz_results.iterrows():
                lecture = row["Lecture"]
                topic = row["Topic"]
                correct = row["Correct"]

                topic_scores[(lecture, topic)]["total"] += 1
                if correct:
                    topic_scores[(lecture, topic)]["correct"] += 1

            # Calculate accuracy
            topic_accuracy = {}
            for key, value in topic_scores.items():
                accuracy = value["correct"] / value["total"]
                topic_accuracy[key] = accuracy

            return topic_accuracy

def RecommendationMap(topic, lecture, accuracy, extracted_recommendation):
            """Generates concise recommendations for weak topics, ensuring full sentences and no word cutoff."""
            if extracted_recommendation:
                # Limit to 120 characters
                recommendation = extracted_recommendation[:150]

                # Find the last sentence-ending punctuation within the 120 character limit
                sentence_end = max(recommendation.rfind(punct) for punct in ['.', '!', '?'])

                if sentence_end != -1:
                    # Trim recommendation to the last complete sentence
                    recommendation = recommendation[:sentence_end+1]
                else:
                    # If no punctuation, find the last full word within the 120 character limit
                    last_space = recommendation.rfind(' ')
                    if last_space != -1:
                        recommendation = recommendation[:last_space] + '...'
                    else:
                        # If no spaces, just truncate and add ellipsis
                        recommendation = recommendation + '...'

                return (
                    f"Weak point: '{topic}' in Lecture {lecture} "
                    f"(Accuracy: {accuracy:.2f}). Suggested: {recommendation}"
                )
            else:
                return (
                    f"Weak point: '{topic}' in Lecture {lecture} "
                    f"(Accuracy: {accuracy:.2f}). Suggested: Review materials and seek help."
                )


@app.route('/Recommendation', methods=['POST'])
def Recommendation_system():
    try:
        data = request.get_json()
        paths = data.get('links')  # Should be a list of PDF paths and lecture numbers
        score = data.get('score')
        quiz_results_data = data.get('score')  # Corrected to get 'quiz_results'

        if not paths:
            return jsonify({'error': 'Missing "links" in request data'}), 400

        if not quiz_results_data:
            return jsonify({'error': 'Missing "quiz_results" in request data'}), 400

        # Extract topics from quiz results
        topics = list({item['Topic'] for item in quiz_results_data})

        # Extract recommendations from PDFs
        recommendations = extract_recommendations_from_pdfs(paths, topics)

        # Calculate accuracies for each topic
        topic_accuracies = calculate_accuracy(quiz_results_data)

        # Generate recommendation messages
        recommendation_messages = []
        for (lecture, topic), accuracy in topic_accuracies.items():
            extracted_recommendation = recommendations.get((lecture, topic))
            message = RecommendationMap(topic, lecture, accuracy, extracted_recommendation)
            recommendation_messages.append({
                'lecture': lecture,
                'topic': topic,
                'accuracy': accuracy,
                'recommendation': message
            })

        # Return the recommendations in the response
        return jsonify({'recommendations': recommendation_messages}), 200

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500





latex_template = """
\\documentclass[paper=letter,fontsize=11pt]{scrartcl}

\\usepackage[english]{babel}
\\usepackage[utf8x]{inputenc}
\\usepackage[protrusion=true,expansion=true]{microtype}
\\usepackage{amsmath,amsfonts,amsthm}
\\usepackage{graphicx}
\\usepackage[svgnames]{xcolor}
\\usepackage{geometry}
\\usepackage[colorlinks=true, linkcolor=blue, urlcolor=blue]{hyperref}
\\usepackage{float}
\\usepackage{etaremune}
\\usepackage{wrapfig}
\\usepackage{attachfile}

\\frenchspacing
\\pagestyle{empty}

\\setlength\\topmargin{0pt}
\\addtolength\\topmargin{-\\headheight}
\\addtolength\\topmargin{-\\headsep}
\\setlength\\oddsidemargin{0pt}
\\setlength\\textwidth{\\paperwidth}
\\addtolength\\textwidth{-2in}
\\setlength\\textheight{\\paperheight}
\\addtolength\\textheight{-2in}
\\usepackage{layout}

%%% Custom sectioning (sectsty package)
\\usepackage{sectsty}
\\sectionfont{
\t\\usefont{OT1}{phv}{b}{n}
\t\\sectionrule{0pt}{0pt}{-5pt}{1pt}
}

%%% Macros
\\newlength{\\spacebox}
\\settowidth{\\spacebox}{8888888888}
\\newcommand{\\sepspace}{\\vspace*{1em}}

\\newcommand{\\MyName}[1]{ % Name
\t\\Huge \\usefont{OT1}{phv}{b}{n} \\hfill #1
\t\\par \\normalsize \\normalfont
}

\\newcommand{\\MySlogan}[1]{ % Slogan (optional)
\t\\large \\usefont{OT1}{phv}{m}{n}\\hfill \\textit{#1}
\t\\par \\normalsize \\normalfont
}

\\newcommand{\\NewPart}[2]{\\section*{\\uppercase{#1} \\small \\normalfont #2}}

\\newcommand{\\NewParttwo}[1]{
\t\\noindent \\huge \\textbf{#1}
    \\normalsize \\par
}

\\newcommand{\\PersonalEntry}[2]{\\small
\t\\noindent\\hangindent=2em\\hangafter=0 % Indentation
\t\\parbox{\\spacebox}{\\textit{#1}}
\t\\small\\hspace{1.5em} #2 \\par
}

\\newcommand{\\SkillsEntry}[2]{
\t\\noindent\\hangindent=2em\\hangafter=0 % Indentation
\t\\parbox{\\spacebox}{\\textit{#1}}
\t\\hspace{1.5em} #2 \\par
}

\\newcommand{\\EducationEntry}[4]{
\t\\noindent \\textbf{#1} \\hfill
\t\\colorbox{White}{
\t\t\\parbox{6em}{
\t\t\\hfill\\color{Black}#2}}
\t\\par
\t\\noindent \\textit{#3} \\par
\t\\noindent\\hangindent=2em\\hangafter=0 \\small #4
\t\\normalsize \\par
}

\\newcommand{\\WorkEntry}[5]{
\t\\noindent \\textbf{#1}
    \\noindent \\small \\textit{#2}
    \\hfill
    \\colorbox{White}{
\t\t\\parbox{6em}{
\t\t\\hfill\\color{Black}#3}}
\t\\par
\t\\noindent \\textit{#4} \\par
\t\\noindent\\hangindent=2em\\hangafter=0 \\small #5
\t\\normalsize \\par
}

\\newcommand{\\Language}[2]{
\t\\noindent \\textbf{#1}
    \\noindent \\small \\textit{#2}
}

\\newcommand{\\Text}[1]{\\par
\t\\noindent \\small #1
\t\\normalsize \\par
}

\\newcommand{\\Textlong}[4]{
\t\\noindent \\textbf{#1} \\par
    \\sepspace
    \\noindent \\small #2
    \\par\\sepspace
\t\\noindent \\small #3
    \\par\\sepspace
\t\\noindent \\small #4
    \\normalsize \\par
}

\\newcommand{\\PaperEntry}[7]{
\t\\noindent #1, ``\\href{#7}{#2}'', \\textit{#3} \\textbf{#4}, #5 (#6).
}

\\newcommand{\\ArxivEntry}[3]{
\t\\noindent #1, ``\\href{http://arxiv.org/abs/#3}{#2}'', \\textit{cond-mat/#3}.
}

\\newcommand{\\BookEntry}[4]{
\t\\noindent #1, ``\\href{#3}{#4}'', \\textit{#3}.
}

\\newcommand{\\FundingEntry}[5]{
    \\noindent #1, ``#2'', \\$#3 (#4, #5).
}

\\newcommand{\\TalkEntry}[4]{
\t\\noindent #1, #2, #3 #4
}

\\newcommand{\\ThesisEntry}[5]{
\t\\noindent #1 -- #2 #3 ``#4'' \\textit{#5}
}

\\newcommand{\\CourseEntry}[3]{
\t\\noindent \\item{#1: \\textbf{#2} \\\\ #3}
}

\\begin{document}

\\MyName{{{{name}}}}    % Placeholder for name

\\sepspace
\\sepspace

%%% Personal details
\\NewPart{{}}{{}}    % Empty section

\\PersonalEntry{{Birth}}{{{{birth}}}}           % Placeholder for birth
\\PersonalEntry{{Address}}{{{{address}}}}       % Placeholder for address
\\PersonalEntry{{Phone}}{{{{phone}}}}           % Placeholder for phone
\\PersonalEntry{{Mail}}{{\\url{{{{email}}}}}}   % Placeholder for email
\\PersonalEntry{{Github}}{{\\href{{{{githubURL}}}}{{{{github}}}}}} % Placeholders for GitHub
\\PersonalEntry{{Linkedin}}{{\\href{{{{linkedinURL}}}}{{{{linkedin}}}}}} % Placeholders for LinkedIn

%%% Objective
\\NewPart{{Objective}}{{}}

{{{{objective}}}}    % Placeholder for objective

%%% Education
\\NewPart{{Education}}{{}}

{{{{education_section}}}}    % Placeholder for education section

%%% Skills
\\NewPart{{Skills}}{{}}

{{{{skills_section}}}}    % Placeholder for skills section

%%% Projects
\\NewPart{{Projects}}{{}}

{{{{projects_section}}}}    % Placeholder for projects section

%%% Experience
\\NewPart{{Experiences}}{{}}

{{{{experience_section}}}}    % Placeholder for experience section

\\end{document}
"""



# JOB Finder Moel --------------------------------------------------
@app.route('/api/jobs', methods=['GET'])
def get_jobs():
    app_id = '33a454df'
    app_key = '1805cb4c51d733cbe670bcab85c8818f'
    job_type = request.args.get('job_type', 'internship')
    location = request.args.get('location', 'Egypt')

    api_url = f'https://api.adzuna.com/v1/api/jobs/eg/search/1?app_id={app_id}&app_key={app_key}&what={job_type}&where={location}'

    response = requests.get(api_url)
    if response.status_code == 200:
        return jsonify(response.json())
    else:
        return jsonify({'error': 'Failed to fetch jobs'}), 500




#End Of Job Finder --------------------------------------------------



#Python -> MODEL----------------------------------------------------



# Get the absolute path of the directory containing the script
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

# Configuration
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB max upload size

# Ensure upload folder exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Allowed extensions
ALLOWED_EXTENSIONS = {'pdf'}

# OpenAI API configuration
api_key = os.getenv('OPENAI_API_KEY')
if api_key:
    print("API key is set.")
else:
    print("API key is not set.")
openai.api_key = api_key  # Set the API key for OpenAI

#def allowed_file(filename):
#    return '.' in filename and \
#        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_lecture_number(filename):
    # Extract numbers from the filename using regex
    match = re.findall(r'\d+', filename)
    if match:
        return int(match[0])
    else:
        return None  # Return None if no number is found

def extract_text_from_pdfs(pdf_paths):
    combined_texts = {}
    for pdf_path, lecture_number in pdf_paths:
        print(f"Extracting text from {pdf_path} (Lecture {lecture_number})...")
        try:
            text = extract_text(pdf_path)
            if text:
                combined_texts[lecture_number] = combined_texts.get(lecture_number, '') + text + ' '
            else:
                print(f"No text extracted from {pdf_path}.")
        except Exception as e:
            print(f"Error extracting text from {pdf_path}: {e}")
    return combined_texts  # Returns a dictionary with lecture numbers as keys

def split_text_into_chunks(text, max_length=1000):
    # Adjust the chunk size as needed
    words = text.split()
    chunks = []
    for i in range(0, len(words), max_length):
        chunk = ' '.join(words[i:i + max_length])
        chunks.append(chunk)
    return chunks

def generate_options(correct_answer):
    options = [correct_answer]
    # Generate dummy distractors for simplicity
    for _ in range(3):
        option = ''.join(random.choices(string.ascii_uppercase + string.digits, k=5))
        options.append(option)
    options = options[:4]
    random.shuffle(options)
    return options

def generate_questions(text_chunks, lecture_number, num_questions, num_mcq, num_true_false):
    """
    Generate quiz questions from text chunks using OpenAI API.
    Now includes topic extraction for the recommendation system.

    Args:
        text_chunks: List of text chunks from the PDF
        lecture_number: The lecture number being processed
        num_questions: Total number of questions to generate
        num_mcq: Number of multiple choice questions
        num_true_false: Number of true/false questions

    Returns:
        List of question dictionaries with topic information
    """
    generated_questions = []
    questions_needed = num_questions
    mcq_needed = num_mcq
    tf_needed = num_true_false

    for chunk_index, chunk in enumerate(text_chunks):
        if questions_needed <= 0:
            break

        # Calculate how many questions to generate in this chunk
        chunk_num_mcq = min(mcq_needed, questions_needed)
        chunk_num_true_false = min(tf_needed, questions_needed - chunk_num_mcq)

        # If no questions are needed from this chunk, continue to next
        if chunk_num_mcq + chunk_num_true_false == 0:
            continue

        print(f"Lecture {lecture_number}, Chunk {chunk_index + 1}/{len(text_chunks)}:")
        print(f"  Questions needed: {questions_needed}")
        print(f"  MCQs needed: {mcq_needed}")
        print(f"  True/False needed: {tf_needed}")
        print(f"  Generating {chunk_num_mcq} MCQs and {chunk_num_true_false} True/False questions.")

        # ===== UPDATED PROMPT WITH TOPIC EXTRACTION =====
        prompt = f"""
You are an AI assistant that generates quiz questions based on the given text.

Instructions:
- Generate exactly {chunk_num_mcq + chunk_num_true_false} quiz questions from the text below.
- Include precisely {chunk_num_mcq} multiple-choice questions and {chunk_num_true_false} true/false questions.
- Do not include any questions of a different type.
- **It is crucial that you generate the exact number of each question type as specified.**
- For multiple-choice questions, provide 4 options labeled A, B, C, and D.
- Indicate the correct answer.
- Provide a brief explanation for each answer.
- **IMPORTANT: For each question, identify the main topic/concept being tested. Use a SHORT, clear phrase (2-5 words) that describes the specific concept. Examples: "Photosynthesis", "Cell Division", "DNA Replication", "Newton's Second Law", "Protein Synthesis".**
- Vary the difficulty between easy, medium, and hard.

Text:
\"\"\"
{chunk}
\"\"\"

Please format your response as a JSON array with the following structure:
[
  {{
    "question": "Question text",
    "type": "MCQ",
    "topic": "Brief Topic Name",
    "options": ["A. Option A", "B. Option B", "C. Option C", "D. Option D"],
    "answer": "A",
    "explanation": "Explanation text."
  }},
  {{
    "question": "Question text",
    "type": "True/False",
    "topic": "Brief Topic Name",
    "answer": "True",
    "explanation": "Explanation text."
  }},
  ...
]
"""

        try:
            # Call OpenAI API
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "user", "content": prompt}
                ],
                max_tokens=1500,
                temperature=0.7,
            )
            reply = response['choices'][0]['message']['content'].strip()
            print(f"AI Response:\n{reply}\n")

            # Parse the JSON response
            try:
                quiz_items = json.loads(reply)
            except json.JSONDecodeError as e:
                print(f"JSON decoding error: {e}")
                print("Skipping this chunk due to malformed JSON.")
                continue

            print(f"Received {len(quiz_items)} questions from OpenAI API.")

            # Process each question
            for item in quiz_items:
                question_text = item.get('question', '')
                question_type = item.get('type', '')
                correct_answer = item.get('answer', '')
                explanation_text = item.get('explanation', '')
                options = item.get('options', [])
                # ===== GET TOPIC FROM OPENAI RESPONSE =====
                topic = item.get('topic', 'General Topic')  # Default if OpenAI doesn't provide one

                # Check if we have capacity for this question type
                if question_type == 'MCQ':
                    if mcq_needed <= 0:
                        print("MCQ quota reached. Skipping this MCQ.")
                        continue  # Skip unwanted MCQ
                    # Process MCQ question
                    if not options or len(options) < 4:
                        options = generate_options(correct_answer)
                    question = {
                        'question': question_text,
                        'type': question_type,
                        'lecture': lecture_number,
                        'topic': topic,  # ===== INCLUDE TOPIC =====
                        'answer': correct_answer,
                        'explanation': explanation_text,
                        'options': options
                    }
                    mcq_needed -= 1
                elif question_type == 'True/False':
                    if tf_needed <= 0:
                        print("True/False quota reached. Skipping this True/False question.")
                        continue  # Skip unwanted True/False
                    # Process True/False question
                    question = {
                        'question': question_text,
                        'type': question_type,
                        'lecture': lecture_number,
                        'topic': topic,  # ===== INCLUDE TOPIC =====
                        'answer': correct_answer,
                        'explanation': explanation_text
                    }
                    tf_needed -= 1
                else:
                    print(f"Unrecognized question type: {question_type}. Skipping.")
                    continue  # Skip unrecognized question type

                generated_questions.append(question)
                questions_needed -= 1

                print(f"Question added. Remaining - Questions: {questions_needed}, MCQ: {mcq_needed}, True/False: {tf_needed}")

                if questions_needed <= 0 or (mcq_needed <= 0 and tf_needed <= 0):
                    print("Required number of questions generated for this lecture.")
                    break

        except Exception as e:
            print(f"Exception during OpenAI API call: {e}")
            traceback.print_exc()
            continue

    print(f"Total questions generated for lecture {lecture_number}: {len(generated_questions)}\n")
    return generated_questions




#NEW Endpoint SAve


@app.route('/save_quiz_analysis', methods=['POST'])
def save_quiz_analysis():
    """
    Save detailed quiz analysis data for the recommendation system.

    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456,
        "quiz_results": [
            {"Lecture": "1", "Topic": "Photosynthesis", "Correct": 1},
            {"Lecture": "1", "Topic": "Cell Respiration", "Correct": 0},
            ...
        ]
    }
    """
    try:
        data = request.get_json()

        # Extract data from request
        user_id = data.get('UserID')
        co_id = data.get('co_id')
        quiz_results = data.get('quiz_results')  # Array of {Lecture, Topic, Correct}

        # Validate required fields
        if not all([user_id, co_id, quiz_results]):
            return jsonify({'status': 'error', 'message': 'Missing required data'}), 400

        # Get database connection
        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()

            # Create table if it doesn't exist
            # This table stores individual question results for analysis
            create_table_query = """
            CREATE TABLE IF NOT EXISTS quiz_analysis (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                co_id INT NOT NULL,
                lecture_num VARCHAR(10) NOT NULL,
                topic VARCHAR(255) NOT NULL,
                correct TINYINT(1) NOT NULL COMMENT '1 for correct, 0 for incorrect',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_course (user_id, co_id),
                INDEX idx_topic (topic),
                INDEX idx_correct (correct),
                INDEX idx_created (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """
            cursor.execute(create_table_query)

            # Insert each quiz result
            insert_query = """
            INSERT INTO quiz_analysis (user_id, co_id, lecture_num, topic, correct)
            VALUES (%s, %s, %s, %s, %s)
            """

            for result in quiz_results:
                cursor.execute(insert_query, (
                    user_id,
                    co_id,
                    result['Lecture'],
                    result['Topic'],
                    result['Correct']
                ))

            conn.commit()
            cursor.close()
            conn.close()

            print(f"✅ Quiz analysis saved: {len(quiz_results)} results for user {user_id}, course {co_id}")
            return jsonify({'status': 'success', 'message': 'Quiz analysis saved successfully.'}), 200

        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500

    except Exception as e:
        print(f"❌ Unexpected error in save_quiz_analysis: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500




#New Endpoint
def cluster_topics(topics_list):
    """
    Cluster similar topic names together using fuzzy string matching.

    Args:
        topics_list: List of topic names (strings)

    Returns:
        Dictionary mapping representative topic to list of similar topics

    Example:
        Input: ["Photosynthesis", "Photosynthesis Process", "Cell Division"]
        Output: {"Photosynthesis": ["Photosynthesis", "Photosynthesis Process"],
                 "Cell Division": ["Cell Division"]}
    """
    if not topics_list:
        return {}

    clusters = {}
    used = set()

    # Sort topics by length (longer topics are more specific)
    sorted_topics = sorted(set(topics_list), key=len, reverse=True)

    for topic in sorted_topics:
        if topic in used:
            continue

        # This topic becomes a cluster representative
        cluster_key = topic
        cluster_members = [topic]
        used.add(topic)

        # Find similar topics
        for other_topic in sorted_topics:
            if other_topic in used:
                continue

            # Calculate similarity ratio
            similarity = SequenceMatcher(None, topic.lower(), other_topic.lower()).ratio()

            # Also check if one topic is contained in the other
            contains = (topic.lower() in other_topic.lower() or
                       other_topic.lower() in topic.lower())

            # If similarity is high or one contains the other, cluster them
            if similarity > 0.7 or contains:
                cluster_members.append(other_topic)
                used.add(other_topic)

        clusters[cluster_key] = cluster_members

    return clusters





#New Endpoint
@app.route('/get_weak_topics', methods=['POST'])
def get_weak_topics():
    """
    Get weak topics for a student based on their quiz performance.
    Uses semantic clustering to group similar topic names.

    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456,
        "threshold": 50  (optional, default 50%)
    }

    Returns topics where student's accuracy is below the threshold.
    """
    try:
        data = request.get_json()
        user_id = data.get('UserID')
        co_id = data.get('co_id')
        threshold = data.get('threshold', 50)  # Default: 50% accuracy threshold

        # Validate required fields
        if not all([user_id, co_id]):
            return jsonify({'status': 'error', 'message': 'Missing UserID or co_id'}), 400

        # Get database connection
        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()

            # Get all quiz results for this user and course
            query = """
            SELECT topic, lecture_num, correct
            FROM quiz_analysis
            WHERE user_id = %s AND co_id = %s
            ORDER BY created_at DESC
            """

            cursor.execute(query, (user_id, co_id))
            results = cursor.fetchall()

            if not results:
                cursor.close()
                conn.close()
                return jsonify({
                    'status': 'success',
                    'weak_topics': [],
                    'message': 'No quiz data found for this user and course.'
                }), 200

            # Organize data by topic
            topic_data = {}
            all_topics = []

            for row in results:
                topic = row[0]
                lecture = row[1]
                correct = row[2]

                all_topics.append(topic)

                if topic not in topic_data:
                    topic_data[topic] = {
                        'lecture': lecture,
                        'correct_count': 0,
                        'total_count': 0
                    }

                topic_data[topic]['total_count'] += 1
                if correct == 1:
                    topic_data[topic]['correct_count'] += 1

            # ===== CLUSTER SIMILAR TOPICS =====
            topic_clusters = cluster_topics(all_topics)

            # Aggregate statistics for clustered topics
            clustered_stats = {}
            for cluster_key, cluster_members in topic_clusters.items():
                total_correct = 0
                total_questions = 0
                lectures = set()

                for member in cluster_members:
                    if member in topic_data:
                        total_correct += topic_data[member]['correct_count']
                        total_questions += topic_data[member]['total_count']
                        lectures.add(topic_data[member]['lecture'])

                if total_questions > 0:
                    accuracy = (total_correct / total_questions) * 100
                    clustered_stats[cluster_key] = {
                        'lectures': sorted(list(lectures)),
                        'correct_count': total_correct,
                        'total_count': total_questions,
                        'accuracy': round(accuracy, 2),
                        'related_topics': cluster_members  # Show what was grouped
                    }

            # Filter weak topics (below threshold)
            weak_topics = []
            for topic, stats in clustered_stats.items():
                if stats['accuracy'] < threshold:
                    weak_topics.append({
                        'topic': topic,
                        'lectures': stats['lectures'],
                        'correct_count': stats['correct_count'],
                        'total_count': stats['total_count'],
                        'accuracy': stats['accuracy'],
                        'related_topics': stats['related_topics']
                    })

            # Sort by accuracy (weakest first), then by total questions
            weak_topics.sort(key=lambda x: (x['accuracy'], -x['total_count']))

            cursor.close()
            conn.close()

            print(f"✅ Weak topics retrieved for user {user_id}, course {co_id}: {len(weak_topics)} topics")

            return jsonify({
                'status': 'success',
                'weak_topics': weak_topics,
                'total_weak_topics': len(weak_topics),
                'threshold': threshold
            }), 200

        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500

    except Exception as e:
        print(f"❌ Unexpected error in get_weak_topics: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500



#Infos
@app.route('/get_topic_performance', methods=['POST'])
def get_topic_performance():
    """
    Get overall performance summary for all topics in a course.
    Useful for displaying statistics and progress.

    Expected JSON format:
    {
        "UserID": 123,
        "co_id": 456
    }
    """
    try:
        data = request.get_json()
        user_id = data.get('UserID')
        co_id = data.get('co_id')

        if not all([user_id, co_id]):
            return jsonify({'status': 'error', 'message': 'Missing UserID or co_id'}), 400

        conn = get_connection()
        if not conn:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()

            # Get aggregated performance by topic
            query = """
            SELECT
                topic,
                COUNT(*) as total_questions,
                SUM(correct) as correct_answers,
                (SUM(correct) / COUNT(*)) * 100 as accuracy,
                GROUP_CONCAT(DISTINCT lecture_num ORDER BY lecture_num) as lectures
            FROM quiz_analysis
            WHERE user_id = %s AND co_id = %s
            GROUP BY topic
            ORDER BY accuracy ASC, total_questions DESC
            """

            cursor.execute(query, (user_id, co_id))
            results = cursor.fetchall()

            performance_data = []
            for row in results:
                performance_data.append({
                    'topic': row[0],
                    'total_questions': row[1],
                    'correct_answers': row[2],
                    'accuracy': round(row[3], 2),
                    'lectures': row[4].split(',') if row[4] else []
                })

            cursor.close()
            conn.close()

            return jsonify({
                'status': 'success',
                'performance': performance_data,
                'total_topics': len(performance_data)
            }), 200

        except mysql.connector.Error as err:
            print(f"❌ Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {str(err)}'}), 500

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500





#from urllib.parse import urlparse, urlunparse, parse_qs

def convert_dropbox_url(url):
    """
    Convert a Dropbox shared link to a direct download link.
    Handles both old and new Dropbox URL formats.
    """
    parsed_url = urlparse(url)

    # Check if the URL is from Dropbox
    if 'dropbox.com' in parsed_url.netloc:
        # Replace 'www.dropbox.com' or 'dropbox.com' with 'dl.dropboxusercontent.com'
        netloc = parsed_url.netloc.replace('www.dropbox.com', 'dl.dropboxusercontent.com').replace('dropbox.com', 'dl.dropboxusercontent.com')
        # Remove query parameters
        new_url = urlunparse(('https', netloc, parsed_url.path, '', '', ''))
        return new_url
    # If it's not a Dropbox link, return it as is
    return url


@app.route('/submit_quiz', methods=['POST'])
def submit_quiz():
    try:
        data = request.get_json()

        # Print the received data for debugging
        print("Received data:", data)

        # Extract data from the request
        user_id = data.get('UserID')
        user_ans = data.get('UserAns')  # CSV string
        quiz_ans = data.get('QuizAns')  # CSV string
        lec_num = data.get('LecNum')    # CSV string
        co_id = data.get('co_id')       # Get co_id from data

        # Validate data
        if not all([user_id, user_ans, quiz_ans, lec_num, co_id]):
            print("Missing data in the request")
            return jsonify({'status': 'error', 'message': 'Missing data'}), 400

        # Connect to the database using get_connection()
        conn = get_connection()
        if not conn:
            print("Database connection failed")
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()

            # Insert data into the Quiz table, including co_id
            # Insert data into the Quiz table, including co_id
            insert_query = """
            INSERT INTO Quiz (UserID, UserAns, QuizAns, LecNum, co_id)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (user_id, user_ans, quiz_ans, lec_num, co_id))
            conn.commit()

            # Close the connection
            cursor.close()
            conn.close()

            print("Quiz results saved successfully")
            return jsonify({'status': 'success', 'message': 'Quiz results saved.'}), 200

        except mysql.connector.Error as err:
            # Print detailed database error
            print(f"Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': 'Database error'}), 500

    except Exception as e:
        # Print detailed exception information
        print(f"An unexpected error occurred: {e}")
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': 'Server error'}), 500


@app.route('/generate_quiz', methods=['POST'])
def generate_quiz():
    try:
        data = request.get_json()
        if data is None:
            return jsonify({'error': 'Invalid JSON sent in request'}), 400
        print('Received Data:', data)

        # Extract parameters from the request
        co_id = data.get('co_id')
        selected_lectures = data.get('selected_lectures', None)
        lecture_start = int(data.get('lecture_start', 1))
        lecture_end = int(data.get('lecture_end', 999))
        num_questions = int(data.get('number_of_questions', 5))
        num_mcq = int(data.get('num_mcq', 0))
        num_true_false = int(data.get('num_true_false', 0))

        if not co_id:
            return jsonify({'error': 'co_id is required.'}), 400

        # Convert co_id to integer if necessary
        co_id = int(co_id)
        print(f"co_id received: {co_id}")

        # Connect to the database to get course_name using co_id
        conn = get_connection()
        if not conn:
            print("Database connection failed")
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()
            print("Database connection established. Executing query...")
            cursor.execute("SELECT COName FROM Courses WHERE COId = %s", (co_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            if not result:
                print("No course found with the provided co_id.")
                return jsonify({'error': 'Invalid co_id. Course not found.'}), 404
            course_name = result[0]
            print(f"Course name retrieved: {course_name}")
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {err}'}), 500

        # Sanitize course_name if needed (e.g., remove spaces)
        course_name = course_name.strip().replace(' ', '')

        # Construct the path to the course directory
        course_dir = os.path.join(BASE_DIR, 'lectures', course_name)
        if not os.path.exists(course_dir):
            return jsonify({'error': f'Course directory not found: {course_dir}'}), 404

        # Get list of PDFs in the course directory
        all_files = os.listdir(course_dir)
        pdf_files = [f for f in all_files if allowed_file(f)]

        if not pdf_files:
            return jsonify({'error': 'No lecture files found for the course.'}), 400

        # Filter PDFs based on selected lectures or lecture range
        pdf_paths = []
        for filename in pdf_files:
            lecture_number = extract_lecture_number(filename)
            if lecture_number is None:
                print(f"No lecture number found in file name {filename}. Skipping this file.")
                continue  # Skip files without lecture numbers
            
            # Use selected_lectures if provided, otherwise fall back to range
            if selected_lectures is not None:
                if lecture_number in selected_lectures:
                    file_path = os.path.join(course_dir, filename)
                    pdf_paths.append((file_path, lecture_number))
                else:
                    print(f"File {filename} (lecture {lecture_number}) not in selected lectures. Skipping.")
            else:
                if lecture_start <= lecture_number <= lecture_end:
                    file_path = os.path.join(course_dir, filename)
                    pdf_paths.append((file_path, lecture_number))
                else:
                    print(f"File {filename} is outside the specified lecture range. Skipping this file.")

        if not pdf_paths:
            return jsonify({'error': 'No valid files within the specified lecture range.'}), 400

        # Extract text from PDFs
        combined_texts = extract_text_from_pdfs(pdf_paths)

        if not combined_texts:
            return jsonify({'error': 'No text could be extracted from the PDFs.'}), 400

        all_questions = []

        # Distribute MCQ and True/False counts among lectures
        total_lectures = len(combined_texts)
        lecture_numbers = sorted(combined_texts.keys())

        # Initialize counts per lecture
        lecture_mcq_counts = [0] * total_lectures
        lecture_tf_counts = [0] * total_lectures

        remaining_mcq = num_mcq
        remaining_tf = num_true_false

        # First pass: assign base counts to each lecture
        for idx in range(total_lectures):
            base_mcq_per_lecture = num_mcq // total_lectures
            base_tf_per_lecture = num_true_false // total_lectures

            lecture_mcq_counts[idx] = base_mcq_per_lecture
            lecture_tf_counts[idx] = base_tf_per_lecture

            remaining_mcq -= base_mcq_per_lecture
            remaining_tf -= base_tf_per_lecture

        # Second pass: distribute remaining counts
        idx = 0
        while remaining_mcq > 0:
            lecture_mcq_counts[idx % total_lectures] += 1
            remaining_mcq -= 1
            idx += 1

        idx = 0
        while remaining_tf > 0:
            lecture_tf_counts[idx % total_lectures] += 1
            remaining_tf -= 1
            idx += 1

        # Now, set lecture_question_counts based on mcq and tf counts
        lecture_question_counts = [lecture_mcq_counts[i] + lecture_tf_counts[i] for i in range(total_lectures)]

        # Confirm that total questions assigned equals num_questions
        total_assigned_questions = sum(lecture_question_counts)
        if total_assigned_questions != num_questions:
            print(f"Total assigned questions ({total_assigned_questions}) does not match requested total ({num_questions}).")
            # Adjust the last lecture to fix the discrepancy
            difference = num_questions - total_assigned_questions
            lecture_question_counts[-1] += difference

        # Now, generate questions for each lecture using the counts
        for idx, lecture_number in enumerate(lecture_numbers):
            text = combined_texts[lecture_number]
            print(f"Processing Lecture {lecture_number}...")
            # Split text into chunks
            text_chunks = split_text_into_chunks(text)
            print(f"Number of text chunks for Lecture {lecture_number}: {len(text_chunks)}")

            # Get the counts for this lecture
            lecture_num_questions = lecture_question_counts[idx]
            lecture_num_mcq = lecture_mcq_counts[idx]
            lecture_num_true_false = lecture_tf_counts[idx]

            # Skip lectures with zero questions
            if lecture_num_questions == 0:
                continue

            print(f"Lecture {lecture_number}:")
            print(f"  Total Questions: {lecture_num_questions}")
            print(f"  MCQs: {lecture_num_mcq}")
            print(f"  True/False: {lecture_num_true_false}")

            # Generate questions
            print(f"Generating {lecture_num_questions} questions for Lecture {lecture_number}...")
            questions = generate_questions(
                text_chunks,
                lecture_number,
                lecture_num_questions,
                lecture_num_mcq,
                lecture_num_true_false
            )

            all_questions.extend(questions)

        if not all_questions:
            return jsonify({'error': 'No questions could be generated.'}), 500

        # Verify that total questions generated match the requested number
        if len(all_questions) != num_questions:
            print(f"Warning: Generated {len(all_questions)} questions, but {num_questions} were requested.")

        # Return the generated quiz as JSON
        response_data = {'questions': all_questions , 'paths' : pdf_paths }
        return jsonify(response_data), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({'error': f'An internal error occurred: {e}'}), 500



PDF_GENERATION_SERVER_URL = "http://alyalawa.pythonanywhere.com/generate_paper_quiz"

def generate_doctor_quiz(co_id, lecture_start, lecture_end, num_questions, num_mcq, num_true_false, selected_lectures=None):
    try:

        if not co_id:
            return jsonify({'error': 'co_id is required.'}), 400

        # Convert co_id to integer if necessary
        co_id = int(co_id)
        print(f"co_id received: {co_id}")

        # Connect to the database to get course_name using co_id
        conn = get_connection()
        if not conn:
            print("Database connection failed")
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        try:
            cursor = conn.cursor()
            print("Database connection established. Executing query...")
            cursor.execute("SELECT COName FROM Courses WHERE COId = %s", (co_id,))
            result = cursor.fetchone()
            cursor.close()
            conn.close()

            if not result:
                print("No course found with the provided co_id.")
                return jsonify({'error': 'Invalid co_id. Course not found.'}), 404
            course_name = result[0]
            print(f"Course name retrieved: {course_name}")
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
            traceback.print_exc()
            return jsonify({'status': 'error', 'message': f'Database error: {err}'}), 500

        # Sanitize course_name if needed (e.g., remove spaces)
        course_name = course_name.strip().replace(' ', '')

        # Construct the path to the course directory
        course_dir = os.path.join(BASE_DIR, 'lectures', course_name)
        if not os.path.exists(course_dir):
            return jsonify({'error': f'Course directory not found: {course_dir}'}), 404

        # Get list of PDFs in the course directory
        all_files = os.listdir(course_dir)
        pdf_files = [f for f in all_files if allowed_file(f)]

        if not pdf_files:
            return jsonify({'error': 'No lecture files found for the course.'}), 400

        # Filter PDFs based on selected lectures or lecture range
        pdf_paths = []
        for filename in pdf_files:
            lecture_number = extract_lecture_number(filename)
            if lecture_number is None:
                print(f"No lecture number found in file name {filename}. Skipping this file.")
                continue  # Skip files without lecture numbers
            
            # Use selected_lectures if provided, otherwise fall back to range
            if selected_lectures is not None:
                if lecture_number in selected_lectures:
                    file_path = os.path.join(course_dir, filename)
                    pdf_paths.append((file_path, lecture_number))
                else:
                    print(f"File {filename} (lecture {lecture_number}) not in selected lectures. Skipping.")
            else:
                if lecture_start <= lecture_number <= lecture_end:
                    file_path = os.path.join(course_dir, filename)
                    pdf_paths.append((file_path, lecture_number))
                else:
                    print(f"File {filename} is outside the specified lecture range. Skipping this file.")

        if not pdf_paths:
            return jsonify({'error': 'No valid files within the specified lecture range.'}), 400

        # Extract text from PDFs
        combined_texts = extract_text_from_pdfs(pdf_paths)

        if not combined_texts:
            return jsonify({'error': 'No text could be extracted from the PDFs.'}), 400

        all_questions = []

        # Distribute MCQ and True/False counts among lectures
        total_lectures = len(combined_texts)
        lecture_numbers = sorted(combined_texts.keys())

        # Initialize counts per lecture
        lecture_mcq_counts = [0] * total_lectures
        lecture_tf_counts = [0] * total_lectures

        remaining_mcq = num_mcq
        remaining_tf = num_true_false

        # First pass: assign base counts to each lecture
        for idx in range(total_lectures):
            base_mcq_per_lecture = num_mcq // total_lectures
            base_tf_per_lecture = num_true_false // total_lectures

            lecture_mcq_counts[idx] = base_mcq_per_lecture
            lecture_tf_counts[idx] = base_tf_per_lecture

            remaining_mcq -= base_mcq_per_lecture
            remaining_tf -= base_tf_per_lecture

        # Second pass: distribute remaining counts
        idx = 0
        while remaining_mcq > 0:
            lecture_mcq_counts[idx % total_lectures] += 1
            remaining_mcq -= 1
            idx += 1

        idx = 0
        while remaining_tf > 0:
            lecture_tf_counts[idx % total_lectures] += 1
            remaining_tf -= 1
            idx += 1

        # Now, set lecture_question_counts based on mcq and tf counts
        lecture_question_counts = [lecture_mcq_counts[i] + lecture_tf_counts[i] for i in range(total_lectures)]

        # Confirm that total questions assigned equals num_questions
        total_assigned_questions = sum(lecture_question_counts)
        if total_assigned_questions != num_questions:
            print(f"Total assigned questions ({total_assigned_questions}) does not match requested total ({num_questions}).")
            # Adjust the last lecture to fix the discrepancy
            difference = num_questions - total_assigned_questions
            lecture_question_counts[-1] += difference

        # Now, generate questions for each lecture using the counts
        for idx, lecture_number in enumerate(lecture_numbers):
            text = combined_texts[lecture_number]
            print(f"Processing Lecture {lecture_number}...")
            # Split text into chunks
            text_chunks = split_text_into_chunks(text)
            print(f"Number of text chunks for Lecture {lecture_number}: {len(text_chunks)}")

            # Get the counts for this lecture
            lecture_num_questions = lecture_question_counts[idx]
            lecture_num_mcq = lecture_mcq_counts[idx]
            lecture_num_true_false = lecture_tf_counts[idx]

            # Skip lectures with zero questions
            if lecture_num_questions == 0:
                continue

            print(f"Lecture {lecture_number}:")
            print(f"  Total Questions: {lecture_num_questions}")
            print(f"  MCQs: {lecture_num_mcq}")
            print(f"  True/False: {lecture_num_true_false}")

            # Generate questions
            print(f"Generating {lecture_num_questions} questions for Lecture {lecture_number}...")
            questions = generate_questions(
                text_chunks,
                lecture_number,
                lecture_num_questions,
                lecture_num_mcq,
                lecture_num_true_false
            )

            all_questions.extend(questions)

        if not all_questions:
            return jsonify({'error': 'No questions could be generated.'}), 500

        # Verify that total questions generated match the requested number
        if len(all_questions) != num_questions:
            print(f"Warning: Generated {len(all_questions)} questions, but {num_questions} were requested.")

        # Return the generated quiz as JSON
        response_data = {'questions': all_questions , 'paths' : pdf_paths }
        return jsonify(response_data), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({'error': f'An internal error occurred: {e}'}), 500


@app.route('/generate_paper_quiz', methods=['POST'])
def generate_paper_quiz():
    try:
        data = request.get_json()
        if data is None:
            return jsonify({'error': 'Invalid JSON sent in request'}), 400

        print('Received Data:', data)

        # Extract parameters from the request
        doc_id = data.get('doc_id')  # Assuming the doc_id is provided in the request
        co_id = data.get('co_id')
        lecture_start = int(data.get('lecture_start', 1))
        lecture_end = int(data.get('lecture_end', 999))
        num_questions = int(data.get('number_of_questions', 5))
        num_mcq = int(data.get('num_mcq', 0))
        num_true_false = int(data.get('num_true_false', 0))
        num_copies = int(data.get('num_copies', 1))  # Number of copies/models

        # Call the generate_quiz function to generate quiz questions
        quiz_response, status_code = generate_doctor_quiz(co_id, lecture_start, lecture_end, num_questions, num_mcq, num_true_false)
        print('generation done')
        if status_code != 200:
            return jsonify({'error': 'Failed to generate quiz', 'details': quiz_response}), 500
        print('quiz response: ')
        print(type(quiz_response))
        quiz_data = quiz_response.get_json()   # quiz_response is already a dictionary
        print('quiz data')
        print(quiz_data)
        # Shuffle the questions to ensure each copy is unique
        shuffle_quiz_data(quiz_data)
        print('data suffled')
        # Insert the quiz into the paper_quizzes table only once
        quiz_id = insert_paper_quiz_to_db(doc_id, co_id, num_copies)
        print('data inserted')
        # Prepare a temporary in-memory zip file to hold all generated PDFs
        zip_io = io.BytesIO()
        with zipfile.ZipFile(zip_io, mode='w', compression=zipfile.ZIP_DEFLATED) as zipf:
            for i in range(num_copies):
                # Shuffle the quiz data before generating each model to ensure uniqueness
                shuffle_quiz_data(quiz_data)

                # Save the model's answers in the paper_quiz_models table
                model_num = i + 1  # Model number for this copy
                save_model_answers_to_db(quiz_data, quiz_id, model_num)

                # Send the quiz data to the PDF generation server to generate a PDF for each copy
                pdf_response = requests.post(
                    PDF_GENERATION_SERVER_URL,
                    json=quiz_data
                )
                print(type(pdf_response))
                # Check if PDF generation was successful
                if pdf_response.status_code != 200:
                    return jsonify({'error': 'Failed to generate PDF from quiz data', 'details': pdf_response.text}), 500

                # Add the generated PDF to the zip file
                pdf_file = pdf_response.content  # Assuming the PDF content is returned as raw bytes
                zipf.writestr(f"generated_quiz_{i+1}.pdf", pdf_file)

        # Set the cursor to the beginning of the zip file
        zip_io.seek(0)

        # Return the zip file containing all the PDFs
        return send_file(
            zip_io,
            as_attachment=True,
            download_name="generated_quizzes.zip",
            mimetype='application/zip'
        )

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({'error': f'An internal error occurred: {e}'}), 500

def shuffle_quiz_data(quiz_data):
    """
    Shuffle the questions and options within the quiz data to ensure that the generated quizzes are unique.
    """
    # Shuffle the order of questions
    random.shuffle(quiz_data["questions"])

    # Shuffle the order of options for each MCQ question
    for question in quiz_data["questions"]:
        if question["type"] == "mcq":  # Only shuffle MCQ options
            random.shuffle(question["options"])

def insert_paper_quiz_to_db(doc_id, co_id, num_copies):
    # Insert the paper quiz into the paper_quizzes table once and return the quiz ID
    try:
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO paper_quizzes (DocID, CoID, model_num)
            VALUES (%s, %s, %s)
        """, (doc_id, co_id, num_copies))
        connection.commit()
        quiz_id = cursor.lastrowid  # Get the ID of the newly inserted quiz
        cursor.close()
        connection.close()
        return quiz_id
    except Exception as e:
        print(f"Error inserting paper quiz into DB: {e}")
        raise

def save_model_answers_to_db(quiz_data, quiz_id, model_num):
    # Save the model's answers in the paper_quiz_models table
    try:
        # Initialize lists to hold MCQ and TF answers separately
        mcq_answers = []
        tf_answers = []

        # Loop through each question to segregate MCQ and TF answers
        for question in quiz_data['questions']:
            if question['type'].upper() == 'MCQ':  # Multiple-choice question
                correct_answer = question.get('answer')  # The correct answer text
                options = question.get('options')  # The list of answer options
                print(question)
                print(correct_answer)
                print(options)
                # Find the letter corresponding to the correct answer (a, b, c, d, etc.)
                for option in options:
                    if correct_answer.upper() == option[0].upper():
                        answer_letter = chr(65 + options.index(option))  # Convert index to letter (a, b, c, d, ...)
                        mcq_answers.append(answer_letter)  # Add MCQ answer letter to the list
                        break

            elif question['type'] == 'True/False':  # True/False question
                correct_answer = question.get('answer')  # The correct answer (True/False)

                # Store "t" for True and "f" for False
                tf_answers.append('t' if correct_answer == 'True' else 'f')

        # Convert the lists to strings (for storage in the database)
        mcq_answers_str = ','.join(mcq_answers)  # MCQ answers as a comma-separated string
        tf_answers_str = ','.join(tf_answers)    # TF answers as a comma-separated string

        # Insert the answers into paper_quiz_models table (storing MCQs in MCQ column and TF in TF column)
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO paper_quiz_models (quiz_id, MCQ, TF)
            VALUES (%s, %s, %s)
        """, (quiz_id, mcq_answers_str, tf_answers_str))
        connection.commit()
        cursor.close()
        connection.close()
    except Exception as e:
        print(f"Error saving model answers to DB: {e}")
        raise

@app.route('/PreviousQuizzes', methods=['POST'])
def get_previous_quizzes():
    try:
        data = request.get_json()
        if not data or 'id' not in data:
            return jsonify({'error': 'Missing user ID'}), 400

        user_id = data['id']

        conn = get_connection()
        if not conn:
            return jsonify({'error': 'Database connection failed'}), 500

        cursor = conn.cursor()

        query = """
            SELECT
                pq.ID,
                c.COName AS QuizName,
                pq.model_num AS QuizModel
            FROM
                paper_quizzes pq
            JOIN
                Courses c ON pq.CoID = c.COId
            JOIN
                paper_quiz_models pqm ON pqm.quiz_id = pq.ID
            WHERE
                pq.DocId = %s
        """
        cursor.execute(query, (user_id,))
        results = cursor.fetchall()

        quiz_ids = []
        quiz_names = []
        quiz_models = []

        for row in results:
            quiz_ids.append(str(row[0]))
            quiz_names.append(row[1])
            quiz_models.append(str(row[2]))

        cursor.close()
        conn.close()

        return jsonify({
            'QuizID': quiz_ids,
            'QuizName': quiz_names,
            'QuizModel': quiz_models
        }), 200

    except Exception as e:
        print(f"Error in /PreviousQuizzes: {e}")
        traceback.print_exc()
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/CourseQuizzes', methods=['POST'])
def course_quizzes():
    try:
        data = request.get_json()
        course_id = data.get('courseId')

        if not course_id:
            return jsonify({'error': 'courseId is required'}), 400

        conn = get_connection()
        cursor = conn.cursor()

        query = """
            SELECT
                pq.ID,
                pq.model_num
            FROM
                paper_quizzes pq
            JOIN
                paper_quiz_models pqm ON pq.ID = pqm.quiz_id
            WHERE
                pq.CoID = %s
        """
        cursor.execute(query, (course_id,))
        results = cursor.fetchall()

        quiz_ids = [str(row[0]) for row in results]
        quiz_models = [str(row[1]) for row in results]

        cursor.close()
        conn.close()

        return jsonify({'QuizID': quiz_ids, 'QuizModel': quiz_models})

    except Exception as e:
        print(f"Error in /CourseQuizzes: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/UploadQuizImages', methods=['POST'])
def upload_quiz_images():
    try:
        quiz_id = request.form.get('quizId')
        model = request.form.get('model')
        images = request.files.getlist('images')

        if not quiz_id or not model or not images:
            return jsonify({'error': 'Missing data'}), 400

        upload_folder = f'uploads/quiz_{quiz_id}_model_{model}'
        os.makedirs(upload_folder, exist_ok=True)

        for img in images:
            img.save(os.path.join(upload_folder, img.filename))

        return jsonify({'message': f'{len(images)} images uploaded successfully'}), 200

    except Exception as e:
        print(f"Error uploading images: {e}")
        return jsonify({'error': str(e)}), 500


#End of MODEL ------------------------------------------------------------


# app = Flask(__name__)


# Database connection helper
def get_connection():
    try:
        conn = mysql.connector.connect(
            host="AlyIbrahim.mysql.pythonanywhere-services.com",
            user="AlyIbrahim",
            password="I@ly170305",  # Use envi  ronment variables in production
            database="AlyIbrahim$StudyMate"
        )
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None


# Function to hash a password
def hash_password(password):
    salt = os.urandom(32)  # Generate a random salt
    hashed_password = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt,
        100000
    )
    combined_password = base64.b64encode(salt + hashed_password).decode('utf-8')
    return combined_password


# Function to verify a password
def verify_password(stored_password, provided_password):
    decoded_password = base64.b64decode(stored_password.encode('utf-8'))
    salt = decoded_password[:32]
    hashed_password = hashlib.pbkdf2_hmac(
        'sha256',
        provided_password.encode('utf-8'),
        salt,
        100000
    )
    return decoded_password[32:] == hashed_password

# Registration endpoint
@app.route('/register', methods=['POST'])
def register_user():
    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    # Retrieve data from JSON body
    data = request.get_json()
    username = data.get('username', 'unknown')
    password = data.get('password', 'unknown')
    name = data.get('fullName', 'unknown')
    role = data.get('role', 'student')
    email = data.get('email', 'unknown')
    phone_number = data.get('phoneNumber', 'unknown')
    address = data.get('address', 'unknown')
    gender = data.get('gender', 'unknown')
    college = data.get('college', 'unknown')
    university = data.get('university', 'unknown')
    major = data.get('major', 'unknown')
    term_level = data.get('term_level', 0)
    profile_picture_link = data.get('pfp', 'unknown')
    experience_points = data.get('xp', 0)
    level = data.get('level', 0)
    title = data.get('title', 'unknown')
    registrationNumber = data.get('registrationNumber', 0)
    birthdate = data.get('birthDate', 'unknown')

    # Hash the password securely
    hashed_password = hash_password(password)

    # SQL Query to insert user
    query = """
    INSERT INTO user (
        username, password, name, role, email,
        phone_number, address, gender, college, university,
        major, term_level, profile_picture_link, experience_points, level, title, Registration_Number, BirthDate
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    try:
        with conn.cursor() as cursor:
            # Execute the query with user-provided data
            cursor.execute(query, (
                username, hashed_password, name, role, email, phone_number, address, gender,
                college, university, major, term_level, profile_picture_link, experience_points,
                level, title, registrationNumber, birthdate
            ))
            conn.commit()

            # Check if user was inserted successfully
            if cursor.rowcount == 1:
                now = datetime.now()
                last_modification = now.strftime("%Y-%m-%d %H:%M:%S")
                cursor.execute("""
                    INSERT INTO last_modifications (username, last_modification)
                    VALUES (%s, %s)
                    ON DUPLICATE KEY UPDATE last_modification = VALUES(last_modification)
                """, (username, last_modification))
                conn.commit()

                response = {'message': 'User registered successfully'}
            else:
                response = {'message': 'User not added'}

    except Exception as e:
        print(f"Error during registration: {e}")
        response = {'message': 'An error occurred during registration'}
    finally:
        conn.close()

    return jsonify(response)


def update_streak(user_id):
    conn = get_connection()
    if not conn:
        return False
    try:
        with conn.cursor(dictionary=True) as cursor:
            # Fetch last_login, day_streak, max_streak for the user
            cursor.execute("""
                SELECT last_login, day_streak, max_streak
                FROM user
                WHERE id = %s;
            """, (user_id,))
            result = cursor.fetchone()
            if result:
                last_login = result['last_login']
                day_streak = result['day_streak'] or 0
                max_streak = result['max_streak'] or 0

                # Get today's date and yesterday's date
                today = datetime.today().date()
                yesterday = today - timedelta(days=1)

                # Check if last_login is not None and is a datetime object
                if last_login:
                    if isinstance(last_login, datetime):
                        last_login_date = last_login.date()
                    elif isinstance(last_login, date):
                        last_login_date = last_login
                    else:
                        # If last_login is not a datetime or date object, handle accordingly
                        app.logger.error(f"Invalid last_login type: {type(last_login)}")
                        last_login_date = None
                else:
                    # If last_login is None, treat as not logged in before
                    last_login_date = None

                if last_login_date == yesterday:
                    # Increment day_streak
                    day_streak += 1
                elif last_login_date == today:
                    # Already logged in today, no change to day_streak
                    return False
                else:
                    # Reset day_streak to 1 (since they logged in today)
                    day_streak = 1

                # Update max_streak if current day_streak is greater
                if day_streak > max_streak:
                    max_streak = day_streak

                # Update last_login to today
                cursor.execute("""
                    UPDATE user
                    SET last_login = %s, day_streak = %s, max_streak = %s
                    WHERE id = %s;
                """, (datetime.now(), day_streak, max_streak, user_id))
                conn.commit()
                return True
            else:
                return False  # User not found
    except Exception as e:
        app.logger.error(f"Error during update_streak: {e}")
        return False
    finally:
        conn.close()

# Modified Login endpoint with update_streak integration
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': 'Invalid username or password'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        with conn.cursor(dictionary=True) as cursor:
            # Query to fetch the relevant user data from the database
            cursor.execute("""
                SELECT id, username, password, name, role, email, phone_number, address, gender,
                       college, university, major, term_level, profile_picture_link,
                       experience_points, level, title, registration_number, birthdate ,day_streak , max_streak
                FROM user
                WHERE username = %s;
            """, (username,))
            user = cursor.fetchone()

            # If user exists in database
            if user:
                stored_password = user['password']
                if verify_password(stored_password, password):  # Compare hashed password
                    # Update the login streak
                    get_xp = update_streak(user['id'])
                    cursor.execute("""
                        SELECT id, username, password, name, role, email, phone_number, address, gender,
                               college, university, major, term_level, profile_picture_link,
                               experience_points, level, title, registration_number, birthdate ,day_streak , max_streak ,last_login
                        FROM user
                        WHERE username = %s;
                    """, (username,))
                    user = cursor.fetchone()

                    # Exclude sensitive data and prepare the response
                    user_data = {
                        'message': 'Login successful',
                        'success': True,
                        'id': user['id'],
                        'username': user['username'],
                        'name': user['name'],
                        'role': user['role'],
                        'email': user['email'],
                        'phone_number': user['phone_number'],
                        'address': user['address'],
                        'gender': user['gender'],
                        'college': user['college'],
                        'university': user['university'],
                        'major': user['major'],
                        'term_level': user['term_level'],
                        'pfp': user['profile_picture_link'],
                        'xp': user['experience_points'],
                        'level': user['level'],
                        'title': user['title'],
                        'registrationNumber': user['registration_number'],
                        'birthDate': user['birthdate'],
                        'day_streak' : user['day_streak'],
                        'max_streak' : user['max_streak'],
                        'last_login' : user['last_login'],
                        'get_xp' : get_xp,
                    }
                    app.logger.debug('Login successful: %s', user_data)
                    return jsonify(user_data), 200

            # If no valid user is found or password is incorrect
            return jsonify({'message': 'Invalid username or password'}), 401
    except Exception as e:
        app.logger.error(f"Error during login: {e}")
        return jsonify({'message': 'An error occurred during login'}), 500
    finally:
        conn.close()


# Debugging and testing endpoint
@app.route('/', methods=['GET'])
def home():
    return jsonify({'message': 'Welcome to ElBatal StudyMate API!'})

# POST: Create a new schedule
@app.route('/schedule', methods=['POST'])
def create_schedule():
    try:
        # Parse JSON payload
        data = request.json
        user_id = data['user_id']
        title = data['title']
        date = datetime.strptime(data['date'], '%Y-%m-%d')
        start_time = datetime.strptime(data['start_time'], '%H:%M:%S').time()
        end_time = datetime.strptime(data['end_time'], '%H:%M:%S').time()
        category = data.get('category')
        recurrence = data.get('recurrence', 'None')
        repeat_end_date = data.get('repeat_end_date')

        # Create Schedule Entry
        schedule = Schedule(
            user_id=user_id,
            title=title,
            date=date,
            start_time=start_time,
            end_time=end_time,
            category=category,
            recurrence=recurrence,
            repeat_end_date=repeat_end_date
        )
        db.session.add(schedule)
        db.session.commit()

        # Return success message
        return jsonify({"message": "Schedule created successfully!"}), 200
    except Exception as e:
        print(f"Error during schedule creation: {e}")
        return jsonify({"message": "An error occurred while creating the schedule"}), 500

# GET: Fetch user's schedules by date range
@app.route('/schedule', methods=['GET'])
def get_schedule():
    try:
        # Parse query parameters
        user_id = request.args.get('user_id')
        start_date_str = request.args.get('start_date')
        end_date_str = request.args.get('end_date')

        # Validate parameters
        if not user_id or not start_date_str or not end_date_str:
            return jsonify({"message": "Missing required query parameters"}), 400

        # Parse the dates
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({"message": "Invalid date format"}), 400

        # Establish database connection
        conn = get_connection()
        if not conn:
            return jsonify({"message": "Database connection error"}), 500

        # Perform raw SQL query
        cursor = conn.cursor(dictionary=True)  # Use dictionary cursor
        query = """
        SELECT *
        FROM Schedule
        WHERE UserId = %s AND Date BETWEEN %s AND %s;
        """
        cursor.execute(query, (user_id, start_date, end_date))
        schedules = cursor.fetchall()
        cursor.close()
        conn.close()

        # Serialize datetime and timedelta objects into JSON-compatible strings
        serialized_schedules = []
        for schedule in schedules:
            serialized_schedules.append({
                "Sid": schedule["Sid"],
                "UserId": schedule["UserId"],
                "Title": schedule["Title"],
                "Date": schedule["Date"].strftime('%Y-%m-%d'),  # Convert date to string
                "StartTime": (datetime.min + schedule["StartTime"]).strftime('%H:%M:%S'),  # Convert timedelta to time string
                "EndTime": (datetime.min + schedule["EndTime"]).strftime('%H:%M:%S'),  # Convert timedelta to time string
                "Category": schedule["Category"],
                "Description": schedule["Description"],
                "Location": schedule["Location"],
                "ReminderBefore": schedule["ReminderBefore"],
                "Repeatance": schedule["Repeatance"],
                "RepeatEndDate": schedule["RepeatEndDate"].strftime('%Y-%m-%d') if schedule["RepeatEndDate"] else None,  # Convert date to string
                "CreatedAt": schedule["CreatedAt"].strftime('%Y-%m-%d %H:%M:%S')  # Convert datetime to string
            })

        return jsonify(serialized_schedules), 200

    except Exception as e:
        print(f"Error while fetching schedules: {e}")
        return jsonify({"message": "An error occurred while fetching the schedule"}), 500




@app.route('/AddSchedule', methods=['POST'])
def add_schedule():
    data = request.get_json()

    # Extract data from the JSON body
    user_id = data.get('id')
    title = data.get('title')
    date = data.get('date')
    start_time = data.get('startTime')
    end_time = data.get('endTime')
    location = data.get('location')
    category = data.get('category')
    repeat = data.get('repeat')
    description = data.get('description')
    reminder_time = data.get('reminderTime')
    repeat_until = data.get('repeatUntil')

    try:
        # Establish connection to the database
        db = get_connection()
        cursor = db.cursor()
        cursor2 = db.cursor()
        # Prepare the SQL INSERT query
        insert_query = """
        INSERT INTO Schedule (UserId, Title, Date, StartTime, EndTime, Category, Description, Location, ReminderBefore, Repeatance, RepeatEndDate)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        query2 = """
        INSERT INTO notifications (title, body , user_id)
        VALUES(%s, %s, %s);
        """
        # Execute the query with the data
        cursor.execute(insert_query, (user_id, title, date, start_time, end_time, category, description, location, reminder_time, repeat, repeat_until))
        print("schedule added successfully")
        cursor2.execute(query2,(title, description , user_id,))
        print("notification added successfully")
        # Commit the transaction
        db.commit()

        # Return a success response
        return jsonify({"message": "Schedule added successfully!"}), 200

    except Exception as e:
        db.rollback()  # Rollback in case of error
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()  # Close the cursor
        cursor2.close()
        db.close()  # Close the database connection


from flask import request, jsonify

@app.route('/tasks/<task_id>/duplicate', methods=['POST'])
def duplicate_task(task_id):
    original = mongo.db.tasks.find_one({"_id": ObjectId(task_id)})
    if not original:
        return jsonify({"error": "Task not found"}), 404

    # Remove the original ID and optionally update the createdAt
    original.pop('_id')
    original['createdAt'] = datetime.utcnow()

    # Merge any fields from the client request (like deadline, name, etc.)
    updated_fields = request.json or {}
    original.update(updated_fields)

    # Insert the new (duplicated) task
    result = mongo.db.tasks.insert_one(original)
    new_task = mongo.db.tasks.find_one({"_id": result.inserted_id})

    # Convert ObjectId to string for response
    new_task['_id'] = str(new_task['_id'])
    return jsonify(new_task), 201



@app.route('/delete_task', methods=['POST'])
def delete_Schedule():
    data = request.get_json()
    Sid = data.get('Sid')

    if not Sid:
        return jsonify({'error': 'Sid is required'}), 400  # Bad Request if Sid is missing

    try:
        db = get_connection()
        cursor = db.cursor()

        # Prepare SQL delete statement
        sql_delete_query = "DELETE FROM Schedule WHERE Sid = %s"
        cursor.execute(sql_delete_query, (Sid,))
        db.commit()

        # Check if any row was affected (i.e., deleted)
        if cursor.rowcount == 0:
            # No schedule found with the given Sid
            cursor.close()
            db.close()
            return jsonify({'error': 'No schedule found with the given Sid'}), 404

        cursor.close()
        db.close()
        return jsonify({'message': 'Schedule deleted successfully'}), 200

    except Exception as e:
        print("Error while deleting schedule:", e)
        return jsonify({'error': 'An error occurred while deleting the schedule.'}), 500


@app.route('/get_recent_quizzes', methods=['GET'])
def get_recent_quizzes():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'status': 'error', 'message': 'user_id parameter is required'}), 400
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch the most recent 2 quizzes for the user
        query = '''
        SELECT *
        FROM Quiz
        WHERE UserID = %s
        ORDER BY QID DESC
        LIMIT 2
        '''
        cursor.execute(query, (user_id,))
        quizzes = cursor.fetchall()

        # Process each quiz to calculate Score and TotalScore
        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list[:num_questions], quiz_answers_list[:num_questions]) if ua.strip() == qa.strip())

            # Set the Score and TotalScore for each quiz
            quiz['Score'] = num_correct
            quiz['TotalScore'] = num_questions

        cursor.close()
        conn.close()
        return jsonify({'status': 'success', 'quizzes': quizzes}), 200
    except Exception as e:
        app.logger.error(f"Error in get_recent_quizzes: {e}")
        return jsonify({'status': 'error', 'message': 'Internal server error'}), 500

@app.route('/register_courses', methods=['POST'])
def register_courses():
    data = request.get_json()
    username = data.get('username')
    courses = data.get('Courses',[])  # List of course names
    print(username)
    print(courses)
    if not username or not courses:
        return jsonify({'error': 'Missing username or courses'}), 400
    try:
        db = get_connection()
        cursor = db.cursor()

        # Prepare to fetch course IDs and insert into register table
        for course_name in courses:
            # Get the course ID from the courses table
            cursor.execute(
                "SELECT COId FROM Courses WHERE COName = %s",
                (course_name,)
            )
            result = cursor.fetchone()

            if result:
                course_id = result[0]
                print(course_id)
                # Insert into the register table
                cursor.execute(
                    "INSERT INTO Register (username, COId) VALUES (%s, %s)",
                    (username, course_id)
                )
            else:
                return jsonify({'error': f'Course not found: {course_name}'}), 404

        db.commit()  # Commit all changes
        cursor.close()
        db.close()
        return jsonify({'success': 'Courses registered successfully'}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/TakeCourses', methods=['POST'])
def get_courses_for_user():
    try:

        data = request.get_json()
        username = data.get('username') # Use query parameters
        if not username:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            # distinct حل مؤقت لحد مشوف الفانكشن اللى فوق
            "SELECT distinct COId FROM Register WHERE username = %s",
            (username,)
        )
        course_ids = cursor.fetchall()

        if not course_ids:
            return jsonify({'error': f'No courses found for username: {username}'}), 200

        subjects = []
        for course in course_ids:
            cursor.execute(
                "SELECT COName FROM Courses WHERE COId = %s",
                (course['COId'],)
            )
            course_name = cursor.fetchone()
            if course_name:
                subjects.append(course_name['COName'])
            else:
                return jsonify({'error': f'Course ID not found in Courses table: {course["COId"]}'}), 404

        cursor.close()
        db.close()

        return jsonify({'username': username, 'courses': subjects , 'CourseID' : course_ids}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500



@app.route('/CourseContent', methods=['POST'])
def get_courses_Content():
    try:
        data = request.get_json()
        Cidx = data.get('courseIdx') # Use query parameters
        username = data.get('username')
        if not Cidx:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)
        cursor2 =db.cursor()
        cursor.execute(
            "SELECT  RFileURL , RName , CID , RId FROM Resources WHERE COId = %s",
            (Cidx,)
        )
        CourseInfo = cursor.fetchall()
        cursor2.execute(
                 "UPDATE Register SET recentEnter  = CURRENT_TIMESTAMP  WHERE ( COId = %s and username = %s ) ",
                (Cidx,username,)
        )
        db.commit();

        if not CourseInfo:
            return jsonify({'error': f'No courses found for Cidx: {Cidx}'}), 404

        subjects = []
        for info in CourseInfo:
            subject = {
                'RFileURL': info['RFileURL'],
                'RName': info['RName'],
                'RCat' : info['CID'],
                'RId' : info['RId'],
            }
            subjects.append(subject)
        cursor.close()
        cursor2.close()
        db.close()

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify({'subInfo': subjects}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

#OMAR ASHRAF COURSE-----------------------------

@app.route('/removeCourse', methods=['POST'])
def remove_course():
    try:
        data = request.get_json()
        username = data.get('username')
        course_id = data.get('course_id')

        if not username or not course_id:
            return jsonify({'error': 'Username and course_id are required'}), 400

        # Connect to database
        connection = mysql.connector.connect(
            host='your_host',
            database='your_database',
            user='your_user',
            password='your_password'
        )

        if connection.is_connected():
            cursor = connection.cursor()

            # Delete from Register table using COId and username
            # Register table structure: COId, username, recentEnter, id
            delete_query = """
                DELETE FROM Register
                WHERE username = %s AND COId = %s
            """
            cursor.execute(delete_query, (username, course_id))
            connection.commit()

            if cursor.rowcount > 0:
                return jsonify({'success': 'Course removed successfully'}), 200
            else:
                return jsonify({'error': 'Course not found for this user'}), 404

    except Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': f'Database error: {str(e)}'}), 500
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
#END OF COURSE




@app.route('/update_user', methods=['POST'])
def update_user():
    data = request.get_json()
    username = data.get('username')

    # Ensure username is provided (it's required for identifying the user)
    if not username:
        return jsonify({'message': 'Username is required'}), 400

    # Fields to update
    fields = {
        'name': data.get('fullName'),
        'email': data.get('email'),
        'password': hash_password(data['password']) if data.get('password') else None,
        'phone_number': data.get('phone_number'),
        'birthDate': data.get('birthDate'),
        'address': data.get('address'),
        'college': data.get('college'),
        'university': data.get('university'),
        'major': data.get('major'),
        'term_level': data.get('term_level'),
        'Registration_Number' : data.get('Registration_Number'),
    }

    # Filter out None or empty values
    fields_to_update = {key: value for key, value in fields.items() if value}

    if not fields_to_update:
        return jsonify({'message': f'No data to update'}), 400

    # Build the query dynamically
    set_clause = ", ".join(f"{key} = %s" for key in fields_to_update.keys())
    values = list(fields_to_update.values()) + [username]

    query = f"UPDATE user SET {set_clause} WHERE username = %s"

    # Database connection
    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        with conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, values)
            conn.commit()

            if cursor.rowcount == 1:
                response = {'message': 'User updated successfully'}
            else:
                response = {'message': f'No changes made or user not found {username}'}

            return jsonify(response), 200
    except Exception as e:
        app.logger.error(f"Error during update_user: {e}")
        return jsonify({'message': f'An error occurred during update_user {e}'}), 500
    finally:
        if conn:
            conn.close()


@app.route('/updateMaterial', methods=['POST'])
def updateMaterial():
    try:
        data = request.get_json()
        Midx = data.get('materialIdx')
        MTitle = data.get('materialTitle')
        Mcat = data.get('materialMcat')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "UPDATE Resources SET RName  = %s , CID = %s  WHERE RId = %s",
                (MTitle,Mcat,Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resources updated successfully'}
        else:
                response = {'message': 'No changes made or Resources not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
# from flask import Flask, request, jsonify
# from flask import Flask, request, jsonify
@app.route('/get_courses_answered', methods=['POST'])
def get_courses_answered():
    data = request.get_json()
    id = data['ID']
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # SQL query to get the number of quizzes completed per course for the given student
        query = """
        select co_id, COName , count(*) as NumberOfQuizzes from Quiz q inner join Courses c on q.co_id = c.COID where q.userId = %s group by COName
        """

        cursor.execute(query, (id,))
        result = cursor.fetchall()

        cursor.close()
        conn.close()
        return jsonify(result), 200
    except Exception as e:
        # Handle exceptions, such as database errors
        return jsonify({'error': str(e)}), 500

@app.route('/get_course_insights', methods=['POST'])
def get_course_insights():
    data = request.get_json()
    user_id = data['ID']
    course_id = data['co_id']
    print(user_id)
    print(course_id)
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch total quizzes taken in the course
        query_total_quizzes = """
        SELECT COUNT(*) AS total_quizzes
        FROM Quiz g
        WHERE g.UserID = %s AND g.co_id = %s
        """
        cursor.execute(query_total_quizzes, (user_id, course_id))
        total_quizzes_result = cursor.fetchone()
        total_quizzes_taken = total_quizzes_result['total_quizzes']

        # Fetch average score in the course
        query_avg_score = """
        SELECT UserAns, QuizAns FROM Quiz WHERE UserID = %s and co_id = %s
        """
        cursor.execute(query_avg_score, (user_id, course_id))
        quizzes = cursor.fetchall()
        total_quizzes = len(quizzes)
        total_score = 0
        total_questions = 0
        solved_questions = 0

        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list, quiz_answers_list) if ua == qa)

            # Calculate score as a percentage
            percentage_score = (num_correct / num_questions) * 100 if num_questions > 0 else 0
            total_score += percentage_score
            total_questions += num_questions
            solved_questions += num_correct

        if total_quizzes > 0:
            average_score = total_score / total_quizzes
        else:
            average_score = 0


        # Build response
        response = {
            'total_quizzes_taken': total_quizzes_taken,
            'average_score': average_score,
            'solved_questions': solved_questions,
            'total_questions': total_questions,
            # Add more data as needed
        }

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/get_insights', methods=['POST'])
def get_insights():
    data = request.get_json()
    if not data or 'ID' not in data:
        return jsonify({'error': 'User ID is missing in the request body.'}), 400

    userID = data.get('ID')
    try:
        conn = get_connection()

        # Use a dictionary cursor to fetch rows as dictionaries
        cursor = conn.cursor(dictionary=True)

        # Query to get all quizzes taken by the user
        query = '''
        SELECT UserAns, QuizAns FROM Quiz WHERE UserID = %s
        '''
        cursor.execute(query, (userID,))
        quizzes = cursor.fetchall()

        # Query to get streak information for the user
        query2 = "SELECT day_streak, max_streak FROM user WHERE id = %s"
        cursor.execute(query2, (userID,))
        streak = cursor.fetchone()

        # Handle case where user is not found
        if streak is None:
            streak = {'day_streak': 0, 'max_streak': 0}

        total_quizzes = len(quizzes)
        total_score = 0

        for quiz in quizzes:
            user_ans = quiz['UserAns']
            quiz_ans = quiz['QuizAns']

            # Convert the answers from strings to lists
            user_answers_list = user_ans.split(',')
            quiz_answers_list = quiz_ans.split(',')

            # Ensure both lists have the same length
            num_questions = min(len(user_answers_list), len(quiz_answers_list))

            # Compute the number of correct answers
            num_correct = sum(1 for ua, qa in zip(user_answers_list, quiz_answers_list) if ua == qa)

            # Calculate score as a percentage
            percentage_score = (num_correct / num_questions) * 100 if num_questions > 0 else 0
            total_score += percentage_score

        if total_quizzes > 0:
            average_score = total_score / total_quizzes
        else:
            average_score = 0

        # Return the total number of quizzes, average score, and streak information
        return jsonify({
            'total_quizzes': total_quizzes,
            'average_score': average_score,
            'day_streak': streak['day_streak'],
            'max_streak': streak['max_streak']
        }), 200

    except Exception as e:
        # Log the error (optional)
        print(f"Error retrieving insights for user {userID}: {e}")
        return jsonify({'error': 'An error occurred while fetching data.'}), 500

    finally:
        cursor.close()
        conn.close()
@app.route('/deleteMaterial', methods=['POST'])
def deleteMaterial():
    try:
        data = request.get_json()
        Midx = data.get('materialIdx')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM Resources WHERE RId = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resourcses deleted successfully'}
        else:
                response = {'message': 'No changes made or Resources not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/addMaterial', methods=['POST'])
def addMaterial():
    try:
        data = request.get_json()
        Murl = data.get('materialUrl')
        MTitle = data.get('materialTitle')
        Mcat = data.get('materialMcat')
        SID = data.get('subid')
        if not Murl:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "insert into Resources (Rname , RFileURL , CID ,COId ) values (%s , %s , %s, %s )  ",
                (MTitle,Murl,Mcat,SID,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'Resourcses Added successfully'}
        else:
                response = {'message': 'No changes made'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


@app.route('/recentCourses', methods=['POST'])
def recentCourses():
    try:

        data = request.get_json()
        username = data.get('username') # Use query parameters
        if not username:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)
        query = """
                SELECT * FROM Register
                where username = %s
                ORDER BY recentEnter DESC;
        """

        cursor.execute(
            query,(username,)
        )
        course_ids = cursor.fetchall()

        if not course_ids:
            return jsonify({'error': f'No courses found for username: {username}'}), 404

        subjects = []
        i = 0
        for course in course_ids:
            cursor.execute(
                "SELECT COName FROM Courses WHERE COId = %s",
                (course['COId'],)
            )
            course_name = cursor.fetchone()
            if course_name:
                subjects.append(course_name['COName'])
            else:
                return jsonify({'error': f'Course ID not found in Courses table: {course["COId"]}'}), 404
            i += 1
            if i == 2 :
                break
        cursor.close()
        db.close()

        return jsonify({'username': username, 'courses': subjects , 'CourseID' : course_ids}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500




@app.route('/upload-image', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in the request'}), 400

    image = request.files['image']
    username = request.form.get('username')

    if image.filename == '':
        return jsonify({'error': 'No image selected for uploading'}), 400

    # Get the current working directory
    current_dir = os.getcwd()

    # Print the current working directory
    print(f"Current directory: {current_dir}")
    # Save the file locally or process it
    image.save(f'../pfpImages/PFP_{username}')


    db = get_connection()  # Assuming get_connection() connects to your database
    cursor = db.cursor()

    update_query = """
    UPDATE user
    SET profile_picture_link = %s
    WHERE username = %s
    """
    cursor.execute(update_query, (f'../pfpImages/PFP_{username}', username))
    db.commit()

    if cursor.rowcount == 1:
        response = {'message': 'Image uploaded and profile updated successfully'}
    else:
        response = {'error': 'User not found or no changes made'}

    cursor.close()
    db.close()

    return jsonify({'message': response}), 200




def encode_image_to_base64(image_path):
    try:
        # Open the image file in binary mode
        with open(image_path, 'rb') as image_file:
            # Read the binary data
            binary_data = image_file.read()
            # Encode the binary data to Base64
            base64_encoded = base64.b64encode(binary_data).decode('utf-8')
        return base64_encoded
    except Exception as e:
        print(f"Error: {e}")
        return None



@app.route('/get_users',methods=['GET'])
def get_users():
    print('>>> \n')
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        query = "select * from user"
        cursor.execute(query)
        result = cursor.fetchall()

        serialized_users = []

        for user in result:
            serialized_users.append({
                'id': user['id'],
                'username': user['username'],
                'name': user['name'],
                'pfp': user['profile_picture_link'],
                'xp': user['experience_points'],
                'title': user['title'],
            })

        for user in serialized_users:
            user['pfp']=encode_image_to_base64(user['pfp'])
        cursor.close()
        conn.close()
        return jsonify(serialized_users), 200


    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500  # Return 500 in case of any exception




@app.route('/set_xp', methods=['POST'])
def set_xp():
    data = request.get_json()
    username = data.get('username')
    new_xp = data.get('xp')

    if not username or new_xp is None:
        return jsonify({'message': 'Username and xp are required'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        cursor = conn.cursor()
        query = "UPDATE user SET experience_points = %s WHERE username = %s"
        cursor.execute(query, (new_xp, username))
        conn.commit()

        if cursor.rowcount == 1:
            response = {'message': 'XP updated successfully'}
        else:
            response = {'message': 'User not found or no changes made'}

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        conn.rollback()
        print(f"Error updating XP: {e}")
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500

@app.route('/set_title', methods=['POST'])
def set_title():
    data = request.get_json()
    username = data.get('username')
    new_title = data.get('title')

    if not username or not new_title:
        return jsonify({'message': 'Username and title are required'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'message': 'Database connection error'}), 500

    try:
        cursor = conn.cursor()
        query = "UPDATE user SET title = %s WHERE username = %s"
        cursor.execute(query, (new_title, username))
        conn.commit()

        if cursor.rowcount == 1:
            response = {'message': 'Title updated successfully'}
        else:
            response = {'message': 'User not found or no changes made'}

        cursor.close()
        conn.close()
        return jsonify(response), 200
    except Exception as e:
        conn.rollback()
        print(f"Error updating title: {e}")
        return jsonify({'message': f'An error occurred: {str(e)}'}), 500

@app.route('/get-profile-image', methods=['POST'])
def get_profile_image():
    data = request.get_json()  # Receive JSON data from the request
    username = data.get('username')  # Extract the 'username' field from the request

    if not username:
        return jsonify({'error': 'Username is required'}), 400  # Error if no username is provided

    try:
        # Fetch the image path from the database
        db = get_connection()  # Assuming get_connection() connects to your database
        cursor = db.cursor()

        query = "SELECT profile_picture_link FROM user WHERE username = %s"
        cursor.execute(query, (username,))
        result = cursor.fetchone()

        cursor.close()
        db.close()

        if not result or not result[0]:
            return jsonify({'error': 'No profile picture found for this user'}), 404  # Return 404 if no image is found

        image_path = result[0]  # The image path fetched from the database

        print(image_path)

        # Check if the image file exists
        if not os.path.exists(image_path):
            return jsonify({'error': 'Image not found at the specified path'}), 404  # If the file is not found, return 404

        # Return the image file with proper MIME type (adjust MIME type as needed)
        return send_file(image_path, mimetype='image/jpeg')  # Assuming it's a JPEG, change the mimetype if needed

    except Exception as e:
        # Log the exception to understand what went wrong
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500  # Return 500 in case of any exception



#BEGINNING OF NOTIFICATION----------------------------------------------------

@app.route('/getNotification', methods=['POST'])
def fetchOnNotifications():
    try:

        data = request.get_json()
        id = data.get('username') # Use query parameters
        if not id:
            return jsonify({'error': 'Missing username'}), 400

        db = get_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute(
            # distinct حل مؤقت لحد مشوف الفانكشن اللى فوق
            "SELECT title , body , id FROM notifications WHERE user_id = %s",
            (id,)
        )
        notifications = cursor.fetchall()

        if not notifications:
            return jsonify({'error': f'No courses found for id: {id}'}), 404
        cursor.close()
        db.close()

        return jsonify({'notifications': notifications}), 200

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/deleteNotification', methods=['POST'])
def deleteNotification():
    try:
        data = request.get_json()
        Midx = data.get('notificationId')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM notifications WHERE id = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'notification deleted successfully'}
        else:
                response = {'message': 'No changes made or notification not found'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/deleteAllNotifications', methods=['POST'])
def deleteAllNotifications():
    try:
        db = get_connection()
        cursor2 =db.cursor()
        cursor1 =db.cursor()
        cursor1.execute("SELECT COUNT(*) FROM notifications")
        total_rows = cursor1.fetchone()[0]

        cursor2.execute("TRUNCATE TABLE notifications;" )
        db.commit();
        cursor2.close()
        cursor1.close()
        db.close()
        if cursor2.rowcount == total_rows:
            response = {'message': 'All notifications deleted successfully'}
        elif cursor2.rowcount > 0:
            response = {'message': 'Some notifications deleted successfully'}
        else:
            response = {'message': 'No notifications found or no changes made'}
        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


#OMAR ASHRAF CODE FOR NOTIFICATION
@app.route('/storeNotification', methods=['POST'])
def store_notification():
    """
    Store a notification in the database

    Request body (JSON):
    {
        "user_id": int,
        "title": str,
        "body": str,
        "type": str (optional) - e.g., "fcm", "scheduled", "quiz", "assignment", "rank"
        "metadata": dict (optional) - additional data as JSON
    }
    """
    try:
        data = request.get_json()

        # Validate required fields
        if not data or 'user_id' not in data or 'title' not in data or 'body' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Missing required fields: user_id, title, body'
            }), 400

        user_id = data['user_id']
        title = data['title']
        body = data['body']
        notification_type = data.get('type', 'general')  # Default to 'general'
        metadata = data.get('metadata', None)

        # Connect to database (use your actual connection details)
        db = mysql.connector.connect(
            host="your_host",
            user="your_username",
            password="your_password",
            database="your_database"
        )
        cursor = db.cursor()

        # Insert notification into database
        query = """
            INSERT INTO notifications (user_id, title, body, created_at, is_read, type, metadata)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        # Convert metadata dict to JSON string if provided
        metadata_json = json.dumps(metadata) if metadata else None

        values = (
            user_id,
            title,
            body,
            datetime.now(),
            False,  # is_read defaults to False
            notification_type,
            metadata_json
        )

        cursor.execute(query, values)
        db.commit()

        notification_id = cursor.lastrowid

        cursor.close()
        db.close()

        return jsonify({
            'status': 'success',
            'message': 'Notification stored successfully',
            'notification_id': notification_id
        }), 200

    except mysql.connector.Error as err:
        return jsonify({
            'status': 'error',
            'message': f'Database error: {str(err)}'
        }), 500

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Server error: {str(e)}'
        }), 500



#END OF NOTIFICATION----------------------------------------


def sanitize_latex(text):
    if not text:
        return ''
    replacements = {
        '\\': r'\textbackslash{}',
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
    }
    for original, replacement in replacements.items():
        text = text.replace(original, replacement)
    return text



def Generate_CV(latex_code):
    # Encode the LaTeX code for inclusion in the URL
    encoded_latex = urllib.parse.quote(latex_code)
    print('Generating...')
    try :
        # API endpoint
        url = f'https://latexonline.cc/compile?text={encoded_latex}'

        # Send GET request
        response = requests.get(url)

        print("CV API Part")
        # Check the response
        if response.status_code == 200 and response.headers['Content-Type'] == 'application/pdf':
            with open('output.pdf', 'wb') as f:
                f.write(response.content)
            print("PDF generated successfully and saved as 'output.pdf'.")
        else:
            print("Failed to compile LaTeX code.")
            print("Status Code:", response.status_code)
            print("Response:", response.text)
    except Exception as error:
        print(error)




# @app.route('/GenerateCV', methods=['POST'])
# def generate_cv_latex():
#     print("Generating CV")
#     data = request.get_json()
#     print(data)
#     # Define the LaTeX template with placeholders

#     # Helper function to escape LaTeX special characters

#     print(latex_template)
#     try :

#         # Prepare personal details
#         name = sanitize_latex(data.get('name', ''))
#         birth = sanitize_latex(data.get('birth', ''))
#         address = sanitize_latex(data.get('address', ''))
#         phone = sanitize_latex(data.get('phone', ''))
#         email = sanitize_latex(data.get('email', ''))
#         github = sanitize_latex(data['github']['name'])
#         githubURL = sanitize_latex(data['github']['githubURL'])
#         linkedin = sanitize_latex(data['linkedin']['name'])
#         linkedinURL = sanitize_latex(data['linkedin']['linkedinURL'])
#         objective = sanitize_latex(data.get('objective', ''))



#         # Prepare Education section
#         education_entries = []
#         for entry in data.get('education', []):
#             degree = sanitize_latex(entry.get('degree', ''))
#             years = sanitize_latex(entry.get('years', ''))
#             institution = sanitize_latex(entry.get('institution', ''))
#             description_lines = [sanitize_latex(line) for line in entry.get('descriptions', [])]
#             description = r'\\'.join(description_lines)
#             education_entry = r'\EducationEntry{{{}}}{{{}}}{{{}}}{{{}}} \sepspace'.format(degree, years, institution, description)
#             education_entries.append(education_entry)
#         education_section = '\n'.join(education_entries)

#         print("1 ..............")
#         # Prepare Skills section
#         skills_entries = []
#         print(data.get('skills', []))
#         for skills in data.get('skills', []):
#             print(skills)
#             sanitized_category = sanitize_latex(skills['head'])
#             sanitized_skills = ', '.join(sanitize_latex(skill) for skill in skills['skills'])
#             # Create a LaTeX command or environment for each skill category
#             skills_entry = r'\textbf{{{}}}: {} \\\\'.format(sanitized_category, sanitized_skills)
#             skills_entries.append(skills_entry)
#         skills_section = '\n'.join(skills_entries)


#         print(f"2 .............. {skills_section}")

#         # Prepare Projects section
#         # Prepare Projects section
#         projects_items = []
#         for project_dict in data.get('projects', []):
#             for title, description in project_dict.items():
#                 sanitized_title = sanitize_latex(title)
#                 sanitized_description = sanitize_latex(description)
#                 project_entry = r'\item \textbf{{{}}}: {}'.format(sanitized_title, sanitized_description)
#                 projects_items.append(project_entry)
#         projects_section = r'\begin{itemize}' + '\n' + '\n'.join(projects_items) + '\n' + r'\end{itemize}'
#         print("1.5 ........... {projects_section}")
#         # Prepare Experience section
#         experience_items = [r'\item {}'.format(sanitize_latex(exp)) for exp in data.get('experience', [])]
#         print(f"2.5 .............. {experience_items}")
#         experience_section = r'\begin{itemize}' + '\n\n' + ''.join(experience_items) + '\n' + r'\end{itemize}'


#         print(f"3 .............. {experience_section}")


#         # Replace placeholders in the template
#         latex_code = latex_template.replace('{{{{name}}}}', name)
#         latex_code = latex_code.replace('{{{{birth}}}}', birth)
#         latex_code = latex_code.replace('{{{{address}}}}', address)
#         latex_code = latex_code.replace('{{{{phone}}}}', phone)
#         latex_code = latex_code.replace('{{{{email}}}}', email)
#         latex_code = latex_code.replace('{{{{github}}}}', github)
#         latex_code = latex_code.replace('{{{{githubURL}}}}', githubURL)
#         latex_code = latex_code.replace('{{{{linkedin}}}}', linkedin)
#         latex_code = latex_code.replace('{{{{linkedinURL}}}}', linkedinURL)
#         latex_code = latex_code.replace('{{{{objective}}}}', objective)
#         latex_code = latex_code.replace('{{{{education_section}}}}', education_section)
#         latex_code = latex_code.replace('{{{{skills_section}}}}', skills_section)
#         latex_code = latex_code.replace('{{{{projects_section}}}}', projects_section)
#         latex_code = latex_code.replace('{{{{experience_section}}}}', experience_section)


#         print(latex_code)

#         Generate_CV(latex_code)
#         return jsonify("Done"), 200
#     except error:
#         print("Error geerating CV")
#         return jsonify(f"Error {error}") , 400



# @app.route('/test')
# def test():
#     try:
#         response = requests.get("https://latexonline.cc")
#         # ret(response.status_code)
#         return f"<pre>{response.status_code}</pre>"
#     except Exception as e:
#         print(f"Error: {e}")
#         return f"<pre>{e}</pre>"
#     return f"<pre>{latex_template}</pre>"

CORS(app)  # Configure CORS as needed

# Database Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://<AlyIbrahim>:<I@ly170305>@<AlyIbrahim.mysql.pythonanywhere-services.com>/<AlyIbrahim$StudyMate>'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
dbb = SQLAlchemy(app)

# Model
class User(dbb.Model):
    id = dbb.Column(dbb.Integer, primary_key=True)
    username = dbb.Column(dbb.String(50), nullable=False)
    email = dbb.Column(dbb.String(120), unique=True, nullable=False)
    experience_points = dbb.Column(dbb.Integer, nullable=False)

# Create tables (if not already created)

# Define the User model

# Route to fetch all users from the database


@app.route('/getUsersWeb', methods=['POST'])
def getUsersWeb():
    try:
        # Establish the database connection
        db = get_connection()
        cursor = db.cursor()

        # Execute the query to fetch all users
        cursor.execute("SELECT * FROM user;")
        users = cursor.fetchall()

        # Check if there are users
        if not users:
            return jsonify({'error': 'No users found'}), 404

        # Format users data for JSON response
        users_list = []
        for user in users:
            users_list.append({
                'id': user[0],  # Assuming 'id' is the first column
                'username': user[1],  # Assuming 'username' is the second column
                'email': user[5],  # Assuming 'email' is the third column
                'experience_points': user[14]  # Assuming 'experience_points' is the fourth column
            })

        cursor.close()
        db.close()

        # Return the users data as JSON
        return jsonify({'users': users_list}), 200

    except mysql.connector.Error as err:
        # Handle MySQL connection or query errors
        return jsonify({'error': str(err)}), 500







@app.route('/getInsightsWeb', methods=['POST'])
def getInsightsWeb():
    try:
        # Connect to the database
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)  # Adjust based on your DB connector

        # Fetch necessary data from Quiz table
        query = "SELECT UserAns, QuizAns, LecNum, co_id FROM Quiz"
        cursor.execute(query)
        quiz_insights = cursor.fetchall()

        # Data processing for the line chart (Quizzes per Lecture)
        quizzes_per_lecture = defaultdict(int)
        for row in quiz_insights:
            lec_num = row['LecNum']
            quizzes_per_lecture[lec_num] += 1

        # Sort the lectures numerically
        sorted_lectures = sorted(quizzes_per_lecture.keys())
        line_chart_data = {
            'labels': [str(lec) for lec in sorted_lectures],
            'counts': [quizzes_per_lecture[lec] for lec in sorted_lectures]
        }

        # Data processing for the doughnut chart (Quizzes per Course)
        quizzes_per_course = defaultdict(int)
        for row in quiz_insights:
            course_id = row['co_id']
            quizzes_per_course[course_id] += 1

        # Get the unique course IDs
        course_ids = list(quizzes_per_course.keys())

        # Fetch course names from Courses table for the given course IDs
        # Build the IN clause with placeholders
        placeholders = ','.join(['%s'] * len(course_ids))
        query2 = "SELECT COId, COName FROM Courses WHERE COId IN (%s)" % placeholders

        # Execute query2 to get course names
        cursor.execute(query2, course_ids)
        course_rows = cursor.fetchall()

        # Build the mapping from COId to COName
        course_names = { row['COId']: row['COName'] for row in course_rows }

        # Build the labels using course names
        labels = [course_names.get(co_id, str(co_id)) for co_id in quizzes_per_course.keys()]
        counts = list(quizzes_per_course.values())

        doughnut_chart_data = {
            'labels': labels,
            'counts': counts
        }

        # Prepare the combined data
        result = {
            'line_chart': line_chart_data,
            'doughnut_chart': doughnut_chart_data
        }

        # Close the connection
        conn.close()

        return jsonify(result), 200

    except Exception as e:
        print(f"Error in getInsightsWeb: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/deleteUserWeb', methods=['POST'])
def deleteuser():
    try:
        data = request.get_json()
        Midx = data.get('username')
        if not Midx:
            return jsonify({'error': 'Missing Midx'}), 400

        db = get_connection()
        cursor2 =db.cursor()

        cursor2.execute(
                 "DELETE FROM user WHERE username = %s",
                (Midx,)
        )
        db.commit();
        cursor2.close()
        db.close()

        if cursor2.rowcount == 1:
                response = {'message': 'user deleted successfully'}
        else:
                response = {'message': 'No changes made or user'}

        # return jsonify({'URL': subjects['RFileURL'], 'Name': subjects['RName']}), 200
        # return jsonify({'courses': [{'URL': subject['RFileURL'], 'Name': subject['RName']} for subject in subjects]}), 200
        return jsonify(response), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500


def send_message(message,subject,reciever_email,
                 EMAIL_ADDRESS='elbatalstudymatesystem@gmail.com',
                 EMAIL_PASSWORD = 'irnh kmlg mfkn wtfe'
                 ):
    # For example, using Gmail's SMTP server
    SMTP_SERVER = 'smtp.gmail.com'
    SMTP_PORT = 587  # Use 465 for SSL, 587 for TLS

    # Email credentials and server configuration
    # EMAIL_ADDRESS = 'elbatalstudymatesystem@gmail.com'  # Replace with your email address
    # EMAIL_PASSWORD = 'irnh kmlg mfkn wtfe'  # Replace with your email password

    # Email content
    msg = EmailMessage()
    msg['Subject'] = subject  # todo change this
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = reciever_email  # Replace with the recipient's email address
    msg.set_content(message)

    try:
        # Create a secure SSL/TLS connection
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as smtp:
            smtp.ehlo()
            smtp.starttls()  # Secure the connection
            smtp.ehlo()
            smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            smtp.send_message(msg)
            return 'Email sent successfully!'
    except Exception as e:
        return f'An error occurred: {e}'


def generate_otp(length=6):
    # Generate a random OTP
    otp = ''.join(random.choices(string.digits, k=length))
    return otp


@app.route('/Send_OTP', methods=['POST'])
def send_otp():
    data = request.get_json()
    reciever_name=data.get('fullname')
    reciever_email=data.get('email')
    OTP=generate_otp()
    message=f'''Dear {reciever_name},

            Your OTP for Elbatal Studymate apllication is: {OTP}. Please keep this code confidential. It will expire in 5 minutes.

            Thank you,
            Elbatal Team
            '''
    try :
        response = send_message(message,"Elbatal Studymate application OTP",reciever_email)
        return jsonify({
            'response' : response,
            'OTP':OTP}), 200
    except Exception as err:
        return jsonify({'error': str(err)}), 500



# Route to check if the email exists
@app.route('/check-email', methods=['POST'])
def check_email():
    data = request.get_json()

    if 'email' not in data:
        return jsonify({'error': 'Email is required'}), 400

    email = data['email']

    try:
        # Get a database connection
        conn = get_connection()
        cursor = conn.cursor()

        # Correct query with parameterized SQL
        cursor.execute('SELECT * FROM user WHERE email = %s', (email,))  # Ensure parameters are passed as a tuple
        result = cursor.fetchone()

        if result:
            # Email found, return isUsed as True
            return jsonify({'isUsed': True}), 200
        else:
            # Email not found, return isUsed as False
            return jsonify({'isUsed': False}), 200

    except Exception as e:
        # Handle any errors during database operation
        return jsonify({'error': str(e)}), 500
    finally:
        # Close the connection to the database
        if conn:
            conn.close()

# Define the LaTeX template with placeholders
latex_template = r"""
\documentclass[paper=letter,fontsize=11pt]{scrartcl}

\usepackage[english]{babel}
\usepackage[utf8x]{inputenc}
\usepackage[protrusion=true,expansion=true]{microtype}
\usepackage{amsmath,amsfonts,amsthm}
\usepackage{graphicx}
\usepackage[svgnames]{xcolor}
\usepackage{geometry}
\usepackage[colorlinks=true, linkcolor=blue, urlcolor=blue]{hyperref}
\usepackage{float}
\usepackage{etaremune}
\usepackage{wrapfig}
\usepackage{attachfile}

\frenchspacing
\pagestyle{empty}

\setlength\topmargin{0pt}
\addtolength\topmargin{-\headheight}
\addtolength\topmargin{-\headsep}
\setlength\oddsidemargin{0pt}
\setlength\textwidth{\paperwidth}
\addtolength\textwidth{-2in}
\setlength\textheight{\paperheight}
\addtolength\textheight{-2in}
\usepackage{layout}

%%% Custom sectioning (sectsty package)
\usepackage{sectsty}
\sectionfont{
	\usefont{OT1}{phv}{b}{n}
	\sectionrule{0pt}{0pt}{-5pt}{1pt}
}

%%% Macros
\newlength{\spacebox}
\settowidth{\spacebox}{8888888888}
\newcommand{\sepspace}{\vspace*{1em}}

\newcommand{\MyName}[1]{ % Name
	\Huge \usefont{OT1}{phv}{b}{n} \hfill #1
	\par \normalsize \normalfont
}

\newcommand{\MySlogan}[1]{ % Slogan (optional)
	\large \usefont{OT1}{phv}{m}{n}\hfill \textit{#1}
	\par \normalsize \normalfont
}

\newcommand{\NewPart}[2]{\section*{\uppercase{#1} \small \normalfont #2}}

\newcommand{\NewParttwo}[1]{
	\noindent \huge \textbf{#1}
    \normalsize \par
}

\newcommand{\PersonalEntry}[2]{\small
	\noindent\hangindent=2em\hangafter=0 % Indentation
	\parbox{\spacebox}{\textit{#1}}
	\small\hspace{1.5em} #2 \par
}

\newcommand{\SkillsEntry}[2]{
	\noindent\hangindent=2em\hangafter=0 % Indentation
	\parbox{\spacebox}{\textit{#1}}
	\hspace{1.5em} #2 \par
}

\newcommand{\EducationEntry}[4]{
	\noindent \textbf{#1} \hfill
	\colorbox{White}{
		\parbox{6em}{
		\hfill\color{Black}#2}}
	\par
	\noindent \textit{#3} \par
	\noindent\hangindent=2em\hangafter=0 \small #4
	\normalsize \par
}

\newcommand{\WorkEntry}[5]{
	\noindent \textbf{#1}
    \noindent \small \textit{#2}
    \hfill
    \colorbox{White}{
		\parbox{6em}{
		\hfill\color{Black}#3}}
	\par
	\noindent \textit{#4} \par
	\noindent\hangindent=2em\hangafter=0 \small #5
	\normalsize \par
}

\newcommand{\Language}[2]{
	\noindent \textbf{#1}
    \noindent \small \textit{#2}
}

\newcommand{\Text}[1]{\par
	\noindent \small #1
	\normalsize \par
}

\newcommand{\Textlong}[4]{
	\noindent \textbf{#1} \par
    \sepspace
    \noindent \small #2
    \par\sepspace
	\noindent \small #3
    \par\sepspace
	\noindent \small #4
    \normalsize \par
}

\newcommand{\PaperEntry}[7]{
	\noindent #1, ``\href{#7}{#2}", \textit{#3} \textbf{#4}, #5 (#6).
}

\newcommand{\ArxivEntry}[3]{
	\noindent #1, ``\href{http://arxiv.org/abs/#3}{#2}", \textit{cond-mat/#3}.
}

\newcommand{\BookEntry}[4]{
	\noindent #1, ``\href{#3}{#4}", \textit{#3}.
}

\newcommand{\FundingEntry}[5]{
    \noindent #1, ``#2", \$#3 (#4, #5).
}

\newcommand{\TalkEntry}[4]{
	\noindent #1, #2, #3 #4
}

\newcommand{\ThesisEntry}[5]{
	\noindent #1 -- #2 #3 ``#4" \textit{#5}
}

\newcommand{\CourseEntry}[3]{
	\noindent \item{#1: \textbf{#2} \\ #3}
}

\begin{document}

\MyName{{{{{name}}}}}

\sepspace
\sepspace

%%% Personal details
\NewPart{}{}

\PersonalEntry{Birth}{{{{{birth}}}}}
\PersonalEntry{Address}{{{{{address}}}}}
\PersonalEntry{Phone}{{{{{phone}}}}}
\PersonalEntry{Mail}{\url{{{{{email}}}}}}
\PersonalEntry{Github}{\href{{{{{githubURL}}}}}{{{{{github}}}}}}
\PersonalEntry{Linkedin}{\href{{{{{linkedinURL}}}}}{{{{{linkedin}}}}}}

%%% Objective
\NewPart{Objective}{}

{{{{objective}}}}

%%% Education
\NewPart{Education}{}

{{{{education_section}}}}

%%% Skills
\NewPart{Skills}{}

{{{{skills_section}}}}

%%% Projects
\NewPart{Projects}{}

{{{{projects_section}}}}

%%% Experience
\NewPart{Experiences}{}

{{{{experience_section}}}}

\end{document}
"""

def generate_cv_latex(data):


    # Helper function to escape LaTeX special characters
    def sanitize_latex(text):
        if not text:
            return ''
        replacements = {
            '\\': r'\textbackslash{}',
            '&': r'\&',
            '%': r'\%',
            '$': r'\$',
            '#': r'\#',
            '_': r'\_',
            '{': r'\{',
            '}': r'\}',
            '~': r'\textasciitilde{}',
            '^': r'\textasciicircum{}',
        }
        for original, replacement in replacements.items():
            text = text.replace(original, replacement)
        return text

    # Prepare personal details
    name = sanitize_latex(data.get('name', ''))
    birth = sanitize_latex(data.get('birth', ''))
    address = sanitize_latex(data.get('address', ''))
    phone = sanitize_latex(data.get('phone', ''))
    email = sanitize_latex(data.get('email', ''))
    github = sanitize_latex(data['github']['name'])
    githubURL = sanitize_latex(data['github']['githubURL'])
    linkedin = sanitize_latex(data['linkedin']['name'])
    linkedinURL = sanitize_latex(data['linkedin']['linkedinURL'])
    objective = sanitize_latex(data.get('objective', ''))

    # Prepare Education section
    education_entries = []
    for entry in data.get('education', []):
        degree = sanitize_latex(entry.get('degree', ''))
        years = sanitize_latex(entry.get('years', ''))
        institution = sanitize_latex(entry.get('institution', ''))
        description_lines = [sanitize_latex(line) for line in entry.get('descriptions', [])]
        description = r'\\'.join(description_lines)
        education_entry = r'\EducationEntry{{{}}}{{{}}}{{{}}}{{{}}} \sepspace'.format(degree, years, institution, description)
        education_entries.append(education_entry)
    education_section = '\n'.join(education_entries)

    # Prepare Skills section
    skills_entries = []
    for category, skills_list in data.get('skills', {}).items():
        sanitized_category = sanitize_latex(category)
        sanitized_skills = ', '.join(sanitize_latex(skill) for skill in skills_list)
        # Create a LaTeX command or environment for each skill category
        skills_entry = r'\textbf{{{}}}: {} \\\\'.format(sanitized_category, sanitized_skills)
        skills_entries.append(skills_entry)
    skills_section = '\n'.join(skills_entries)

    projects_items = []
    for project_dict in data.get('projects', []):
        for title, description in project_dict.items():
            sanitized_title = sanitize_latex(title)
            sanitized_description = sanitize_latex(description)
            # Use regular strings and escape backslashes
            project_entry = '\\item \\textbf{{{}}}: {}'.format(sanitized_title, sanitized_description)
            projects_items.append(project_entry)

    # Construct the projects_section without raw strings
    projects_section = '\\begin{itemize}\n' + '\n'.join(projects_items) + '\n\\end{itemize}'
    print(f"Projects Section:\n{projects_section}")
    # Prepare Experience section
    experience_items = [r'\item {}'.format(sanitize_latex(exp)) for exp in data.get('experience', [])]
    experience_section = r'\begin{itemize}' + '\n' + '\n'.join(experience_items) + '\n' + r'\end{itemize}'

    # Replace placeholders in the template
    latex_code = latex_template.replace('{{{{name}}}}', name)
    latex_code = latex_code.replace('{{{{birth}}}}', birth)
    latex_code = latex_code.replace('{{{{address}}}}', address)
    latex_code = latex_code.replace('{{{{phone}}}}', phone)
    latex_code = latex_code.replace('{{{{email}}}}', email)
    latex_code = latex_code.replace('{{{{github}}}}', github)
    latex_code = latex_code.replace('{{{{githubURL}}}}', githubURL)
    latex_code = latex_code.replace('{{{{linkedin}}}}', linkedin)
    latex_code = latex_code.replace('{{{{linkedinURL}}}}', linkedinURL)
    latex_code = latex_code.replace('{{{{objective}}}}', objective)
    latex_code = latex_code.replace('{{{{education_section}}}}', education_section)
    latex_code = latex_code.replace('{{{{skills_section}}}}', skills_section)
    latex_code = latex_code.replace('{{{{projects_section}}}}', projects_section)
    latex_code = latex_code.replace('{{{{experience_section}}}}', experience_section)


    return latex_code


# Define your data
data = {
    'name': 'Salah Gamal 12665',
    'birth': 'April 16, 2004',
    'address': 'Aswan ,Aswan',
    'phone': '+201557786305',
    'email': '1256@gmail.com',
    'github': {
        'name':'Salah Gamal',
        'githubURL':'https://github.com/SALAH164',
    },
    'linkedin': {
        'name':'Salah Eldin Gamal',
        'linkedinURL':'https://www.linkedin.com/in/salah-gamal-7aba37254/',
    },
    'objective': 'Seeking a challenging position in technology to utilize my skills and knowledge.',
    'education': [
        {
            'degree': 'M.Sc in Computer Science',
            'years': '2022-2025',
            'institution': 'University of Information Technology, AASTMT',
            'descriptions': [
                'Graduated with honors',
                'GPA: 3.3/4.0'
            ]
        },
{
            'degree': 'M.Sc in Computer Science',
            'years': '2022-2025',
            'institution': 'University of Information Technology, AUC',
            'descriptions': [
                'Graduated with honors',
                'GPA: 3.3/4.0'
            ]
        },
    ],
    'skills': {
        'Programming Languages':
           ['Python', 'Java', 'C++','javascript','latex'],
        'Web Development':
           ['HTML', 'CSS', 'JavaScript', 'flask'],
        'Databases':
            [ 'MySQL'],
        'Tools': ['Git', 'Docker', 'Kubernetes'],
        'Methodologies':[ 'Agile', 'Scrum'],
    },
    'projects': [
        {'Project One': 'Developed a web application for managing tasks using Python and Django.'},
        # {'Project One': 'Developed a web application for managing tasks using Python and Django.'},
        # {'Project One': 'Developed a web application for managing tasks using Python and Django.'},
    ],
    'experience': [
        'Software Engineer at TechCorp (2020-Present): Worked on developing scalable backend systems using Python and Django.',
        'Intern at WebSolutions (Summer 2019): Assisted in front-end development using JavaScript and React.'
    ]
}

def latex_to_pdf(latex_code, output_filename='output'):
    tex_filename = f"{output_filename}.tex"

    # Write LaTeX code to .tex file
    with open(tex_filename, 'w') as tex_file:
        tex_file.write(latex_code)

    # Compile LaTeX file to PDF
    try:
        subprocess.run(
            ['pdflatex', '-interaction=nonstopmode', tex_filename],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        print("An error occurred during compilation.")
    finally:
        # Clean up auxiliary files
        for ext in ['aux', 'log', 'tex']:
            aux_file = f"{output_filename}.{ext}"
            if os.path.exists(aux_file):
                os.remove(aux_file)


class CV_Builder(ABC):
    def __init__(self, data):
        self.template = latex_template
        self.data = data
        self.latex  = latex_template

    def sanitize_latex(self, text):
        if not text:
            return ''
        replacements = {
            '\\': r'\textbackslash{}', '&': r'\&', '%': r'\%', '$': r'\$',
            '#': r'\#', '_': r'\_', '{': r'\{', '}': r'\}',
            '~': r'\textasciitilde{}', '^': r'\textasciicircum{}',
        }
        for original, replacement in replacements.items():
            text = text.replace(original, replacement)
        return text

    def replace(self, key, value):
            self.latex = self.latex.replace(f'{{{{{{{{{key}}}}}}}}}', value)
    @abstractmethod
    def build_personal_details(self): pass

    @abstractmethod
    def build_education(self): pass

    @abstractmethod
    def build_skills(self): pass

    @abstractmethod
    def build_projects(self): pass

    @abstractmethod
    def build_experience(self): pass

    def get_result(self):
        return self.latex



class Standard_CV_Builder(CV_Builder):
    def __init__(self, data):
        super().__init__(data)
    def sanitize(self, text):
        if not text:
            return ''
        replacements = {
            '\\': r'\textbackslash{}',
            '&': r'\&',
            '%': r'\%',
            '$': r'\$',
            '#': r'\#',
            '_': r'\_',
            '{': r'\{',
            '}': r'\}',
            '~': r'\textasciitilde{}',
            '^': r'\textasciicircum{}',
        }
        for original, replacement in replacements.items():
            text = text.replace(original, replacement)
        return text

    def build_personal_details(self):
        d = self.data
        self.replace('name', self.sanitize_latex(d.get('name', '')))
        self.replace('birth', self.sanitize_latex(d.get('birth', '')))
        self.replace('address', self.sanitize_latex(d.get('address', '')))
        self.replace('phone', self.sanitize_latex(d.get('phone', '')))
        self.replace('email', self.sanitize_latex(d.get('email', '')))
        self.replace('github', self.sanitize_latex(d['github']['name']))
        self.replace('githubURL', self.sanitize_latex(d['github']['githubURL']))
        self.replace('linkedin', self.sanitize_latex(d['linkedin']['name']))
        self.replace('linkedinURL', self.sanitize_latex(d['linkedin']['linkedinURL']))
        self.replace('objective', self.sanitize_latex(d.get('objective', '')))

    def build_education(self):
        entries = []
        for entry in self.data.get('education', []):
            degree = self.sanitize_latex(entry.get('degree', ''))
            years = self.sanitize_latex(entry.get('years', ''))
            institution = self.sanitize_latex(entry.get('institution', ''))
            description_lines = [self.sanitize_latex(line) for line in entry.get('descriptions', [])]
            description = r'\\'.join(description_lines)
            latex_entry = r'\EducationEntry{{{}}}{{{}}}{{{}}}{{{}}} \sepspace'.format(degree, years, institution, description)
            entries.append(latex_entry)
        self.replace('education_section', '\n'.join(entries))

    def build_skills(self):
        entries = []
        for category, skills in self.data.get('skills', {}).items():
            cat = self.sanitize_latex(category)
            skill_list = ', '.join(self.sanitize_latex(skill) for skill in skills)
            entries.append(r'\textbf{{{}}}: {} \\'.format(cat, skill_list))
        self.replace('skills_section', '\n'.join(entries))

    def build_projects(self):
        items = []
        for project in self.data.get('projects', []):
            for title, desc in project.items():
                items.append(r'\item \textbf{{{}}}: {}'.format(
                    self.sanitize_latex(title), self.sanitize_latex(desc)
                ))
        section = r'\begin{itemize}' + '\n' + '\n'.join(items) + '\n' + r'\end{itemize}'
        self.replace('projects_section', section)

    def build_experience(self):
        items = [r'\item {}'.format(self.sanitize_latex(exp)) for exp in self.data.get('experience', [])]
        section = r'\begin{itemize}' + '\n' + '\n'.join(items) + '\n' + r'\end{itemize}'
        self.replace('experience_section', section)

class CV_Director:
    def __init__(self, builder: CV_Builder):
        self.builder = builder

    def generate_cv(self):
        self.builder.build_personal_details()
        self.builder.build_education()
        self.builder.build_skills()
        self.builder.build_projects()
        self.builder.build_experience()
        return self.builder.get_result()


@app.route('/create_cv', methods=['POST'])
def create_cv():
    data = request.get_json()
    print(data)
    # todo add the type attribute in the data sent by the app
    type = 1
    if type==1:
        try:
            builder = Standard_CV_Builder(data)
            director = CV_Director(builder)
            # Generate the LaTeX code
            latex_code = director.generate_cv()
            # The latex_code variable now contains the complete LaTeX code as a string
            # You can print it, save it to a file, or pass it to a LaTeX compiler

            print(latex_code)
            latex_to_pdf(latex_code)
            return send_file(
                'output.pdf',
                mimetype='application/pdf',
                as_attachment=True,
                download_name='output.pdf'
            )
            return jsonify({"Done successfully":latex_code}), 200
        except Exception as e:
            return jsonify({'Error 1': f'{e}'}), 500
    elif type==2:
        return jsonify({'Error': 'Coming soon !'}), 500
    else :
        return jsonify({'Error': 'Wrong or invalid CV type inserted'}), 500



@app.route('/add_last_modification', methods=['POST'])
def add_last_modification():
    data = request.get_json()
    username = data.get('username')
    last_modification = data.get('last_modification_date')

    # Validate input
    if not username or not last_modification:
        return jsonify({'error': 'Missing username or last_modification'}), 400

    try:
        conn = get_connection()
        if not conn:
            return jsonify({'message': 'Database connection error'}), 500
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO last_modifications (username, last_modification)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE last_modification = VALUES(last_modification)
        """, (username, last_modification))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': 'Last modification date added successfully'}), 201

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        return jsonify({'status': 'error', 'message': f'Database error {err}'}), 500





@app.route('/get_last_modification', methods=['POST'])
def get_last_modification():
    username = request.get_json().get('username')
    try:
        conn = get_connection()
        if not conn:
            return jsonify({'message': 'Database connection error'}), 500

        cursor = conn.cursor(dictionary=True)

        # Step 1: Try to fetch existing record
        cursor.execute("""
            SELECT last_modification FROM last_modifications WHERE username = %s
        """, (username,))
        result = cursor.fetchone()

        # Step 2: If not found, insert with current date
        if not result:
            cursor.execute("""
                INSERT INTO last_modifications (username, last_modification)
                VALUES (%s, NOW())
            """, (username,))
            conn.commit()

            # Re-fetch the inserted record
            cursor.execute("""
                SELECT last_modification FROM last_modifications WHERE username = %s
            """, (username,))
            result = cursor.fetchone()

        cursor.close()
        conn.close()

        return jsonify({'username': username, 'last_modification': result['last_modification']}), 200

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        return jsonify({'status': 'error', 'message': f'Database error: {err}'}), 500





@app.route('/check_password', methods=['POST'])
def check_password():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Missing username or password'}), 400

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT password FROM user WHERE username = %s", (username,))
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        if result:
            stored_hash = result['password']
            if verify_password(stored_hash, password):
                return jsonify({'status': 'success', 'message': 'Password correct'}), 200
            else:
                return jsonify({'status': 'fail', 'message': 'Incorrect password'}), 401
        else:
            return jsonify({'status': 'fail', 'message': 'User not found'}), 404

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        return jsonify({'status': 'error', 'message': 'Database error'}), 500


chat_endpoint(app, get_connection, BASE_DIR, allowed_file, extract_lecture_number)

# Run the app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True, use_reloader=False)
