import Foundation
import PocketCastsDataModel
import PocketCastsUtils

public extension ApiServerHandler {
    func validateLogin(identityToken: Data?, completion: @escaping (Result<(String, String, String), APIError>) -> Void) {
        let url = ServerHelper.asUrl(ServerConstants.Urls.api() + "user/login_apple")
        guard var request = ServerHelper.createEmptyProtoRequest(url: url),
              let identityToken = identityToken,
              let token = String(data: identityToken, encoding: .utf8)
        else {
            FileLog.shared.addMessage("Unable to create protobuffer request to obtain token")
            completion(.failure(.UNKNOWN))
            return
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: ServerConstants.HttpHeaders.authorization)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let responseData = data, error == nil, response?.extractStatusCode() == ServerConstants.HttpConstants.ok else {
                let errorResponse = ApiServerHandler.extractErrorResponse(data: data, error: error)
                FileLog.shared.addMessage("Unable to obtain token, status code: \(response?.extractStatusCode() ?? -1), server error: \(errorResponse?.rawValue ?? "none")")
                completion(.failure(errorResponse ?? .UNKNOWN))
                return
            }

            do {
                let response = try Api_UserLoginResponse(serializedData: responseData)
                completion(.success((response.token, response.uuid, response.email)))
            } catch {
                FileLog.shared.addMessage("Error occurred while trying to unpack token request \(error.localizedDescription)")
                completion(.failure(.UNKNOWN))
            }

        }.resume()
    }
}
