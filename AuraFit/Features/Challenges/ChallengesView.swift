import SwiftUI
import SwiftData

/// The Challenges tab: active and completed style challenges.
struct ChallengesView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \Challenge.startDate, order: .reverse) private var challenges: [Challenge]

    private var active: [Challenge] { challenges.filter { !$0.isCompleted } }
    private var completed: [Challenge] { challenges.filter(\.isCompleted) }

    var body: some View {
        NavigationStack {
            Group {
                if challenges.isEmpty {
                    AFEmptyState(
                        systemImage: "trophy",
                        title: "No challenges",
                        message: "Check back soon for new style challenges to take on."
                    )
                } else {
                    list
                }
            }
            .navigationTitle("Challenges")
            .afScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .accessibilityIdentifier("aurafit.challenges.root.container")
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: AFSpacing.md) {
                if !active.isEmpty {
                    AFSectionHeader(title: "Active")
                    ForEach(active) { challenge in
                        NavigationLink {
                            ChallengeDetailView(challenge: challenge)
                        } label: {
                            ChallengeRowView(challenge: challenge)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !completed.isEmpty {
                    AFSectionHeader(title: "Completed")
                        .padding(.top, AFSpacing.sm)
                    ForEach(completed) { challenge in
                        NavigationLink {
                            ChallengeDetailView(challenge: challenge)
                        } label: {
                            ChallengeRowView(challenge: challenge)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AFSpacing.md)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ChallengesView()
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
