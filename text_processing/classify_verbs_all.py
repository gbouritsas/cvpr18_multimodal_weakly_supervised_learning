# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 04:31:49 2017

@author: giorgos
"""

from functions_for_verbs import verb_classification
import sys
import scipy.io as scio
import gensim
import numpy as np
from gensim.scripts.glove2word2vec import glove2word2vec
sys.path.insert(0, 'word_embeddings/sent2vec/')
#from get_sentence_embeddings_from_pre_trained_models import*


def classify_verbs(movies,method,model,index2word_set):

    for movie_name in movies:
        input_folder= movies_folder + movie_name + '/results_script'
        result_folder=movies_folder + movie_name + '/results_script'
        print('Calculating sentence similarity between categories and sentences in '+movie_name+'_sentences.mat...')
        movie_mat=scio.loadmat(input_folder+'/'+movie_name+'_sentences.mat')

        if method=='wordnet':
            mdict=verb_classification(movie_mat,mat,method,[],[],[])
            print('Saving to '+movie_name+'_similarities_wordnet_47.mat...')
            scio.savemat(result_folder+'/'+movie_name+'_similarities_wordnet_47.mat',mdict)
        elif method=='word2vec':
            num_features=300
            mdict=verb_classification(movie_mat,mat,method,model,num_features,index2word_set)
            print('Saving to '+movie_name+'_similarities_word2vec_47.mat...')
            scio.savemat(result_folder+'/'+movie_name+'_similarities_word2vec_47.mat',mdict)
        elif method=='glove':
            num_features=300
            mdict=verb_classification(movie_mat,mat,method,model,num_features,index2word_set)
            print('Saving to '+movie_name+'_similarities_glove_47.mat...')
            scio.savemat(result_folder+'/'+movie_name+'_similarities_glove_47.mat',mdict)
        elif method=='fasttext':
            print('Saving to '+movie_name+'_similarities_fasttext_47.mat...')
            scio.savemat(result_folder+'/'+movie_name+'_similarities_fasttext_47.mat',mdict)
        elif method=='sent2vec':
            mdict=verb_classification(movie_mat,mat,method,[],[],[])
            print('Saving to '+movie_name+'_similarities_sent2vec_47.mat...')
            scio.savemat(result_folder+'/'+movie_name+'_similarities_sent2vec_47.mat',mdict)

def loadGloveModel(gloveFile):
    print('Loading Glove Model')

    #adjust this path
    glove_vectors_file="../word_embeddings/glove.6B/gensim_glove_vectors.txt"
    glove2word2vec(gloveFile, word2vec_output_file=glove_vectors_file)
    model = gensim.models.KeyedVectors.load_word2vec_format(glove_vectors_file, binary=False)
    print('Done.')
    return model;
# %%

movies = sys.argv[1:]
# Modify this path:
global categories_folder
global categories_small_file
categories_folder='../manual_annotation/'
categories_small_file='categories_ids_47.mat'
mat = scio.loadmat(categories_folder + categories_small_file,struct_as_record=0)

method='word2vec'

global movies_folder
# Modify this path:
movies_folder = '/Users/giorgosmpouritsas/Documents/movies/'
movies=['BMI','CRA','DEP','GLA','LOR']

if method=='word2vec':
    # adjust word2vec path
    word2vec_path = '../word_embeddings/word2vec/GoogleNews-vectors-negative300.bin'
    model = gensim.models.KeyedVectors.load_word2vec_format('../word_embeddings/word2vec/GoogleNews-vectors-negative300.bin', binary=True)
    index2word_set = set(model.index2word)
if method=='glove':
    # adjust glove path
    gloveFile='../word_embeddings/glove.6B/glove.6B.300d.txt'
    model=loadGloveModel(gloveFile)
    index2word_set = set(model.index2word)
if method=='wordnet':
    model=[]
    index2word_set=[]

# %%
classify_verbs(movies,method,model,index2word_set)


#if __name__ == "__main__":
#    classify_verbs(movies,method)
