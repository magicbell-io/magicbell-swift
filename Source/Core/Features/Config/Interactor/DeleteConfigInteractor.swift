//
//  DeleteUserConfigInteractor.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Foundation
import Harmony

struct DeleteConfigInteractor {
    private let deleteConfigInteractor: Interactor.DeleteAllByQuery

    public init(_ deleteConfigInteractor: Interactor.DeleteAllByQuery) {
        self.deleteConfigInteractor = deleteConfigInteractor
    }

    public func execute() -> Future<Void> {
        return deleteConfigInteractor.execute(AllObjectsQuery(), CacheOperation())
    }
}
