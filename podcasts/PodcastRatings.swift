import Foundation
import PocketCastsServer
import PocketCastsDataModel

struct PodcastRatings {

    /// Gets the rating from the API for a podcast UUID, will get the iTunesID if it's missing
    static func rating(for uuid: String) async throws -> PodcastRatingResponse? {
        guard let itunesId = iTunesID(for: uuid) else {
            return try await updateItunesIdAndGetRating(for: uuid)
        }

        return try await rating(for: itunesId)
    }

    /// Gets the rating from the API for an iTunesID
    static func rating(for iTunesID: Int) async throws -> PodcastRatingResponse? {
        guard iTunesID != Constants.ItunesIDNotFound else { return nil }

        return try await MainServerHandler.shared.podcastRating(iTunesId: iTunesID)
    }


    /// Tries to grab the iTunesID from the server, save it, and then return the rating
    static func updateItunesIdAndGetRating(for uuid: String) async throws -> PodcastRatingResponse? {
        guard
            let result = try await MainServerHandler.shared.podcastExtraInfo(uuids: [uuid])?.result?.first
        else {
            return nil
        }

        let itunesId = result.itunesId ?? Constants.ItunesIDNotFound
        DataManager.sharedManager.updateItunesId(uuid: uuid, iTunesId: itunesId)

        return try await rating(for: itunesId)
    }

    /// Gets the rating from the database
    private static func iTunesID(for uuid: String) -> Int? {
        guard let itunesId = DataManager.sharedManager.findPodcast(uuid: uuid, includeUnsubscribed: true)?.itunesId else {
            return nil
        }

        return Int(itunesId)
    }

    private enum Constants {
        // -1 means we checked with the APi and there is no iTunes ID
        static let ItunesIDNotFound = -1
    }
}
