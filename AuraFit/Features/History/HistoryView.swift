import SwiftUI
import SwiftData

/// The History tab: searchable/filterable list of all past fits with quick stats.
struct HistoryView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FitSession.createdAt, order: .reverse) private var sessions: [FitSession]

    @State private var filter: Filter = .all
    @State private var sessionToDelete: FitSession?

    private enum Filter: String, CaseIterable, Identifiable {
        case all = "All"
        case favorites = "Favorites"
        case best = "Top Scores"
        var id: String { rawValue }
    }

    private var filtered: [FitSession] {
        switch filter {
        case .all: return sessions
        case .favorites: return sessions.filter(\.isFavorite)
        case .best: return sessions.filter { $0.overallScore >= 80 }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("History")
            .afScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: AFSpacing.md) {
                filterPicker
                if filtered.isEmpty {
                    AFGlassCard {
                        AFEmptyState(
                            systemImage: "line.3.horizontal.decrease.circle",
                            title: "Nothing here yet",
                            message: filter == .favorites
                                ? "Tap the heart on any fit to save it here."
                                : "Score 80+ on a fit to see it in Top Scores."
                        )
                    }
                    .padding(.top, AFSpacing.lg)
                } else {
                    grid
                }
            }
            .padding(AFSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $filter) {
            ForEach(Filter.allCases) { f in Text(f.rawValue).tag(f) }
        }
        .pickerStyle(.segmented)
    }

    private var grid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: AFSpacing.md),
                            GridItem(.flexible(), spacing: AFSpacing.md)],
                  spacing: AFSpacing.md) {
            ForEach(filtered) { session in
                NavigationLink {
                    FitDetailView(session: session)
                } label: {
                    FitCardView(session: session,
                                width: nil,
                                image: environment.imageStore.loadImage(relativePath: session.originalImagePath))
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
                        repo.setFavorite(session, !session.isFavorite)
                    } label: {
                        Label(session.isFavorite ? "Unfavorite" : "Favorite",
                              systemImage: session.isFavorite ? "heart.slash" : "heart")
                    }
                    Button(role: .destructive) {
                        sessionToDelete = session
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .confirmationDialog("Delete this fit?",
                            isPresented: Binding(get: { sessionToDelete != nil },
                                                 set: { if !$0 { sessionToDelete = nil } }),
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
                    repo.delete(session)
                    HapticsManager.shared.impact(.rigid)
                }
                sessionToDelete = nil
            }
            Button("Cancel", role: .cancel) { sessionToDelete = nil }
        } message: {
            Text("This removes the fit and its saved images. This can't be undone.")
        }
    }

    private var emptyState: some View {
        ScrollView {
            AFEmptyState(
                systemImage: "clock.arrow.circlepath",
                title: "No fits yet",
                message: "Your scanned fits will appear here with scores and stats.",
                actionTitle: "Scan a Fit"
            ) {
                router.startScan()
            }
            .padding(.top, AFSpacing.xxl)
        }
    }
}

#Preview {
    HistoryView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
