import SwiftUI

struct BetaMenu: View {
    @State var enabled = true
    var body: some View {
        List {
            ForEach(FeatureFlag.allCases, id: \.self) { feature in
                Toggle(feature.rawValue, isOn: feature.isOn)
            }
        }
    }
}

private extension FeatureFlag {
    var isOn: Binding<Bool> {
        return Binding<Bool>(
            get: {
                return isEnabled
            },
            set: { enabled in
                try? FeatureFlagOverrideStore().override(self, withValue: enabled)
            }
        )
    }
}

struct BetaMenu_Previews: PreviewProvider {
    static var previews: some View {
        BetaMenu()
    }
}
