import datetime
import json
import logging
import os
import time

import requests


logging.basicConfig(level=logging.INFO)


def get_movies(page_number, API_KEY):
    """
    Function to get movies from the TMDB API for a given page number.

    Parameters:
    page_number (int): The page number for which to get the movies.
    API_KEY (str): Your TMDB API key.

    Returns:
    list: A list of dictionaries, each containing information about a movie.
    """

    logging.info(f"Fetching page {page_number}")
    url = f"https://api.themoviedb.org/3/discover/movie?api_key={API_KEY}&page={page_number}"

    while True:
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
        except requests.HTTPError as http_err:
            logging.error(f"HTTP error occurred: {http_err}")
            time.sleep(10)  # Wait 10 seconds before trying again
            continue
        except Exception as err:
            logging.error(f"An error occurred: {err}")
            time.sleep(10)  # Wait 10 seconds before trying again
            continue
        else:
            break

    data = response.json()

    movies = data.get("results", [])
    filmes = []
    for movie in movies:
        df = {
            "Titulo": movie["title"] if "title" in movie else None,
            "Data de lançamento": movie["release_date"] if "release_date" in movie else None,
            "Visão geral": movie["overview"].encode("utf-8").decode("utf-8")
            if "overview" in movie
            else None,  # Tratamento de caracteres especiais
            "Votos": movie["vote_count"] if "vote_count" in movie else None,
            "Média de votos": movie["vote_average"] if "vote_average" in movie else None,
            "Popularidade": movie["popularity"] if "popularity" in movie else None,
            "vote_count": movie["vote_count"] if "vote_count" in movie else None,
        }
        filmes.append(df)
    return filmes


def upload_to_s3(filmes, s3, S3_BUCKET_NAME, start_page, end_page):
    """
    Function to upload movie data to S3.

    Parameters:
    filmes (list): The movie data to upload.
    s3 (boto3.S3.Client): The S3 client to use for the upload.
    S3_BUCKET_NAME (str): The name of the bucket to which to upload the data.

    Returns:
    bool: True if the upload was successful, False otherwise.
    """

    current_date = datetime.datetime.now().strftime("%Y/%m/%d")
    movies_destino = f"tmdb/movies/{current_date}/filmes_{start_page}_{end_page}.json"

    try:
        filmes_json = json.dumps(filmes)
        s3.upload_file(filmes_json, S3_BUCKET_NAME, movies_destino)
        logging.info("Upload concluído com sucesso!")
        return True
    except Exception as e:
        logging.error(f"Falha na criação do bucket: {e}")
        return False
