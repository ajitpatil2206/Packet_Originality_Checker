import json
from flask import Flask, request, jsonify
import werkzeug

from main import findID

app = Flask(__name__)

@app.route('/upload', methods = ["POST"])

def upload():
    if(request.method == "POST"):

        imagefile = request.files['image']

        filename = werkzeug.utils.secure_filename(imagefile.filename)
        print("\nReceived image file name:" + imagefile.filename)

        imagefile.save("./images/" + filename)

        id = findID("./images/" + filename)

        if(id==-1):
            result = 'Fake'
        elif (id<10):
            result = 'Passed'
        else:
            result = 'Tampered'
        
        return json.dumps({
            "Result": result
        })

if __name__ == "__main__":
    app.run(debug=True, port=4000)
