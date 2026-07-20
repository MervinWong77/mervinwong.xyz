import SwiftUI

/// Self-contained scanning mascot scene. Driven only by `ScanAnimationDirector`.
struct ScanningMascotSceneView: View {
    var director: ScanAnimationDirector
    var reduceMotion: Bool = false
    /// Compact stage for the scanning experience — no empty material panel.
    var compact: Bool = false

    @State private var ballX: CGFloat = -36
    @State private var catFacingRight = true
    @State private var catLift: CGFloat = 0
    @State private var blink: CGFloat = 0
    @State private var tailWag: Double = 0
    @State private var showCards = false
    @State private var swipeCardAway = false
    @State private var cardOpacity: Double = 1
    @State private var showCheckmark = false
    @State private var showSparkle = false
    @State private var proud = false
    @State private var idleTask: Task<Void, Never>?
    @State private var blinkTask: Task<Void, Never>?
    @State private var reactionTask: Task<Void, Never>?
    @State private var lastHandledToken: Int = -1

    private var walkAmplitude: CGFloat { compact ? 28 : 44 }
    private var catSize: CGSize { compact ? CGSize(width: 108, height: 88) : CGSize(width: 132, height: 108) }

    var body: some View {
        ZStack {
            if showCheckmark || director.mode == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: compact ? 22 : 28, weight: .semibold))
                    .foregroundStyle(BrandColor.teal)
                    .offset(x: compact ? 72 : 118, y: compact ? -18 : -28)
                    .transition(.opacity.combined(with: .scale))
            }

            if showSparkle {
                DuplicateSparkleView()
                    .scaleEffect(compact ? 0.85 : 1)
                    .offset(y: compact ? -40 : -58)
                    .transition(.opacity.combined(with: .scale))
            }

            HStack(spacing: compact ? 10 : 14) {
                DuplicateFileCardView(title: "photo.jpg")
                    .scaleEffect(compact ? 0.82 : 1, anchor: .bottom)
                    .opacity(showCards ? cardOpacity : 0)
                    .offset(x: swipeCardAway ? -100 : 0, y: swipeCardAway ? -18 : 0)
                    .rotationEffect(.degrees(swipeCardAway ? -10 : 0))

                DuplicateFileCardView(title: "photo copy.jpg", showMatchBadge: showCards && !swipeCardAway)
                    .scaleEffect(compact ? 0.82 : 1, anchor: .bottom)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 14)
                    .scaleEffect(showCards ? 1 : 0.94)
            }
            .offset(y: compact ? -36 : -56)
            .animation(reduceMotion ? nil : .spring(duration: 0.45, bounce: 0.55), value: showCards)
            .animation(reduceMotion ? nil : .easeIn(duration: 0.45), value: swipeCardAway)

            ZStack {
                if !reduceMotion && director.mode == .idlePlay {
                    ScanBallView()
                        .scaleEffect(compact ? 0.85 : 1)
                        .offset(x: ballX, y: compact ? 28 : 42)
                }

                CopyCatMascotView(
                    facingRight: catFacingRight,
                    lift: catLift,
                    blink: blink,
                    tailWag: tailWag,
                    proud: proud || director.mode == .completed
                )
                .frame(width: catSize.width, height: catSize.height)
                .offset(x: reduceMotion ? 0 : ballX * 0.32, y: compact ? 18 : 30)
            }
        }
        // Compact mode: no clip-to-giant-panel — scene is only as tall as its frame.
        .onAppear {
            director.reduceMotion = reduceMotion
            startIdleLoop()
            startBlinkLoop()
        }
        .onDisappear {
            stopAllAnimationTasks()
        }
        .onChange(of: reduceMotion) { _, value in
            director.reduceMotion = value
            if value {
                stopAllAnimationTasks()
                ballX = 0
                catLift = 0
                blink = 0
                tailWag = 0
                showCards = false
                showSparkle = false
            } else if director.mode == .idlePlay {
                startIdleLoop()
                startBlinkLoop()
            }
        }
        .onChange(of: director.mode) { _, mode in
            switch mode {
            case .idlePlay:
                showCheckmark = false
                showSparkle = false
                proud = false
                startIdleLoop()
                startBlinkLoop()
            case .completed:
                stopIdleLoop()
                reactionTask?.cancel()
                withAnimation(reduceMotion ? nil : .spring(duration: 0.5, bounce: 0.4)) {
                    showCheckmark = true
                    showCards = false
                    showSparkle = false
                    proud = true
                    catLift = -4
                    ballX = 0
                    tailWag = 12
                }
            case .cancelled:
                stopAllAnimationTasks()
                showCards = false
                showCheckmark = false
                showSparkle = false
                proud = false
            case .duplicateReaction:
                break
            }
        }
        .onChange(of: director.reactionToken) { _, token in
            guard token != lastHandledToken else { return }
            lastHandledToken = token
            if !reduceMotion {
                playDuplicateReaction()
            }
        }
    }

    private func stopIdleLoop() {
        idleTask?.cancel()
        idleTask = nil
    }

    private func stopBlinkLoop() {
        blinkTask?.cancel()
        blinkTask = nil
    }

    private func stopAllAnimationTasks() {
        stopIdleLoop()
        stopBlinkLoop()
        reactionTask?.cancel()
        reactionTask = nil
    }

    private func startBlinkLoop() {
        stopBlinkLoop()
        guard !reduceMotion else { return }
        blinkTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(Int.random(in: 2200...3800)))
                guard !Task.isCancelled else { break }
                withAnimation(.easeIn(duration: 0.08)) { blink = 1 }
                try? await Task.sleep(for: .milliseconds(90))
                withAnimation(.easeOut(duration: 0.1)) { blink = 0 }
            }
        }
    }

    private func startIdleLoop() {
        stopIdleLoop()
        guard !reduceMotion, director.mode == .idlePlay else { return }
        idleTask = Task { @MainActor in
            while !Task.isCancelled && director.mode == .idlePlay {
                catFacingRight = true
                withAnimation(.easeInOut(duration: 0.95)) {
                    ballX = walkAmplitude
                    catLift = -5
                    tailWag = 18
                }
                try? await Task.sleep(for: .milliseconds(1000))
                guard !Task.isCancelled, director.mode == .idlePlay else { break }

                catFacingRight = false
                withAnimation(.easeInOut(duration: 0.95)) {
                    ballX = -walkAmplitude
                    catLift = 0
                    tailWag = -16
                }
                try? await Task.sleep(for: .milliseconds(1000))
            }
        }
    }

    private func playDuplicateReaction() {
        stopIdleLoop()
        reactionTask?.cancel()
        swipeCardAway = false
        cardOpacity = 1
        showCards = false
        showCheckmark = false
        showSparkle = false

        reactionTask = Task { @MainActor in
            withAnimation(.spring(duration: 0.42, bounce: 0.7)) {
                showCards = true
                ballX = 0
                catLift = -2
                tailWag = 8
            }
            try? await Task.sleep(for: .milliseconds(280))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(duration: 0.35, bounce: 0.55)) {
                showSparkle = true
                catLift = -12
                catFacingRight = true
            }
            try? await Task.sleep(for: .milliseconds(550))
            guard !Task.isCancelled else { return }

            catFacingRight = false
            withAnimation(.easeIn(duration: 0.4)) {
                swipeCardAway = true
                cardOpacity = 0
                showSparkle = false
                catLift = -6
                ballX = -18
            }
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.25)) {
                showCards = false
                swipeCardAway = false
                cardOpacity = 1
                catLift = 0
            }
        }
    }
}
