//
//  DefaultFavoritUseCase.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import Foundation
import RxSwift

class DefaultFavoriteUseCase {
    private let favoriteRepo: FavoriteRepoProtocol

    init(favoriteRepo: FavoriteRepoProtocol = FavoriteRepo.shared) {
        self.favoriteRepo = favoriteRepo
    }

    func favoriteState(name: String) -> Observable<Bool> {
        let notifi: Observable<Bool> = NotificationCenter.default.rx.notification(.favoriteChanged, object: nil)
            .compactMap { notification in
                guard let userInfo = notification.userInfo as? [String: Bool],
                      let notifiName = userInfo.keys.first,
                      let isFavorite = userInfo[name]
                else {
                    return nil
                }
                return name == notifiName ? isFavorite : nil
            }
        return notifi.startWith(favoriteRepo.isFavorite(name: name))
    }

    func favoirteToggle(name: String) -> Observable<Void> {
        let isChanged: Bool
        if favoriteRepo.isFavorite(name: name) {
            isChanged = favoriteRepo.deleteFavorte(name: name)
        } else {
            isChanged = favoriteRepo.addFavotite(name: name)
        }
        NotificationCenter.default.post(name: .favoriteChanged, object: nil, userInfo: [name: isChanged])
        return .just(())
    }
}

extension Notification.Name {
    static let favoriteChanged = Notification.Name("FavoriteChanged")
}
