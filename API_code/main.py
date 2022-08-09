import pickle
import cv2
import numpy as np
import os

orb = cv2.ORB_create(nfeatures = 1000)

#get pickled files
file = 'descrip.pkl'
fileobj = open(file, 'rb')
desList = pickle.load(fileobj)

file = 'class_names.pkl'
fileobj = open(file, 'rb')
classNames = pickle.load(fileobj)

print(classNames)



#Function to check if the given image matches with the valid or tampered packets
def findID(img, thres = 20):

    #getting the image (to be checked)
    cap = cv2.imread(img)
    img2 = cap
    imgOriginal = img2.copy()
    img2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

    kp2, des2 = orb.detectAndCompute(img2, None)
    bf = cv2.BFMatcher()
    finalVal = -1
    
    matchList = []
    for des in desList:
        good = []
        matches = bf.knnMatch(des, des2, k=2)
        try :
            for m, n in matches:
                if m.distance < 0.75 * n.distance:
                    good.append([m])
            matchList.append(len(good))
            #print("matcheList : ", matchList)
        except:
            pass
    if len(matchList) != 0:
        if max(matchList) > thres:
            finalVal = matchList.index(max(matchList))
    return finalVal

