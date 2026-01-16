import Foundation

final class ImagePrefetcher {
    static let shared = ImagePrefetcher()

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.urlCache = URLCache.shared
        return URLSession(configuration: cfg)
    }()

    func prefetch(_ urls: [String]) {
        for s in urls {
            guard let url = URL(string: s) else { continue }
            var req = URLRequest(url: url)
            req.cachePolicy = .returnCacheDataElseLoad
            session.dataTask(with: req) { _, _, _ in }.resume()
        }
    }
}