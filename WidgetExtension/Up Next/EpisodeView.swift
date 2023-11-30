import Foundation
import SwiftUI

struct EpisodeView: View {
    @State var episode: WidgetEpisode
    @State var topText: Text
    @State var isPlaying: Bool = false
    @State var isFirstEpisode: Bool = false

    @Environment(\.dynamicTypeSize) var typeSize

    var body: some View {
        Link(destination: CommonWidgetHelper.urlForEpisodeUuid(uuid: episode.episodeUuid)!) {
            HStack(spacing: 12) {
                SmallArtworkView(imageData: episode.imageData)
                VStack(alignment: .leading) {
                    Text(episode.episodeTitle)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isFirstEpisode, #available(iOS 17, *) {
                        Spacer()
                        Toggle(isOn: isPlaying, intent: PlayEpisodeIntent(episodeUuid: episode.episodeUuid)) {
                            topText
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(newTopBackgroundColor)
                        }
                        .toggleStyle(WidgetFirstEpisodePlayToggleStyle())
                    } else {
                        Spacer()
                            .frame(height: 4)
                        topText
                            .font(.caption2)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                if !isFirstEpisode, #available(iOS 17, *) {
                    Toggle(isOn: isPlaying, intent: PlayEpisodeIntent(episodeUuid: episode.episodeUuid)) {}
                    .toggleStyle(WidgetPlayToggleStyle())
                }
            }
        }
    }

    @ViewBuilder
    static func createCompactWhenNecessaryView(episode: WidgetEpisode) -> some View {
        EpisodeView(episode: episode, topText: Text(CommonWidgetHelper.durationString(duration: episode.duration)))
    }
}

struct WidgetFirstEpisodePlayToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            Group {
                configuration.isOn ?
                Image("icon-pause")
                    .resizable()
                    .foregroundStyle(newTopBackgroundColor)
                :
                Image("icon-play")
                    .resizable()
                    .foregroundStyle(newTopBackgroundColor)
            }
            .frame(width: 24, height: 24)
            // TODO: Something fun - create a timeline that counts down by the minute instead of showing "now playing"
            configuration.label
                .truncationMode(.tail)
        }
        .padding(.trailing, 14) // matches the 8px leading built into the icon
        .padding(.leading, 6) // 6 + 8 (from icon) = 14 in design
        .padding(.vertical, 2) // 2 + 8 (from icon) = 10 in design (actually 9.76)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
        )
     }
}

struct WidgetPlayToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundStyle(Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.2))
                    .frame(width: 24, height: 24)
                Group {
                    configuration.isOn ?
                    Image("icon-pause")
                        .resizable()
                        .foregroundStyle(.white)
                    :
                    Image("icon-play")
                        .resizable()
                        .foregroundStyle(.white)
                }
                .frame(width: 24, height: 24)
            }
        }
     }
}
