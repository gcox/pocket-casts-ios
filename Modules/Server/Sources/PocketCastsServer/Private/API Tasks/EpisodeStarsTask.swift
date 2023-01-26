import Foundation
import PocketCastsDataModel
import PocketCastsUtils
import SwiftProtobuf

class RetrieveEpisodeStarsTask: ApiBaseTask {
    private let completion: ((Int?) -> Void)
    private let episode: Episode

    init(episode: Episode, completion: @escaping ((Int?) -> Void)) {
        self.episode = episode
        self.completion = completion
        super.init()
    }

    override func apiTokenAcquired(token: String) {
        let url = ServerConstants.Urls.api() + "episode/stars"
        do {
            var request = Api_EpisodeStarCountRequest()

            request.podcast = episode.podcastUuid
            request.episode = episode.uuid

            let data = try request.serializedData()
            let (response, httpStatus) = postToServer(url: url, token: token, data: data)

            guard let responseData = response, httpStatus == ServerConstants.HttpConstants.ok else {
                completion(nil)
                return
            }

            do {
                let result = try Api_EpisodeStarCountResponse(serializedData: responseData)

                completion(Int(result.count))
            } catch {
                FileLog.shared.addMessage("Failed  \(error.localizedDescription)")
                completion(nil)
            }
        } catch {
            FileLog.shared.addMessage("Failed  \(error.localizedDescription)")
            completion(nil)
        }
    }
}
