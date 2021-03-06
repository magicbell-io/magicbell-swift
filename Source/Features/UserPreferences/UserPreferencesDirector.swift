//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import Foundation
import Harmony
import Combine

public protocol UserPreferencesDirector {

    /// Fetches the user preferences.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func fetch(completion: @escaping(Result<UserPreferences, Error>) -> Void)

    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func update(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void)

    /// Fetches the preferences for a given category.
    /// - Parameters:
    ///     - completion: Closure with a `Result`. Success returns the `Preferences` for the given category.
    func fetchPreferences(for category: String, completion: @escaping(Result<Preferences, Error>) -> Void)

    /// Updates the preferences for a given category.
    /// - Parameters:
    ///   - preferences: The notification preferences for a given category.
    ///   - category: The category name.
    ///   - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func updatePreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<Preferences, Error>) -> Void)
}

public extension UserPreferencesDirector {
    /// Fetches the user preferences.
    /// - Returns: A future with the user preferences or an error
    @available(iOS 13.0, *)
    func fetch() -> Combine.Future<UserPreferences, Error> {
        return Future { promise in
            self.fetch { result in
                promise(result)
            }
        }
    }

    /// Updates the user preferences. Update can be partial and only will affect the categories included in the object being sent.
    /// - Returns: A future with the user preferences or an error
    @available(iOS 13.0, *)
    @discardableResult
    func update(_ userPreferences: UserPreferences) -> Combine.Future<UserPreferences, Error> {
        return Future { promise in
            self.update(userPreferences) { result in
                promise(result)
            }
        }
    }

    /// Fetches the preferences for a given category.
    /// - Returns: A future with the preferences or an error
    @available(iOS 13.0, *)
    func fetchPreferences(for category: String) -> Combine.Future<Preferences, Error> {
        return Future { promise in
            self.fetchPreferences(for: category) { result in
                promise(result)
            }
        }
    }

    /// Updates the preferences for a given category.
    /// - Parameters:
    ///   - preferences: The notification preferences for a given category.
    ///   - category: The category name.
    /// - Returns: A future with the preferences or an error
    @available(iOS 13.0, *)
    @discardableResult
    func updatePreferences(_ preferences: Preferences, for category: String) -> Combine.Future<Preferences, Error> {
        return Future { promise in
            self.updatePreferences(preferences, for: category) { result in
                promise(result)
            }
        }
    }
}

struct DefaultUserPreferencesDirector: UserPreferencesDirector {

    private let logger: Logger
    private let userQuery: UserQuery
    private let getUserPreferencesInteractor: GetUserPreferencesInteractor
    private let updateUserPreferencesInteractor: UpdateUserPreferencesInteractor

    init(
        logger: Logger,
        userQuery: UserQuery,
        getUserPreferencesInteractor: GetUserPreferencesInteractor,
        updateUserPreferencesInteractor: UpdateUserPreferencesInteractor
    ) {
        self.logger = logger
        self.userQuery = userQuery
        self.getUserPreferencesInteractor = getUserPreferencesInteractor
        self.updateUserPreferencesInteractor = updateUserPreferencesInteractor
    }


    func fetch(completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        getUserPreferencesInteractor.execute(userQuery: userQuery)
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    func update(_ userPreferences: UserPreferences, completion: @escaping(Result<UserPreferences, Error>) -> Void) {
        updateUserPreferencesInteractor.execute(userPreferences, userQuery: userQuery)
            .then { userPreferences in
                completion(.success(userPreferences))
            }.fail { error in
                completion(.failure(error))
            }
    }


    func fetchPreferences(for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        getUserPreferencesInteractor.execute(userQuery: userQuery)
            .map { userPreferences in
                guard let preferences = userPreferences.preferences[category] else {
                    throw MagicBellError("Notification preferences not found for category \(category)")
                }
                return preferences
            }.then { preferences in
                completion(.success(preferences))
            }.fail { error in
                completion(.failure(error))
            }
    }

    /// Updates the notification preferences for a given category.
    /// - Parameters:
    ///   - preferences: The notification preferences for a given category.
    ///   - category: The category name.
    ///   - completion: Closure with a `Result`. Success returns the `UserPreferences`.
    func updatePreferences(_ preferences: Preferences, for category: String, completion: @escaping(Result<Preferences, Error>) -> Void) {
        let userPreferences = UserPreferences([category: preferences])
        updateUserPreferencesInteractor.execute(userPreferences, userQuery: userQuery)
            .map { userPreferences in
                guard let preferences = userPreferences.preferences[category] else {
                    throw MagicBellError("Notification preferences not found for category \(category)")
                }
                return preferences
            }.then { preferences in
                completion(.success(preferences))
            }.fail { error in
                completion(.failure(error))
            }
    }
}
