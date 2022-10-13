//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 13.10.2022.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()

    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_syidi95i") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                guard let movies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) else {
                    return
                }
                handler(.success(movies))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
