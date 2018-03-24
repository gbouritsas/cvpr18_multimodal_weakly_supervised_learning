# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 04:02:02 2017

@author: ΓΙΩΡΓΟΣ
"""
from functions_for_verbs import fast_xml_to_mat
import sys
import scipy.io as scio
movies = sys.argv[1:]


def parse_xml(movies):
	for movie_name in movies:
		input_folder = movies_folder + movie_name + '/results_script/'
		result_folder = movies_folder + movie_name + '/results_script/'
		print('Parsing '+ movie_name +'_preprocessed.txt.ser.gz.xml...')
		doc=fast_xml_to_mat(movie_name + '_preprocessed.txt.ser.gz.xml',input_folder)
		print('Parse complete. Writing to '+ movie_name + '_preprocessed_struct.mat...' )
		scio.savemat(result_folder + movie_name + '_preprocessed_struct.mat',doc)

# This path needs to be modified.
global movies_folder
movies_folder = '/Users/giorgosmpouritsas/Documents/movies/'
# Modify this list if necessary
movies=['BMI','CRA','DEP','GLA','LOR']
parse_xml(movies)
