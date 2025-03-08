# Bigram Analysis  

This is a simple Sinatra web application that analyzes text input using **bigram frequency analysis** and **cosine similarity** to compare it to typical English text. Based on the similarity score, it fetches an appropriate emoji icon from the IconFinder API.  

## Features  
- Extracts bigrams from user input  
- Computes cosine similarity with English bigram probabilities  
- Fetches an emoji icon based on similarity score  
- Displays results in a simple web interface  

## Setup
- get an **IconFinder API Key** 
- run bundle install 
- run bin/server
