# -*- coding: utf-8 -*-
"""
Created on Thu Jan 19 17:55:50 2017

@author: ΓΙΩΡΓΟΣ
"""
import scipy.io as scio
from scipy import spatial
import numpy as np
import xmltodict
from requests import get
import numpy
import string
import os
import codecs
import gensim
import re
#from get_sentence_embeddings_from_pre_trained_models import*

#translator to clean punctuation
translator = str.maketrans('', '', string.punctuation)

def fast_xml_to_mat(movie_name,input_folder):
    with codecs.open(input_folder + movie_name,'r','utf-8') as fd:
        doc = xmltodict.parse(fd.read())
    return(doc)
    
#change this if possible because internet requests extremely slow the processing down.
#there is a java implementation to replace this(wishlist)
sss_url="http://swoogle.umbc.edu/SimService/GetSimilarity"
def sss(s1, s2, type='relation', corpus='webbase'):
    connected = False
    while not connected:
        try:
            response=[]
            response = get(sss_url, params={'operation':'api','phrase1':s1,'phrase2':s2,'type':2})
            connected=True
            return float(response.text.strip())
        except:
            if not response:
                print ('Error in getting similarity for (%s,%s): no internet' % (s1,s2))
                if connected:
                    return(0.0)
            else:
                print ('Error in getting similarity for %s: %s' % ((s1,s2), response))
                if connected:
                    return(0.0)
            
def sw2v(s1, s2, model,num_features,index2word_set):
    s1_afv = avg_feature_vector(s1, model, num_features, index2word_set)
    s2_afv = avg_feature_vector(s2, model, num_features, index2word_set)
    if spatial.distance.norm(s1_afv)==0 or spatial.distance.norm(s2_afv)==0:
        sim=0
    else:
        sim = 1 - spatial.distance.cosine(s1_afv, s2_afv)
    return sim

def avg_feature_vector(sentence, model, num_features, index2word_set):
    words = sentence.split()
    feature_vec = np.zeros((num_features, ), dtype='float32')
    n_words = 0
    for word in words:
        if word.lower() in index2word_set:
            n_words += 1
            feature_vec = np.add(feature_vec, model[word.lower()])
    if (n_words > 0):
        feature_vec = np.divide(feature_vec, n_words)
    return feature_vec


def verb_classification(movie_mat,mat,method,model,num_features,index2word_set):
    sentences=movie_mat['sentences_with_ids']
    struct=mat['categories_ids']
    categories=[]
    for i in range(0,struct.shape[1]):
        categories.append(struct[0,i].categories[0])
    final_similarities=[]
    final_categories=[]
    final_ids=[]
    sentence_ids=[]
    similarities_all=[]
    if method=='sent2vec':
        sent=[]
        for j in range(0,sentences.shape[1]):
            s=sentences[0][j][0][0]
            if sentences[0][j][2][0][0]==0:
                if re.match('^ *$',s.translate(translator)):
                    sent.append('negative')
                else:
                    sent.append(s.translate(translator))
            else:
                sent.append('negative')
        sentences_embeddings=get_sentence_embeddings(sent, ngram='unigrams', model='wiki')
        #sentences_embeddings=get_sentence_embeddings(['I went', 'I will go'], ngram='unigrams', model='wiki')
        categories_embeddings=get_sentence_embeddings(categories, ngram='unigrams', model='wiki')
    for j in range(0,sentences.shape[1]):
        print(j+1,'/',sentences.shape[1])
        similarities=[]
        s=sentences[0][j][0][0]
        neg_flag=sentences[0][j][2][0][0]
        if neg_flag==0 and not re.match('^ *$',s.translate(translator)):
            cat_id=0
            for category in categories:
                if method=='wordnet':
                    sentence_similarity=sss(s.translate(translator),category)
                elif method=='word2vec':
                    sentence_similarity=sw2v(s.translate(translator),category,model,num_features,index2word_set)
                elif method=='glove':
                    sentence_similarity=sw2v(s.translate(translator),category,model,num_features,index2word_set)
                elif method=='fasttext':
                    sentence_similarity=sfast(s.translate(translator),category)
                elif method=='sent2vec':
                    sentence_similarity=1 - spatial.distance.cosine(sentences_embeddings[j,:],categories_embeddings[cat_id,:])
                similarities.append(sentence_similarity)
                cat_id+=1
            similarities_all.append([similarities])
            index_max= max(range(len(similarities)), key=similarities.__getitem__)
            final_similarities.append(max(similarities))
            final_categories.append(categories[index_max])
            final_ids.append(index_max+1)
        else:
            similarities_all.append([0.0 for i in range(0,len(categories))])
            final_similarities.append(0.0)
            final_categories.append('negative')
            final_ids.append(0)   
        
    obj_arr=np.array(final_categories,dtype=numpy.object)
    obj_arr_1 =np.array(similarities_all,dtype=numpy.object)
    mdict={'final_categories':obj_arr,'final_similarities':final_similarities,'final_ids':final_ids,'similarities_all':obj_arr_1}
    return(mdict)
 
