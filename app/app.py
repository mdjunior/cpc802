import os #port
import re #getTokens
from flask import Flask
from flask import jsonify
from flask import request

import joblib

filenameVectorizer   = os.getenv('MODELS_FOLDER','../models/') + 'cpc802-20200209-030517-perceptron-word.vectorizer'
filenameModel_logreg = os.getenv('MODELS_FOLDER','../models/') + 'cpc802-20200209-030517-logreg-word.sav'
filenameModel_lsvm   = os.getenv('MODELS_FOLDER','../models/') + 'cpc802-20200209-030517-lsvm-word.sav'
filenameModel_percep = os.getenv('MODELS_FOLDER','../models/') + 'cpc802-20200209-030517-perceptron-word.sav'

# Função que separa cada URL em uma lista de palavras/tokens, utilizando como separadores: '/', '-', '.'
#   Ela é necessário mesmo na aplicação Flask.
def getTokens(input):
    return re.split('/|-|\.|=|&|\?|\s+|\<|\>|;|\(|\)', str(input.encode('utf-8')))

# Vamos carregar os vetores.
vectorizer = joblib.load(filenameVectorizer)

# Vamos carregar os modelos.
lgs = joblib.load(filenameModel_logreg)
lsvm = joblib.load(filenameModel_lsvm)
percep = joblib.load(filenameModel_percep)

api = Flask(__name__)

@api.route('/<path:subpath>')
def show_subpath(subpath):

    uri = '%s?%s' % (request.path, request.query_string.decode('utf-8'))

    # Vetorizamos a URI
    URI_vector = vectorizer.transform([ uri ])

    # Geramos uma predição quando ao URI.
    lgs_predict = lgs.predict(URI_vector)
    lsvm_predict = lsvm.predict(URI_vector)
    percep_predict = percep.predict(URI_vector)

    status_code = 200
    if lgs_predict == 1 or lsvm_predict == 1 or percep_predict == 1:
        status_code = 403

    return jsonify(
        uri    = uri,
        lgs    = int(lgs_predict[0]),
        lsvm   = int(lsvm_predict[0]),
        percep = int(percep_predict[0]),
    ), status_code

if __name__ == "__main__":
    api.run(host='0.0.0.0',port=os.getenv('PORT',8888))