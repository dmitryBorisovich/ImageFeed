import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidData(String)
    case noData
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    if let receivedData = String(data: data, encoding: .utf8) {
                        print(receivedData)
                    }
                    print(">>> [dataTask] Network error. HTTP status code \(statusCode) was received")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print(">>> [dataTask] Network error. URL Request error: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print(">>> [dataTask] Network error. URL Session error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    let invalidData = String(data: data, encoding: .utf8) ?? ""
                    print("""
                        >>> [objectTask] Network error. Decoding failed: \(error.localizedDescription)
                        Received data: \(invalidData)
                    """)
                    completion(.failure(NetworkError.invalidData(invalidData)))
                }
            case .failure(let error):
                print(">>> [dataTask] Network error. No data to decode: \(error.localizedDescription)")
                completion(.failure(NetworkError.noData))
            }
        }
        return task
    }
}
