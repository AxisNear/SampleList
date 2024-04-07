
import Foundation
import Alamofire
import RxSwift

enum PokemonAPI {
    case listPokemon, info(String)
    var endPoint: String {
        switch self {
        case .listPokemon:
            return "https://pokeapi.co/api/v2/pokemon"
        case .info(let name):
            return "https://pokeapi.co/api/v2/pokemon/\(name)"
        }
    }
}

class PMService {
    func fetchData(url: String) -> Observable<Data> {
        return Observable.create { observer in
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func fetchData(api: PokemonAPI) -> Observable<Data> {
        return Observable.create { observer in
            AF.request(api.endPoint).responseData { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
